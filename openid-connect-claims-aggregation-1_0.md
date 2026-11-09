%%%
title = "OpenID Connect Claims Aggregation 1.0 - Draft 04"
abbrev = "oidc-ca"
ipr = "none"
workgroup = "connect"
keyword = ["security", "openid", "privacy"]

[seriesInfo]
name = "OpenID-Draft"
value = "openid-connect-claims-aggregation-1_0"
status = "standard"

[pi]
subcompact = "yes"
private = "Draft-04"
tocdepth = "5"
iprnotified = "no"

[[author]]
initials="N."
surname="Sakimura"
fullname="Nat Sakimura"
organization="NAT.Consulting"
    [author.address]
    email = "nat@nat.consulting"

[[author]]
initials="E."
surname="Jay"
fullname="Edmund Jay"
organization="Illumila"
    [author.address]
    email = "ejay@illumi.la"

%%%

.# Abstract 

OpenID Providers within OpenID Connect assume many roles, one of these is providing End-User claims to relying parties at the consent of the End-User such as their name or date of birth. OpenID Connect defines multiple models under which claims are provided and relied upon by a relying parties, including simple, aggregated and distributed claims. This document focuses on elaborating upon the aggregated model outlined in section 5.6.2 of OpenID Connect core by defining the full life-cycle of aggregated claims and the new roles of the entities involved in an aggregated claims model.

This document specifies the methods for

* an OP acting as a client of Claims Provider (CP) to perform discovery for a Claims Provider Metadata;
* the OP to establish itself as a client of the Claims Provider;
* the OP to obtain claims from the Claims Provider; 
* an RP to ask for verified claims to the OP;  
* the OP to return obtained claims from CP to the RP; and 
* the RP to verify the claims.

.# Warning

This document is not an OIDF International Standard. It is distributed for review and comment. It is subject to change without notice and may not be referred to as an International Standard.

Recipients of this draft are invited to submit, with their comments, notification of any relevant patent rights of which they are aware and to provide supporting documentation.

.# Foreword

The OpenID Foundation (OIDF) promotes, protects and nurtures the OpenID community and technologies. As a non-profit international standardizing body, it is comprised by over 160 participating entities (workgroup participants). The work of preparing implementer drafts and final international standards is carried out through OIDF workgroups in accordance with the OpenID Process. Participants interested in a subject for which a workgroup has been established has the right to be represented in that workgroup. International organizations, governmental and non-governmental, in liaison with OIDF, also take part in the work. OIDF collaborates closely with other standardizing bodies in the related fields.

.# Introduction

OpenID Connect is a selective claims disclosure mechanism. When a set of claims included in its response is about 
an entity authentication event, it works as an entity authentication federation mechanism, but it can deliver 
other claims selected by the subject as well. 

An OpenID Connect response can include claims from several sources. These sources can be authoritative
or corroborative. The roles in the Aggregated Claims model are described in (#actors).

An OP can provide an RP the claims by value or by reference. 

By value is the case where an OP collects claims and their values 
from CPs and aggregate them in one package to provide to the RP. 
This model is called Aggregated Claims Model. 

By reference is the case where the OP does not collect and provide the value 
but just provide the reference and its access information to the RP. 
This model is called Distributed Claims Model. 

Another feature that this document provides is the way to avoid multiple consent screen 
per RP authorization request. If OpenID Connect Core spec is used to build Aggregated Claims Model 
naively, it may result in many consent screens per RP request. 
For example, if four CPs and one OP is involved in the request, then, there may be five consent screens. 
This is too onerous. This document defines a mechanism to consolidate it into one consent screen. 
This is done through one "OP User Setup Phase" per CP that the OP obtains the consent 
from the subject to obtain claims from the CP for the purpose of creating aggregated 
claims response for future RP requests in which OP will collect a new consent from the subject. 

The OP obtains an access token and, if needed and granted, a refresh token. The CP's UserInfo endpoint
returns signed Claim Sets. Profiles and trust frameworks may require the use of refresh tokens.


There are four phases defined in this document. 

1. CP Discovery Phase: OP discovers CP metadata. 
1. Client Configuration Phase: OP establishes itself as a client of the CP.
1. Setup Phase: The Subject authorizes the OP to obtain claims from the CP. The OP obtains an access token and may obtain a refresh token.
1. RP Phase: 
    1. RP makes authentication and claims request, 
	1. OP fetches relevant claim sets from CPs, 
	1. OP respond to the RP
	1. the RP verifies the response. 

Intended reader of this document is the developer and systems architect who builds attributes and claims base systems. 



.# Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" in this document are to be interpreted as described in BCP
14 [RFC2119] [RFC8174] when, and only when, they appear in all
capitals, as shown here.

{mainmatter}

# Scope

This document specifies the methods for

* an OP acting as a client of Claims Provider (CP) to perform discovery for a Claims Provider Metadata;
* the OP to establish itself as a client of the Claims Provider;
* the OP to obtain claims from the Claims Provider; 
* the OP to return obtained claims from CP to the RP; and 
* the RP to verify the claims.

# Normative references
The following referenced documents are indispensable for the application of this document. For dated references, only the edition cited applied. For undated references, the latest edition of the referenced document (including any amendments) applies.

[BCP14] - Key words for use in RFCs to Indicate Requirement Levels
[BCP14]: https://tools.ietf.org/html/bcp14

[RFC6749] - The OAuth 2.0 Authorization Framework
[RFC6749]: https://tools.ietf.org/html/rfc6749

[RFC6750] - The OAuth 2.0 Authorization Framework: Bearer Token Usage
[RFC6750]: https://tools.ietf.org/html/rfc6750

[OIDC] - OpenID Connect Core 1.0 incorporating errata set 1
[OIDC]: https://openid.net/specs/openid-connect-core-1_0.html

[OpenID.Discovery] - OpenID Connect Discovery 1.0
[OpenID.Discovery]: https://openid.net/specs/openid-connect-discovery-1_0.html

[OpenID.Registration] - OpenID Connect Registration 1.0
[OpenID.Registration]: http://openid.net/specs/openid-connect-registration-1_0.html

[OpenID.Federation] - OpenID Federation 1.0
[OpenID.Federation]: https://openid.net/specs/openid-federation-1_0.html

[JWT] - JSON Web Token
[JWT]: http://tools.ietf.org/html/draft-ietf-oauth-json-web-token

[JWS] - JSON Web Signature
[JWS]: http://tools.ietf.org/html/draft-ietf-jose-json-web-signature

[JWE] - JSON Web Encryption
[JWE]: http://tools.ietf.org/html/draft-ietf-jose-json-web-encryption

[JWA] - JSON Web Algorithms
[JWA]: http://tools.ietf.org/html/draft-ietf-jose-json-web-algorithms


# Terms and definitions
For the purpose of this document, the terms defined in [RFC6749], [RFC6750], [RFC7636], [OpenID Connect Core][OIDC] and the following apply.

**Claim Set** – a set of claims issued by a Claims Provider


# Symbols and abbreviated terms

**RP** – Relying Party

**OP** – OpenID Provider

**CP** – Claims Provider

**HTTP** - Hyper Text Transfer Protocol

**TLS** - Transport Layer Security

# Actors

~~~ ascii-art
Subject --- authorizes release to the OP ------> CP
Subject --- authorizes disclosure to the RP ---> OP

CP <------ requests claims ------ OP <------ requests claims ------ RP
CP ------- signed Claim Sets ---> OP ------- Aggregated Claims ---> RP
~~~
Figure: Relationships among actors


## Subject (User)

Subject is the entity that grants access to the claims at CPs and the OP. 
In this system, the Subject grants CP to provide OP the Claims for 
the purpose of providing those claims with other claims to potentially 
unspecified RPs under the Subject's direction. 

This request from the OP to the CP is sent by the Subject's instruction. 
The Subject also allows OP to potentially store the obtained claims. 

The Subject also allows RP to make a claims request to the OP, 
typically for the Subject to receive some services from the RP. 

## RP

RP is an actor that typically provides some service to the Subject. 
To perform the service, the RP obtains some claims about the Subject from OP. 
The basis for the processing of the Subject's claims by the RP can be 
performance of contract, consent, and other lawful basis. 

## CP

CP, Claims Provider, is a role assumed by an OpenID Provider 
that supports signed UserInfo response and has the OP as a client.  

The provision for the Claims Provider are as follows: 

1. It MUST support signed UserInfo response. 
1. It MUST support OpenID Federation Automatic Registration as specified in (#client-configuration-phase).

### UserInfo Endpoint
The UserInfo Endpoint is described in 5.3 of OpenID Connect 1.0 [OIDC] as an OAuth 2.0 Protected Resource that returns Claims about the authenticated Subject.

For Claims Aggregation, the CP MUST set the `aud` Claim of the signed UserInfo JWT to the `client_id`
of the OP to which the access token was issued, in accordance with Section 5.3.2 of [OIDC].
The `aud` Claim MUST identify only that client, either as a string or as an array containing that string as its only element.


## OP

OP is an entity that acts as an OpenID Provider to the RP. 
Also, OP acts as a relying party to CPs. 

The provision for the OP is as follows: 

1. It MUST support OpenID Connect Aggregated Claims as an OpenID Provider. 
1. It MUST act as an OpenID Connect relying party to CPs to fetch claims from CPs according to instructions given by the Subject. 
1. It MAY store the signed claims obtained from CPs with appropriate safeguarding controls. 
1. To the authenticated Subject, it MUST provide a user interface to show what claims about the subject it stores. 
1. It MUST NOT provide claims to RPs without the Subject's permission. 



# Trust Model

This specification uses the L1 trust model. The RP relies on the OP to associate Claim Sets from
CPs with the Subject authenticated by the OP. By including an Aggregated Claim Set in an ID Token
or UserInfo response, the OP asserts that the Claim Set is about the Subject identified by the
`sub` in that response.

The OP MUST bind the CP's Issuer Identifier and Subject Identifier (`iss`, `sub`), obtained from
the validated CP ID Token during Setup, to the authenticated OP account that initiated Setup.
The OP MUST bind the corresponding authorization grant and its access and refresh tokens to the
same OP account. Token refresh and downscoping MUST preserve this binding. When it obtains a signed
UserInfo response, the OP MUST validate it according to [OIDC], verify its signature and audience,
and match its `iss` and `sub` against the stored CP identifiers. The OP MUST use those tokens and
any Claim Sets obtained with them only for the bound OP account. This requirement also applies to
stored Claim Sets.

The OP and the CP establish trust for client registration through [OpenID.Federation]. The CP's
grant authorizes the OP to collect claims. Disclosure to a particular RP requires the Subject's
separate authorization at the OP as described in (#subject-granting).

The RP MUST validate the OP's ID Token or UserInfo response according to [OIDC]. The RP MUST
apply its trust policy to decide whether it trusts the OP to associate claims with the Subject
and whether it trusts each CP as a source for the claims it uses. The RP MAY use Federation to
establish trust in either party. A deployment can use Federation Trust Marks to indicate
conformance with its trust framework.
Profiles can define additional subject binding or presentation-time authentication requirements.

# Discovery Phase

Before making an OpenID Connect Authentication Request to a CP, the OP needs to obtain
configuration information from the CP, 
including its Authorization Endpoint, Token Endpoint, and UserInfo Endpoint locations. 

This information is obtained via Discovery, as described in OpenID Connect Discovery 1.0 [OpenID.Discovery], or may be obtained via other mechanisms.

The Claims Provider Metadata uses the following parameters from [OpenID.Discovery].

`userinfo_endpoint`
: **Required**. Claims Endpoint. URL at the Issuing-Authority that provides signed claims.

`userinfo_signing_alg_values_supported`
: **Optional**. JSON array containing a list of the  JWS [JWS] signing algorithms (alg values) JWA [JWA] supported by the UserInfo Endpoint to encode the Claims in a  JWT [JWT]. The value *none* MUST NOT be included.


## Aggregating OP Metadata

The OP MUST include `aggregated` in `claim_types_supported` and set `claims_parameter_supported`
to `true` in its `openid_provider` metadata. If the OP also publishes a configuration document
using [OpenID.Discovery], it MUST advertise the same capabilities there. These parameters
describe the OP's capabilities for serving RPs. A CP that only serves signed UserInfo to the OP
has no requirement to advertise `aggregated` in that role.


# Client Configuration Phase

The OP acts as an OpenID Connect client of the CP. The OP and the CP MUST use Automatic Registration
as specified in Section 12.1 of [OpenID.Federation].
The OP MUST publish `openid_provider` and `openid_relying_party` metadata in its Entity Configuration
under the same Entity Identifier. The OP MUST use this Entity Identifier as both its Issuer Identifier
and its `client_id` at the CP. The OP and the CP MUST perform Trust Chain and metadata resolution
as required by [OpenID.Federation].

For example, an OP with the Issuer Identifier `https://op.example` uses `https://op.example` as its
`client_id` at the CP and publishes its Entity Configuration at
`https://op.example/.well-known/openid-federation`.

## Client Metadata

The OP MUST include the following client metadata defined in [OpenID.Registration] in its
`openid_relying_party` metadata.

- `userinfo_signed_response_alg`. An asymmetric signing algorithm supported by the CP so that the RP
  can verify the Claim Set using the CP's public key.
- `policy_uri`. URL of the OP's privacy policy to be shown to the Subject during the Setup Phase.

The OP MUST omit `userinfo_encrypted_response_alg`.


# Setup Phase

The OP obtains the Subject's authorization to collect claims from each CP it will use. The OP
MUST use an OpenID Connect Authentication Request to obtain the grant. It SHOULD identify the
requested claims using `scope`, `claims.userinfo`, or both. It MUST associate the grant and tokens
with the authenticated OP account as specified in (#trust-model).

When requesting a refresh token for offline access, the OP MUST include `offline_access` in
`scope` and use a response type that returns an authorization code. The OP and CP MUST follow
the consent requirements in Section 11 of [OIDC], including `prompt=consent` unless other
conditions permitting offline access are in place.

The CP MUST show the Subject a dialogue explaining that the OP will obtain signed Claim Sets
to provide claims to RPs at the Subject's direction. The dialogue MUST include a link to the
`policy_uri` in the OP's client metadata. Granting access MUST involve active user interaction.

# Delivery Phase (RP Phase)

In Delivery Phase, the claims are delivered to RP. 
To do so, it typically goes through the following steps: 

1. (Claims Request) The RP sends an OpenID Connect Authentication Request to the OP.
1. (Request Verification) The OP verifies if the request is valid. 
1. (Subject Granting) The OP shows dialogue to the Authenticated Subject if it grants the access to the claims and obtains grant from the Subject. 
1. (Claims Collection) The OP accesses relevant Claims Provider's UserInfo Endpoints with Access Tokens to collect signed claims
1. (Claims Verification) The RP verifies the received response. 

## Claims Request by RP to OP

The RP MUST use an OpenID Connect Authentication Request as defined in [OIDC]. To request
individual claims, the RP MUST use the standard `claims` parameter with `userinfo`, `id_token`, or both,
as described in Section 5.5 of [OIDC]. The OP MUST support this parameter. The RP can also use
`scope` as defined in [OIDC].

The OP selects CPs associated with the Subject's account and MUST use the Aggregated Claims format
for claims it returns from those CPs. The RP can apply its own policy to the CP's signed `iss`
when deciding whether to use the claims. The request syntax defined here covers claim names.
Requesting a specific CP or specifying freshness requirements for CP data requires an extension.


## RP authentication and the request verification

Upon receipt of the request, the OP 

1. MUST verify that the request is not tampered and is from a valid registered RP if the request is signed; and 
1. MUST at least verify that the client_id is valid and make sure 
   that the authorization code that it is going to return will be bound to this client_id if the request is not signed. 

NOTE: RP MUST be authenticated at one point or another before completion of the transaction. 

## Subject Granting

After verifying the request, the OP 

1. MUST authenticate the Subject if it has not yet been; 
1. MUST show the Subject what is being requested from the RP; 
1. MUST show the Subject the link to the RP provided policy_url; and 
1. MUST obtain grant from the Subject through explicit action. 

## Claims Collection

The OP MAY collect Claim Sets before an RP requests them if the CP grant and the Subject's
authorization permit it. The OP MAY reuse a stored Claim Set if it still meets the applicable
validity, authorization, and account-binding requirements.

For a new collection, the OP SHOULD use an access token with the narrowest scope available for
the claims it needs. If the available access token grants broader access than needed, and a
refresh token and a suitable narrower scope are available, the OP SHOULD request a downscoped
access token using `grant_type=refresh_token` and `scope`, as described in Section 12 of [OIDC]
and Section 6 of [RFC6749]. The requested scope MUST be within the scope of the original grant.
The OP MUST successfully reevaluate trust in the CP before continuing to make requests after
the Trust Chain expires, as specified in Section 12.3 of [OpenID.Federation].

If the OP cannot collect a suitable Claim Set using a valid access token or a refresh token,
it MUST obtain the necessary authorization from the Subject at the CP or omit the affected claims.


### UserInfo Endpoint Request

For claims collection, the OP

1. MUST send OAuth protected resource request to the UserInfo Endpoint using previously obtained Access Token as described in 5.3.1 of OpenID Connect 1.0 [OIDC];

This process will be repeated for as each Claims Providers as necessary.

## Claims Delivery

The OP creates the Aggregated Claims response as described in Section 5.6.2 of [OIDC]. The RP
receives the entire signed JWT embedded in `_claim_sources`, including claims that are not listed
in `_claim_names`. The OP MUST ensure that every claim it discloses in the embedded JWT is
authorized for disclosure to that RP. If a Claim Set includes claims the OP cannot disclose,
the OP MUST obtain a suitable Claim Set from the CP or omit that JWT from the response.

## Claims Verification

For Claims Verification,  

1. the RP MUST verify the signature of the Aggregate Claim according to  [JWS] using the algorithm specified in the JWT  *alg*  Header Parameter the keys provided by the Issuer of the Aggregate Claim for the signature verification; 
1. the RP MUST extract the signed claims from JWT and other relevant members and verify according to their verification rule; 
1. the RP MUST verify that issuers of the signed claims in the aggregated claims are the ones it trusts; 
1. the RP MUST verify that each signed Claim Set has exactly one `aud` value and that it matches
   the Issuer Identifier of the OP used for the OpenID Connect transaction. The RP MUST use the Issuer
   Identifier established for that OP during OpenID Connect validation. When the Aggregated Claims
   are delivered in a UserInfo response, the RP uses the OP associated with the access token used for
   that request. The RP MUST compare the strings without normalization as specified in Section 14 of [OIDC];
1. The RP MUST reject the response if any of the verification above fails. 

# Security Considerations

The security considerations of [OIDC] and [OpenID.Federation] apply.

## Audience Binding

The RP uses the OP's Issuer Identifier to check the audience of each Claim Set. This check relies on
the CP binding that `client_id` to the correct client. The CP MUST establish the client as specified
in (#client-configuration-phase) before issuing a signed UserInfo response for Claims Aggregation.
The CP MUST NOT allow a different client to use that `client_id`, including through a separate registration.

The audience check binds the Claim Set to the OP that obtained it. The RP also verifies the CP's signature
and determines whether it trusts the CP to issue the claims.

## Cross-User Claim Substitution

A compromised or malicious OP can include a Claim Set for one Subject in a response for
another Subject. The substituted Claim Set can have a valid CP signature and the expected OP
audience. The RP's signature and audience checks therefore cannot detect this substitution.
The trust model in (#trust-model) relies on the OP to preserve the account binding through
collection, storage, and disclosure. A Federation Trust Mark can attest to an OP's compliance
with operational requirements. It does not prove the account binding for a particular response.

# Privacy Considerations

Unless ephemeral identifiers are used at CPs, colluding RPs CAN correlate the subject using the `sub` value in the JWT included in the aggregated claim.


{backmatter}

# Notices

Copyright (c) 2025 The OpenID Foundation.

The OpenID Foundation (OIDF) grants to any Contributor, developer,
implementer, or other interested party a non-exclusive, royalty free,
worldwide copyright license to reproduce, prepare derivative works from,
distribute, perform and display, this Implementers Draft, Final
Specification, or Final Specification Incorporating Errata Corrections
solely for the purposes of (i) developing specifications,
and (ii) implementing Implementers Drafts, Final Specifications,
and Final Specification Incorporating Errata Corrections based
on such documents, provided that attribution be made to the OIDF as the
source of the material, but that such attribution does not indicate an
endorsement by the OIDF.

The technology described in this specification was made available
from contributions from various sources, including members of the OpenID
Foundation and others. Although the OpenID Foundation has taken steps to
help ensure that the technology is available for distribution, it takes
no position regarding the validity or scope of any intellectual property
or other rights that might be claimed to pertain to the implementation
or use of the technology described in this specification or the extent
to which any license under such rights might or might not be available;
neither does it represent that it has made any independent effort to
identify any such rights. The OpenID Foundation and the contributors to
this specification make no (and hereby expressly disclaim any)
warranties (express, implied, or otherwise), including implied
warranties of merchantability, non-infringement, fitness for a
particular purpose, or title, related to this specification, and the
entire risk as to implementing this specification is assumed by the
implementer. The OpenID Intellectual Property Rights policy
(found at openid.net) requires
contributors to offer a patent promise not to assert certain patent
claims against other contributors and against implementers.
OpenID invites any interested party to bring to its attention any
copyrights, patents, patent applications, or other proprietary rights
that may cover technology that may be required to practice this
specification.


# Acknowledgements

We would like to thank the following people for their valuable feedback and contributions that helped to evolve this specification.

[[TBD]]

# Document History

[[ To be removed from the final specification ]]

-04

* Clarified downscoping, offline access, and the use of stored Claim Sets
* Anti RP-RP' Linkability provision added
* Stated the L1 trust model and described the risk of cross-user claim substitution
* Clarified how RPs request claims and how the aggregating OP advertises support

-03

* Simplified claims aggregation 
  * Rollback changes introduced in version 02
* Removed Claims Endpoint and related metadata and registration options
* Reuses Userinfo endpoint at Claims Provider to return aggregation claims
* Removed c_token in claims object

-02

* defined new names for actors 
  * OpenID Provider (OP) -> Identity Wallet (IW)
  * Claims Provider (CP) -> Issuing Authority (IA)
  * Relying Party (RP) -> Claims Consumer (CC)
* Claims endpoint response formats allows multiple schema types (W3C VC, JWT)
  * Added 'claimset_format', 'sub_jwk', 'did' to authorization request parameters
  * Added 'format' to claims endpoint response
* Added new requirements for claims endpoint
  * MTLS or DPOP for sender constrain tokens
  * Support OID4IDA claims
  * Support W3C VC response format
* Support for DIDs in request/response

-01

* initial revision
* defined claims endpoint & discovery metadata
* defined registration of claims endpoint response signature and encryption algs
* defined c_token in claims object to request claims from claims endpoint
* 