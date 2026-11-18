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

OpenID Connect Core defines the representation of Aggregated Claims returned by an OpenID
Provider to a Relying Party, but does not prescribe the OP-to-CP protocol for obtaining the JWT
used in that representation. In particular, it does not require the JWT to be a UserInfo
response. This specification provides implementation guidance for that interaction and defines
an OAuth-protected Claims Endpoint, together with discovery, authorization, account binding,
storage, disclosure, and verification requirements. Its scope is Aggregated Claims; the endpoint
used by an RP to retrieve Distributed Claims in Section 5.6.2 of [OIDC] is distinct from the
OP-to-CP collection interface defined here.

The Claims Endpoint separates OP-facing account-binding information from the CP-signed Claim
Set disclosed to the RP. This permits a Claim Set without a `sub` claim: the OP verifies the CP
account association when collecting it and preserves that association when storing and
disclosing it. The RP relies on the OP for Subject binding under the L1 trust model. Omitting
`sub` does not prevent correlation through reuse of the same JWT or through identifying
attributes. The Subject can authorize reuse of stored Claim Sets or request new issuance, with
the corresponding privacy and availability tradeoffs described in the Privacy Considerations.

Another feature that this document provides is the way to avoid multiple consent screen 
per RP authorization request. If OpenID Connect Core spec is used to build Aggregated Claims Model 
naively, it may result in many consent screens per RP request. 
For example, if four CPs and one OP is involved in the request, then, there may be five consent screens. 
This is too onerous. This document defines a mechanism to consolidate it into one consent screen. 
This is done through one "OP User Setup Phase" per CP that the OP obtains the consent 
from the subject to obtain claims from the CP for the purpose of creating aggregated 
claims response for future RP requests in which OP will collect a new consent from the subject. 

The OP obtains an access token and, if needed and granted, a refresh token. The CP's Claim Set
Endpoint returns signed Claim Sets separately from OP-facing account-binding information.
Profiles and trust frameworks may require the use of refresh tokens.


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

[RFC6838] - Media Type Specifications and Registration Procedures
[RFC6838]: https://www.rfc-editor.org/rfc/rfc6838.html

[RFC7009] - OAuth 2.0 Token Revocation
[RFC7009]: https://www.rfc-editor.org/rfc/rfc7009.html

[RFC7636] - Proof Key for Code Exchange by OAuth Public Clients
[RFC7636]: https://www.rfc-editor.org/rfc/rfc7636.html

[RFC8414] - OAuth 2.0 Authorization Server Metadata
[RFC8414]: https://www.rfc-editor.org/rfc/rfc8414.html

[RFC8705] - OAuth 2.0 Mutual-TLS Client Authentication and Certificate-Bound Access Tokens
[RFC8705]: https://www.rfc-editor.org/rfc/rfc8705.html

[RFC8725] - JSON Web Token Best Current Practices
[RFC8725]: https://www.rfc-editor.org/rfc/rfc8725.html

[RFC9207] - OAuth 2.0 Authorization Server Issuer Identification
[RFC9207]: https://www.rfc-editor.org/rfc/rfc9207.html

[RFC9449] - OAuth 2.0 Demonstrating Proof of Possession (DPoP)
[RFC9449]: https://www.rfc-editor.org/rfc/rfc9449.html

[RFC9700] - Best Current Practice for OAuth 2.0 Security
[RFC9700]: https://www.rfc-editor.org/rfc/rfc9700.html

[OIDC] - OpenID Connect Core 1.0 incorporating errata set 2
[OIDC]: https://openid.net/specs/openid-connect-core-1_0.html

[OpenID.Discovery] - OpenID Connect Discovery 1.0
[OpenID.Discovery]: https://openid.net/specs/openid-connect-discovery-1_0.html

[OpenID.Registration] - OpenID Connect Dynamic Client Registration 1.0 incorporating errata set 2
[OpenID.Registration]: https://openid.net/specs/openid-connect-registration-1_0.html

[OpenID.Federation] - OpenID Federation 1.0
[OpenID.Federation]: https://openid.net/specs/openid-federation-1_0.html

[OpenID4IDA] - OpenID Connect for Identity Assurance 1.0 incorporating errata set 1
[OpenID4IDA]: https://openid.net/specs/openid-connect-4-identity-assurance-1_0-errata1.html

[JWT] - JSON Web Token
[JWT]: https://www.rfc-editor.org/rfc/rfc7519.html

[JWS] - JSON Web Signature
[JWS]: https://www.rfc-editor.org/rfc/rfc7515.html

[JWE] - JSON Web Encryption
[JWE]: http://tools.ietf.org/html/draft-ietf-jose-json-web-encryption

[JWA] - JSON Web Algorithms
[JWA]: https://www.rfc-editor.org/rfc/rfc7518.html

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
that supports the Claims Endpoint defined here and has the OP as a client.

The provision for the Claims Provider are as follows: 

1. It MUST support the Claims Endpoint and signed Claim Set format defined below.
1. It MUST support OpenID Federation Automatic Registration as specified in (#client-configuration-phase).
1. It SHOULD provide an authenticated Subject with a user interface to review and revoke
   standing grants issued to OPs, including the claims and operations those grants permit.

### Claims Endpoint

The Claims Endpoint is an OAuth 2.0 Protected Resource used by the OP to obtain
CP-signed Claim Sets. It is distinct from the UserInfo Endpoint in Section 5.3 of [OIDC]
and from the RP-facing endpoint for Distributed Claims in Section 5.6.2 of [OIDC]. Its
request and response are defined in (#claims-endpoint-request) and
(#claims-endpoint-response).

### Signed Claim Set Format

A Claim Set MUST be a compact, asymmetrically signed JWS containing a JSON object. Its
protected header MUST contain `typ` with the value `claims-aggregation+jwt`. This is the
`application/`-omitted form of the media type `application/claims-aggregation+jwt`, as
specified in Section 4.1.9 of [JWS]. This type identifies the inner signed Claim Set, not
the JSON acquisition envelope or the OP's enclosing ID Token or UserInfo response.
The CP MUST include `iss`, `aud`, `iat`, and `exp` in the payload. The `iss` MUST be the
CP's validated Issuer Identifier. The `aud` MUST identify only the OP's Entity Identifier, which is both
its `client_id` at the CP and its Issuer Identifier under (#client-configuration-phase),
either as a string or as an array containing that string as its only element. The `iat` and `exp` MUST be
NumericDate values as defined in [JWT], with `exp` later than `iat`. These timestamps describe
the issuance and expiration of the JWT, not when the underlying attributes were verified.

The Claim Set MUST NOT contain `sub`. The CP MUST NOT include the OP-facing `account_ref`
or an equivalent CP account identifier under another claim name for account binding.
This does not prohibit identifying attributes that the Subject authorizes for disclosure,
such as a name or an explicitly requested identifier; their correlation risks still apply.
Claims supplied to the RP MUST appear as top-level members that can be referenced using
`_claim_names` as specified in Section 5.6.2 of [OIDC]. The format does not introduce a
holder proof or require a per-presentation identifier or `jti`.

The CP MUST implement `RS256` signing, and the OP and RP MUST implement `RS256` signature
verification for Claim Sets. The OP MUST support selecting `RS256` in a Claims Endpoint
request. Implementations MAY support additional asymmetric signing algorithms, subject to
metadata and policy validation in (#signature-validation).

The CP MUST sign the JWT using the `signing_alg` accepted in the Claims Endpoint request. It MUST
NOT use the same signing key with more than one signature algorithm. For each key used to
sign Claim Sets, it MUST publish the intended algorithm in the `alg` parameter of every
JWK representation it advertises for that key.

When rotating signing keys, the CP SHOULD keep each retired public key available through its
advertised verification-key sources until all Claim Sets signed with that key have expired,
including the clock-skew allowance used by the deployment. Compromised keys MAY be withdrawn
earlier under the deployment's key revocation policy.

The name Claims Endpoint and the metadata names `claims_endpoint` and
`claims_signing_alg_values_supported` restore terminology used in an earlier draft of this
specification. This does not restore that draft's wire format: this profile separates
OP-facing account binding from the signed JWT disclosed to the RP.

Registration requests for the two CP metadata names and the Claim Set media type are
specified in (#iana-considerations).

[[ Editor's note: The registration templates are defined below; formal registration has
not yet been completed. Before submission, references must identify a stable, publicly
available specification version. Previous use of a name in a draft is not a registration. ]]

## OP

OP is an entity that acts as an OpenID Provider to the RP. 
Also, OP acts as a relying party to CPs. 

The provision for the OP is as follows: 

1. It MUST support OpenID Connect Aggregated Claims as an OpenID Provider. 
1. It MUST act as an OpenID Connect relying party to CPs to fetch claims from CPs according to instructions given by the Subject. 
1. It MAY store the signed claims obtained from CPs with appropriate safeguarding controls. 
1. It MUST provide the authenticated Subject with the storage and authorization controls
   described in (#subject-control-of-stored-claim-sets), including a view of stored claims.
1. It MUST NOT provide claims to RPs without the Subject's permission. 



# Trust Model

This specification uses the L1 trust model. The RP relies on the OP to associate Claim Sets from
CPs with the Subject authenticated by the OP. By including an Aggregated Claim Set in an ID Token
or UserInfo response, the OP asserts that the Claim Set is about the Subject identified by the
`sub` in that response.

The OP MUST bind the CP's Issuer Identifier and Subject Identifier (`iss`, `sub`), obtained from
the validated CP ID Token during Setup, to the authenticated OP account that initiated Setup.
The OP MUST bind the corresponding authorization grant and its access and refresh tokens to the
same OP account. Token refresh and downscoping MUST preserve this binding. When collecting a
Claim Set, the OP MUST validate the CP response according to (#claims-endpoint-response) and the signed JWT according to (#claims-verification),
including matching the response `account_ref` against the stored CP Subject Identifier
and the JWT `iss` against the stored CP Issuer Identifier. The OP MUST use
those tokens and any Claim Sets obtained with them only for the bound OP account. This
requirement also applies to stored Claim Sets.

The OP and the CP establish trust for client registration through [OpenID.Federation]. The CP's
grant authorizes the OP to collect claims. Disclosure to a particular RP requires the Subject's
separate authorization at the OP as described in (#subject-granting).

The RP MUST validate the OP's ID Token or UserInfo response according to [OIDC]. The RP MUST
apply its trust policy to decide whether it trusts the OP to associate claims with the Subject
and whether it trusts each CP as a source for the claims it uses. The RP MAY use Federation to
establish trust in either party. A deployment can use Federation Trust Marks to indicate
conformance with its trust framework.
The bare CP-signed JWT contains no CP Subject Identifier and does not independently prove
which Subject it concerns. The RP relies on the OP's enclosing response and the protected
acquisition and storage binding. A bare JWT imported from another source MUST NOT by itself
establish an account binding. Restoration of a stored Claim Set MUST also restore and
validate its protected account-binding record. Export does not make the JWT usable with a
different OP audience. Profiles can define additional subject binding or presentation-time
authentication requirements.

# Discovery Phase

Before making an OpenID Connect Authentication Request to a CP, the OP needs to obtain
configuration information from the CP, 
including its Authorization Endpoint, Token Endpoint, and Claims Endpoint locations.

This information is obtained via Discovery, as described in OpenID Connect Discovery 1.0 [OpenID.Discovery], or may be obtained via other mechanisms.

For each Setup transaction, the OP MUST identify the CP by its Issuer Identifier and use
metadata resolved for that issuer. The OP MUST validate the issuer as required by Section 4.3
of [OpenID.Discovery] or Section 5.1.3 of [OpenID.Federation]. Other metadata acquisition
mechanisms MUST provide the same validated issuer binding. The OP MAY reuse metadata cached
for that issuer while it remains valid under the applicable caching rules and, when using
Federation, the Trust Chain validity requirements in Section 12.3 of [OpenID.Federation].
Once those validity conditions cease to hold, the OP MUST successfully refresh and validate
the metadata and, when applicable, reevaluate trust before continuing the transaction.
The OP MUST retain the association between the issuer and the resolved endpoints throughout
the transaction.
The OP MUST NOT treat the Authorization Endpoint, Token Endpoint, or Claims Endpoint as
independently configurable values detached from the CP's Issuer Identifier.

The CP MUST publish the following metadata in its `openid_provider` metadata and, if it
also publishes an [OpenID.Discovery] configuration document, in that document with the same
values. These parameters extend the metadata in [OpenID.Discovery].

`claims_endpoint`
: **Required**. HTTPS URL of the CP's Claims Endpoint. It MUST NOT contain a fragment.

`claims_signing_alg_values_supported`
: **Required**. Non-empty JSON array of asymmetric JWS signing algorithms supported for
  Claim Sets. `none` and symmetric MAC algorithms MUST NOT be included. The CP MUST support
  each advertised algorithm through the request selection defined below and MUST include
  `RS256` in this array. The OP MUST find an algorithm permitted by its local policy or
  abort collection. Additional asymmetric algorithms MAY be advertised and selected.

The endpoint and its signing algorithms MUST remain bound to the validated CP issuer.
The CP's UserInfo metadata does not select the Claim Set signing algorithm.

The CP MUST set `authorization_response_iss_parameter_supported` to `true` in its
`openid_provider` metadata as specified in [RFC9207].

The CP MUST support the Authorization Code Flow and PKCE with the `S256` code challenge method
as specified in [RFC7636]. Its `openid_provider` metadata MUST include `code` in
`response_types_supported` and `S256` in `code_challenge_methods_supported`. If the CP also
publishes a configuration document using [OpenID.Discovery], it MUST advertise these
capabilities and support for the authorization response `iss` parameter there as well.

## Claim Set Profile

This specification defines one signed Claim Set profile, identified by the explicit JWT
`typ` in (#signed-claim-set-format). It does not define a new RP capability metadata member
or an Authentication Request parameter to negotiate that type. The OP advertises support
for Aggregated Claims as described below. Deployments MAY establish OP/RP profile support
through configuration, registration arrangements, or a trust framework, consistently with
Section 5.6.2 of [OIDC].

The type requirement applies to Claim Sets issued by this specification's Claims Endpoint;
it does not impose that type on every JWT used for Aggregated Claims under [OIDC]. Within
this profile, the OP and RP MUST apply (#claims-verification) and MUST NOT silently fall
back to accepting an ID Token, UserInfo JWT, or another profile when validation fails.
Existing stored JWTs with `sub` do not conform to this profile. Support for another profile
requires separate validation rules and deployment arrangements outside this specification.

## Aggregating OP Metadata

The OP MUST include `aggregated` in `claim_types_supported` and set `claims_parameter_supported`
to `true` in its `openid_provider` metadata. If the OP also publishes a configuration document
using [OpenID.Discovery], it MUST advertise the same capabilities there. These parameters
describe the OP's capabilities for serving RPs. A CP that only serves Claim Sets to the OP
has no requirement to advertise `aggregated` in that role.

For authorization code responses to RPs, the OP MUST support PKCE with `S256` as specified in
[RFC7636]. It MUST include `S256` in `code_challenge_methods_supported` in its
`openid_provider` metadata and, if published, its [OpenID.Discovery] configuration document.


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

The OP MUST include `policy_uri`, defined in [OpenID.Registration], in its
`openid_relying_party` metadata so the CP can show its privacy policy during Setup.

Claim Set signing algorithms are selected per collection request from the CP's validated
`claims_signing_alg_values_supported`, subject to OP policy. They are not selected using
`userinfo_signed_response_alg`. UserInfo response signing and encryption metadata do not
control the Claims Endpoint. The OP's single Federation RP metadata object therefore
does not need to declare a different Claim Set signing algorithm for each CP.

## OP Client Authentication

The OP MUST act as a confidential client of the CP. The OP and CP MUST support
`private_key_jwt` client authentication as specified in Section 9 of [OIDC]. In the base
profile, the OP MUST set `token_endpoint_auth_method` to `private_key_jwt` in its
`openid_relying_party` metadata and use that method for client authentication.

The OP publishes one `openid_relying_party` metadata object in its Entity Configuration.
Its declared authentication method is therefore common to all CPs using that configuration,
rather than selected separately for each CP. A profile or trust framework MAY instead
require `self_signed_tls_client_auth`, as defined in Section 2.2 of [RFC8705], if it requires
all participating OPs and CPs to support and use that method. In that case, the OP MUST
declare `self_signed_tls_client_auth` as its single `token_endpoint_auth_method` and use it
consistently. mTLS support remains OPTIONAL for base-profile participants; an OP declaring
it cannot assume interoperability with CPs that only support the base method.

The CP MUST advertise `private_key_jwt` and any supported mTLS alternative in
`token_endpoint_auth_methods_supported` in its `openid_provider` metadata and, if published,
its [OpenID.Discovery] configuration document. The OP MUST NOT select `none` or a shared-secret
client authentication method for this profile.

Automatic Registration requests MUST prove possession of the OP's RP keys as required by
Section 12.1.1 of [OpenID.Federation], using a signed Request Object or authenticated PAR.
The OP MUST also authenticate at the CP's Token Endpoint for both authorization code
exchange and refresh token use. For OP clients under this specification, the CP MUST reject
unauthenticated Token Requests and refresh tokens presented by a different client. Other CP
endpoints requiring client authentication MUST use a mutually supported method consistent
with the resolved metadata.
The OP MUST keep each authenticated request bound to the selected CP issuer and its
validated endpoint metadata, including requests to a revocation or PAR endpoint.

For `private_key_jwt`, the OP and CP MUST apply the assertion creation and validation rules
in Section 9 of [OIDC], with the following audience restriction. The assertion's `aud` MUST
contain exactly one value equal to the CP's validated Issuer Identifier, expressed as a
string or a single-element array. The OP MUST obtain that identifier through the issuer
validation in (#discovery-phase), not derive it from an endpoint URI. The CP MUST reject
assertions that do not satisfy this audience restriction. This requirement applies at
every CP endpoint where the OP uses `private_key_jwt`, including the Token, PAR, and
revocation endpoints. It implements Section 2.1.2.1 of [OAuth.Security.Update] in place of
the Token Endpoint audience recommendation in Section 9 of [OIDC].

The CP MUST validate the assertion signature using the OP's resolved `openid_relying_party`
keys and applicable algorithm restrictions. It MUST verify that `iss` and `sub` identify the
OP's `client_id` and that `exp` has not been reached. The OP MUST use a fresh `jti` for each
assertion. Assertions SHOULD have short lifetimes, for example no more than a few minutes.
The OP MUST follow any additional assertion lifetime limits specified by the applicable
profile or trust framework. The CP MUST reject assertion reuse and retain a replay record
for each accepted (`client_id`, `jti`) until the assertion's `exp`, including any clock-skew
allowance under which it could still be accepted.

When `self_signed_tls_client_auth` is used at any endpoint, the CP MUST match the presented
certificate against the certificates published in the OP's resolved RP JWK Set and perform
the certificate and client binding checks in Section 2.2 of [RFC8705]. PAR requests MUST
also satisfy the requirements in Section 12.1.1.2 of [OpenID.Federation].


# Setup Phase

The OP obtains the Subject's authorization to collect claims from each CP it will use. The OP
MUST use the OpenID Connect Authorization Code Flow with `response_type=code` to obtain the grant.
It SHOULD identify the requested claims and collection permissions using scopes supported
by the CP. The grant MUST authorize access to the Claims Endpoint for the requested
claims. This specification does not assign new meaning to `claims.userinfo` or
`claims.id_token` for that resource; mapping claim permissions to scopes is defined by the
CP or an applicable profile or trust framework. UserInfo-only tokens MUST NOT be assumed
to authorize access to the Claims Endpoint. An existing grant without the required
resource permission requires new authorization before collection.
The OP SHOULD limit the requested grant to claims and operations needed for the collection
purposes authorized by the Subject, as described in Section 2.3 of [RFC9700].
It MUST associate the grant and tokens with the authenticated OP account as specified in
(#trust-model).

When requesting a refresh token for offline access, the OP MUST include `offline_access` in
`scope`. The OP and CP MUST follow the consent requirements in Section 11 of [OIDC], including
`prompt=consent` unless other conditions permitting offline access are in place.

The CP MUST show the Subject a dialogue explaining that the OP will obtain signed Claim Sets
to provide claims to RPs at the Subject's direction. The dialogue MUST include a link to the
`policy_uri` in the OP's client metadata. Granting access MUST involve active user interaction.
The dialogue MUST explain that collected Claim Sets may continue to be used or disclosed by
the OP until they expire, including after the CP grant is revoked. It MUST explain that the
Subject controls further disclosure at the OP and must use the OP's controls to stop it, as
described in (#authorization-withdrawal-and-grant-revocation).

## CP Token Issuance and Use

The CP SHOULD issue short-lived access tokens, choosing lifetimes according to the exposure
and sensitivity of the authorized claims. It SHOULD restrict each access token to its
Claim Set resource and the claims and operations authorized by the Subject. The Claim Set
Endpoint MUST verify that a presented token is intended for that resource and permits the
requested access. These restrictions do not require access tokens to use a JWT format.

The OP and CP SHOULD use sender-constrained access tokens, using certificate binding as
specified in Section 3 of [RFC8705] or DPoP as specified in [RFC9449]. When such tokens are
issued, the OP MUST present the applicable proof and the CP's Claims Endpoint MUST verify
the token's binding to that proof before returning claims. Client authentication, token
sender-constraining, and PKCE serve distinct purposes; none replaces the other applicable
checks. mTLS client authentication alone does not imply certificate-bound access tokens.

The CP MUST assess the risk of issuing a refresh token and, if issued, bind it to the OP
client and the Subject-authorized scope and resources as specified in Section 4.14.2 of
[RFC9700]. The CP MUST validate this binding and authenticate the OP on every refresh.
This profile uses confidential clients; it does not require the separate refresh-token
key binding specified for public clients in [RFC9449]. The CP MAY rotate refresh tokens as
an additional replay-detection measure following Section 4.14.2 of [RFC9700]. When the CP
returns a replacement refresh token, the OP MUST replace the old token as specified in
Section 6 of [RFC6749], preserving the account binding in (#trust-model).

The CP SHOULD support token revocation as specified in [RFC7009]. Token expiration,
rotation, and revocation govern further collection; their effect on stored signed Claim
Sets is specified in (#authorization-withdrawal-and-grant-revocation).

## Authorization Request and Transaction Binding

Before starting Setup, the OP MUST authenticate the Subject and create an authorization
transaction bound to that OP account and the initiating user-agent session. The transaction
MUST also identify the selected CP issuer, its resolved metadata, the OP's client registration
at that CP, and the `redirect_uri` used for the request. If the OP supports multiple connection
configurations or tenants for a CP, it MUST bind the selected configuration and tenant to the
transaction as well.

The OP MUST use PKCE with `code_challenge_method=S256` for every Setup request, including when
it acts as a confidential client. Before sending the request, it MUST verify that the validated
CP metadata advertises support for `S256` and abort Setup if that support is absent.
It MUST generate a new, unpredictable `code_verifier` for each transaction as specified in
[RFC7636] and bind it to that transaction. For clients registered to use Claims Aggregation
under (#client-configuration-phase), identified by their `client_id`, the CP MUST reject
authorization requests without an `S256` challenge. The CP MUST validate the corresponding
`code_verifier` before issuing tokens, including the downgrade protection in Section 4.8.2
of [RFC9700].

The OP MUST send an unpredictable, transaction-specific `state` value securely bound to the
transaction and initiating user-agent session. The OP MUST give each transaction a limited
lifetime, accept it at most once, and reject expired transactions. If the OP sends a `nonce`,
it MUST bind it to the transaction and validate the returned ID Token's `nonce` according to [OIDC].

## Authorization Response Session Validation

Before sending an authorization code to a Token Endpoint, the OP MUST validate the returned
`state` against the pending transaction and verify that the user-agent session completing
Setup is bound to the authenticated OP account that initiated it. It MUST abort Setup if
`state` is missing or mismatched, the transaction is expired or already used, or the session
binding cannot be verified. A `state` value or an authorization-session identifier carried
in a URL MUST NOT by itself establish the authenticated OP account or its user-agent session.

If the initiating session is not available at the redirection endpoint, the OP MUST use one
of the following procedures before exchanging the code.

1. The OP stores the received authorization response with its pending transaction and returns
   the user agent to the initiating origin or application with an unpredictable, short-lived,
   one-time handle for that response and transaction. The OP MUST require the original session
   cookie or equivalent session credential held by the initiating application, verify its
   binding to the initiating OP account and transaction, and consume the handle at most once.
   Presentation of the handle alone MUST NOT complete Setup.
   The handle MUST expire no later than the pending transaction and, when the CP's authorization
   code expiration time is known from its policy or deployment configuration, no later than
   that code. If the CP rejects the code as expired, the OP MUST invalidate the handle and
   require a new Setup transaction.
1. The OP reauthenticates the Subject, verifies that the authenticated OP account matches the
   account that initiated the pending transaction, and validates the returned `state` against
   that transaction before completing Setup.

Any further redirection used for this purpose MUST use an OP-controlled destination that an
attacker cannot override.

## Authorization Response Issuer Validation

The CP MUST include the `iss` parameter in authorization responses as specified in [RFC9207].
For each authorization request, the OP MUST store the expected CP Issuer Identifier from the
validated CP metadata and bind it to the authorization transaction and the user-agent session.

On receiving the authorization response, the OP MUST compare the `iss` parameter to the stored
Issuer Identifier as specified in Section 2.4 of [RFC9207]. The OP MUST reject the response if
`iss` is missing or the values differ. The OP MUST perform this check before sending the
authorization code to the Token Endpoint associated with the original request.

## Token Request and Account Binding

The OP MUST use the client registration, `redirect_uri`, and PKCE verifier bound to the
validated transaction for the code exchange. It MUST NOT select a different CP, connection
configuration, tenant, or Token Endpoint based on the received response. After validating the
CP's ID Token according to [OIDC], the OP MUST establish the account binding in (#trust-model)
before using or storing the resulting tokens or Claim Sets for that account.

If the OP has a stored CP subject binding for the OP account and the same CP issuer, it MUST
compare the new CP `sub` with the stored value. If it detects a different CP `sub`, the OP
MUST treat it as account relinking and obtain explicit confirmation from the authenticated
Subject before replacing the binding.

Before establishing a new binding, the OP SHOULD check whether the validated CP (`iss`, `sub`)
is already bound to another OP account within the applicable account namespace, including the
tenant where accounts are tenant-scoped. If such a binding exists, the OP MUST either reject
the new binding or require additional verification under the deployment's account-linking
policy before making the CP's tokens or Claim Sets available to the new OP account. It MUST
NOT automatically transfer or remove the existing binding. Deployments that permit a CP
account to be linked to multiple OP accounts MUST define the conditions for doing so in that
policy.

# Delivery Phase (RP Phase)

In Delivery Phase, the claims are delivered to RP. 
To do so, it typically goes through the following steps: 

1. (Claims Request) The RP sends an OpenID Connect Authentication Request to the OP.
1. (Request Verification) The OP verifies if the request is valid. 
1. (Subject Granting) The OP shows dialogue to the Authenticated Subject if it grants the access to the claims and obtains grant from the Subject. 
1. (Claims Collection) The OP accesses relevant Claims Providers' Claims Endpoints with Access Tokens to collect signed claims
1. (Claims Verification) The RP verifies the received response. 

## Claims Request by RP to OP

The RP MUST use an OpenID Connect Authentication Request as defined in [OIDC]. To request
individual claims, the RP MUST use the standard `claims` parameter with `userinfo`, `id_token`, or both,
as described in Section 5.5 of [OIDC]. The OP MUST support this parameter. The RP can also use
`scope` as defined in [OIDC].

The RP MUST provide `policy_uri` in its client metadata as defined in Section 2 of
[OpenID.Registration]. This specification requires that otherwise optional parameter so the
OP can show the RP's privacy policy to the Subject during authorization.

The OP selects CPs associated with the Subject's account and MUST use the Aggregated Claims format
for claims it returns from those CPs. The RP can apply its own policy to the CP's signed `iss`
when deciding whether to use the claims. The request syntax defined here covers claim names.
Requesting a specific CP requires an extension. The RP applies its own freshness policy as
described in (#local-freshness-policy-and-user-directed-updates).


## RP authentication and the request verification

The OP MUST validate the Authentication Request according to [OIDC], including the
`client_id`, required parameters, and the client metadata registered or resolved for that RP.
When a Request Object is used, the OP MUST also apply the validation requirements in
Section 6.3 of [OIDC], including signature verification when it is signed. A valid signature
does not replace the other request validation requirements.

The OP MUST compare the request's `redirect_uri` with the registered `redirect_uris` using
exact string matching, except for the native application loopback port exception described
in Section 4.1.3 of [RFC9700]. This comparison is required even when the request is signed.
If the `client_id` or `redirect_uri` is missing or invalid, the OP MUST NOT redirect the user
agent to that URI, including to return an error. Other request errors MUST be handled using
the applicable Authentication Error Response in [OIDC].

When an authorization code is issued, the OP MUST bind it to the RP's `client_id`, the
`redirect_uri` used in the Authentication Request, and the PKCE challenge and method, if
present. At the Token Endpoint, it MUST validate the code, its client and redirect URI
bindings, and any client authentication according to Section 3.1.3.2 of [OIDC] and
Sections 4.1.2 and 4.1.3 of [RFC6749], including rejecting expired or previously used codes.

A confidential RP MUST authenticate to the OP's Token Endpoint using the method registered
for its `client_id`. For flows that issue an authorization code, a public RP MUST use PKCE
and a confidential RP SHOULD also use PKCE.
When using PKCE under this specification, the RP MUST use `S256` with a transaction-specific
verifier securely bound to the initiating client and user agent. The OP MUST reject a public
RP's authorization request that would issue a code without an `S256` challenge. For any RP,
the OP MUST reject an authorization request containing `code_challenge` unless
`code_challenge_method` is explicitly `S256`, including when the method is omitted and would
default to `plain` under Section 4.3 of [RFC7636]. When a challenge was supplied, the OP MUST
reject the Token Request unless the verifier matches that challenge. It MUST also reject a
Token Request containing a `code_verifier` if no challenge was present in the corresponding
Authentication Request, as required by Section 4.8.2 of [RFC9700]. Client authentication does
not replace these PKCE checks when PKCE is used.

RPs MUST prevent CSRF and authorization code injection according to Section 2.1 of [RFC9700].
A confidential RP using the OIDC `nonce` alternative to PKCE MUST meet the additional
requirements in Section 4.5.3.2 of [RFC9700], including transaction and user-agent binding
and validation of the `nonce` in the ID Token returned from the Token Endpoint before using
any issued tokens.

## Subject Granting

After verifying the request, the OP MUST authenticate the Subject if necessary and obtain
the Subject's authorization to disclose claims to the requesting RP. It MUST obtain that
RP-specific authorization before initiating a CP authorization request on behalf of that RP
and, in all cases, before disclosing claims, including previously collected Claim Sets.

When obtaining consent, the OP MUST show a dialogue that:

1. Identifies the requesting RP using its `client_id` and, if present, its `client_name` from
   the client metadata registered or resolved for that `client_id`;
1. Identifies the CP source of each claim based on its validated Issuer Identifier, shows
   the claims to be disclosed to that RP, including any additional claims in an embedded
   JWT as described in (#claims-delivery), and indicates that the CP's Issuer Identifier
   and any identifying attributes in that JWT will be disclosed to the RP. The OP-facing
   account reference is not disclosed by this profile;
1. Provides a link to the RP's `policy_uri` from that client metadata; and
1. Obtains the Subject's consent through explicit action.

The OP SHOULD prefer RP identity information verified under the applicable trust framework
when presenting the RP to the Subject. Such information can include `organization_name`
verified through Federation metadata policy or an applicable Trust Mark attesting to that
identity information. Resolving signed metadata or validating a Trust Mark does not by
itself verify every displayed name. The OP MUST NOT present an unverified `client_name` or
other self-asserted identity information as verified. It SHOULD select language-tagged
display values, such as `client_name#ja`, according to the Subject's language preferences,
with fallback as described in Section 2.1 of [OpenID.Registration].

The OP MAY remember a consent decision for the same authenticated Subject and RP
`client_id`, limited to the authorized claims and their CP sources identified by validated
Issuer Identifiers. It MUST NOT skip the dialogue based on consent given to a different RP
or on the CP grant authorizing the OP to collect claims. Remembered consent MUST NOT be
used after withdrawal, for claims outside its authorized scope, or for a different CP
source that the Subject has not authorized. Withdrawal is handled as specified in
(#authorization-withdrawal-and-grant-revocation).

When the RP requests `prompt=consent`, the OP MUST obtain fresh consent through explicit
action. When `prompt=none` is requested, the OP MUST NOT display a dialogue. If valid consent
covering the disclosure to that RP is unavailable, it MUST return `consent_required` as
defined in Section 3.1.2.6 of [OIDC]. Other authentication or interaction requirements are
handled using the applicable errors in that section.

## Claims Collection

The OP MAY collect Claim Sets before an RP requests them if the CP grant and the Subject's
authorization permit it. The OP MAY reuse a stored Claim Set if it still meets the applicable
validity, authorization, and account-binding requirements, including the OP's collection and
storage policies.

The OP SHOULD provide a means for the authenticated Subject to request updated claims from
a selected CP. It MAY perform a new collection using the Subject's existing authorization
and valid CP tokens, or obtain the necessary authorization at the CP as described in
(#setup-phase). The OP MAY apply privacy policies and rate limits to such updates.
Renewing an access token alone does not update a stored Claim Set. The OP MUST preserve the
CP-signed JWT and its `iat` when storing and disclosing it.

For a new collection, the OP SHOULD use an access token with the narrowest scope available for
the claims it needs. If the available access token grants broader access than needed, and a
refresh token and a suitable narrower scope are available, the OP SHOULD request a downscoped
access token using `grant_type=refresh_token` and `scope`, as described in Section 12 of [OIDC]
and Section 6 of [RFC6749]. The requested scope MUST be within the scope of the original grant.
The OP MUST successfully reevaluate trust in the CP before continuing to make requests after
the Trust Chain expires, as specified in Section 12.3 of [OpenID.Federation].

If a new collection is needed and the OP cannot obtain a suitable Claim Set using a valid
access token or a refresh token, it MUST obtain the necessary authorization from the Subject
at the CP or omit the affected claims.

### Token and Claim Set Storage

The OP MUST protect stored CP access tokens, refresh tokens, client authentication and
proof-of-possession private keys, and signed Claim Sets against unauthorized disclosure,
modification, and use. It MUST enforce the account and CP bindings in (#trust-model) when
accessing stored material. These protections MUST cover persistent stores, backups, and
operational access. The OP MUST prevent tokens, private keys, and Claim Sets from being
exposed through logs or diagnostics accessible to unauthorized parties.

The OP SHOULD encrypt sensitive stored material at rest and protect encryption keys
separately from the data. Key isolation and access controls SHOULD limit the impact of a
compromised component. The storage architecture, including the use of Subject-controlled
encryption keys, is an implementation choice. These safeguards do not impose a retention
deadline on Claim Sets or change the Subject's control over their disclosure.

### Subject Control of Stored Claim Sets

The OP MUST provide an authenticated Subject with a user interface to inspect stored Claim
Sets and their CP sources, delete selected stored Claim Sets, and review and withdraw the
OP's collection and RP-specific disclosure authorizations. The interface MUST distinguish
deletion of stored data, stopping further collection, stopping disclosure, and revoking a
grant at the CP. The OP SHOULD direct the Subject to a CP's grant-management interface when
one is available. No new grant-management URL metadata is defined by this specification.

When the Subject requests deletion, the OP MUST remove the selected Claim Sets from its
active stores and MUST NOT disclose retained copies of those deleted Claim Sets. The OP
MUST explain the scope and timing of deletion, including any backup retention, and that
deletion at the OP does not erase copies already delivered to RPs. Before returning backup
data to active use, the OP MUST apply the Subject's recorded deletion and withdrawal
decisions so that restoration does not silently reactivate deleted data or withdrawn
permissions. Retained backups remain subject to (#token-and-claim-set-storage).

Deletion alone does not withdraw collection authorization; a new authorized collection can
obtain the claims again. The OP MUST make that distinction clear and allow the Subject to
stop further collection as specified in (#authorization-withdrawal-and-grant-revocation).
Withdrawal of disclosure authorization stops the corresponding disclosure, independently
of whether the Subject retains a private copy. Revoking the CP grant governs further CP
access, not the validity of previously issued Claim Sets.

The OP SHOULD NOT automatically recollect claims deleted by the Subject from the same CP
without a subsequent explicit instruction from the Subject to collect those claims again.
An RP request or previously remembered disclosure consent does not by itself constitute
such an instruction. The OP SHOULD offer a single operation to delete selected Claim Sets
and withdraw the corresponding collection authorization. Withdrawal through that operation
is subject to (#authorization-withdrawal-and-grant-revocation).

The OP SHOULD let the authenticated Subject review disclosure history identifying which
RPs received which Claim Sets, their CP sources, and when disclosure occurred. Any retained
history MUST be protected according to (#token-and-claim-set-storage) and subject to the
Subject's deletion and backup-restoration controls described above, subject to applicable
legal retention obligations. Records retained solely to meet those obligations MUST be
excluded from ordinary viewing and disclosure flows and remain subject to the same storage
protections. Access to those records MUST be restricted to authorized purposes for meeting
those obligations. The OP SHOULD minimize the information retained for that history rather
than retain complete signed JWTs solely to provide it.

The OP MAY let the authenticated Subject export their stored CP-signed Claim Sets without
altering the signed JWTs. Such export does not change their audience, account-binding, or
verification requirements. The OP SHOULD explain that exported artifacts remain
transferable signed personal data with the correlation and onward-transfer risks described
in (#correlation-and-transferable-signed-data).

This specification does not impose a retention deadline on the Subject's stored Claim
Sets. A Subject can choose to retain an expired Claim Set as a record; its retention does
not permit accepting or disclosing it as valid after `exp`. The validation requirements in
(#claims-verification) continue to apply. Storage and encryption architecture, including
Subject-controlled archival keys, remain implementation choices.

### Authorization Withdrawal and Grant Revocation

The OP MUST preserve the association of stored Claim Sets with the authenticated OP account
and the CP identifiers established in (#trust-model). Further collection from the CP is
governed by the OAuth grant and token validity requirements of [RFC6749] and [RFC6750].
Token revocation, when supported, follows [RFC7009]. The OP MUST handle token errors through
the applicable recovery or reauthorization procedure when further collection is needed.

Expiration or revocation of a CP access token, refresh token, or grant does not by itself
invalidate previously collected signed Claim Sets. The OP MAY continue to disclose a stored
Claim Set under the Subject's authorization if it satisfies the applicable signature,
expiration, account-binding, and trust-policy requirements. The RP applies its own acceptance
and freshness policies to that Claim Set. Obtaining fresh CP authorization or successfully
calling the CP again is not a prerequisite for such use.

If the Subject withdraws authorization for collection or disclosure at the OP, the OP MUST
stop the corresponding collection or disclosure until the Subject authorizes it again.
Withdrawal limited to a particular RP MUST stop disclosure of affected Claim Sets to that
RP, according to the scope of the withdrawal.

The `invalid_token` error in [RFC6750] can indicate expiration, revocation, or other failure,
and the `invalid_grant` error in [RFC6749] can also have several causes. Neither error alone
establishes the scope of a revocation or the validity of a stored Claim Set. A failed
collection or refresh attempt does not by itself require suspension of disclosure of an
otherwise acceptable stored Claim Set.


### Claims Endpoint Request

The OP MUST send an HTTPS POST request to the CP's validated `claims_endpoint`, with
`Content-Type: application/json` and an access token authorized for that resource. For a
bearer token, it MUST follow [RFC6750]. For a DPoP-bound token, it MUST use the authorization
scheme and proof in Section 7 of [RFC9449]. For a certificate-bound token, it MUST present
the certificate as specified in [RFC8705]. The CP MUST validate token validity, resource,
permissions, and any sender binding before issuing a Claim Set.

The request body MUST be a JSON object with these members:

`nonce`
: **Required**. A non-empty, unpredictable, operation-specific string generated by the OP. Before
  sending the request, the OP MUST bind it to a pending collection operation, the OP account,
  and the CP issuer and Subject Identifier established during Setup. It MUST NOT reuse the
  RP's authentication nonce or use this value as evidence of Subject identity. The OP MUST
  limit each operation's lifetime and reject responses for expired or completed operations.

`claims`
: **Required**. A non-empty JSON object whose member names identify the top-level claims
  requested and whose values MUST be `null` in this base profile. Claim-specific query
  syntax requires an extension. This member does not expand the grant's permissions.
  `iss`, `sub`, `aud`, `iat`, `exp`, `nbf`, and `jti` MUST NOT be requested as attribute names.

`signing_alg`
: **Required**. A single asymmetric JWS algorithm selected from the CP's validated
  `claims_signing_alg_values_supported` and permitted by OP policy. The OP MUST bind this
  selection to the pending operation. The CP MUST reject a selection it does not support.

For example (the access token and nonce are illustrative):

```http
POST /claims HTTP/1.1
Host: cp.example
Authorization: Bearer ACCESS_TOKEN
Content-Type: application/json

{
  "nonce": "request-specific-random-value",
  "claims": {"birthdate": null},
  "signing_alg": "RS256"
}
```

The CP MUST limit returned attributes to those requested and authorized by the grant and
Subject. It MAY omit requested attributes, including for privacy reasons. Omission is not
an error and MUST NOT imply a particular reason such as absence, lack of verification, or
withholding by the Subject. An unknown requested attribute name MUST NOT by itself make an
otherwise valid request malformed. If no requested attributes are supplied, the CP MUST
return the empty result defined in (#claims-endpoint-response), rather than issue a JWT
containing only protocol claims.

Malformed or unsupported requests, such as invalid request structure or an unsupported
`signing_alg`, MUST receive HTTP 400 with `Content-Type: application/json` and a JSON object
containing `"error": "invalid_request"`. This JSON error object MAY include
`error_description` as a human-readable string. Error responses MUST NOT disclose the
account reference, claim values, or sensitive reasons for withholding particular attributes.
Token and scope errors MUST use the applicable status and `WWW-Authenticate` response from
Section 3 of [RFC6750] or the applicable error rules of [RFC9449]; the endpoint's JSON
request errors do not replace those authentication challenges.

The OP repeats collection for each CP as necessary.

### Claims Endpoint Response

A successful response MUST use HTTP 200, `Content-Type: application/json`, and
`Cache-Control: no-store`. Its body MUST be a JSON object with these members:

`account_ref`
: **Required when `claim_set` is present; otherwise MUST be omitted**. A non-empty string
  containing the CP Subject Identifier for the account authorized by the access token,
  using the same identifier as the CP ID Token issued to this OP during Setup. The CP MUST
  derive it from the token's authorized account, not echo a caller-supplied account reference.

`nonce`
: **Required**. The exact `nonce` from the request associated with this response.

`claim_set`
: **Required when one or more requested attributes are supplied; otherwise MUST be omitted**.
  A non-empty string containing the CP-signed JWT defined in (#signed-claim-set-format).
  The CP MUST ensure that its attributes concern the account identified by `account_ref`.
  `null`, an empty string, or a JWT containing only protocol claims MUST NOT represent an
  empty result.

For example (the compact JWS is abbreviated):

```json
{
  "account_ref": "cp-sub-7f39",
  "nonce": "request-specific-random-value",
  "claim_set": "<CP-signed-JWT>"
}
```

If no requested attributes are supplied, the CP returns HTTP 200 with the same content
type and cache directive, echoing only the operation nonce:

```json
{
  "nonce": "request-specific-random-value"
}
```

This empty result reports only that this collection supplied no attributes. It does not
assert that the attributes do not exist or explain why they were not supplied.

An illustrative decoded protected header and payload of a returned `claim_set` are:

```json
{"typ":"claims-aggregation+jwt","alg":"RS256","kid":"cp-app-key-1"}
```

```json
{
  "iss": "https://cp.example",
  "aud": "https://op.example",
  "iat": 1794960000,
  "exp": 1795046400,
  "birthdate": "1990-01-01"
}
```

The example uses the common mandatory-to-implement algorithm `RS256`.
The timestamps start at 2026-11-18T00:00:00Z. The response's cache directive prevents HTTP
caching; it does not prohibit Subject-authorized storage under (#claims-collection).

The OP MUST reject a purported successful response unless it has the required status,
media type, and JSON members with the types specified above. It MUST NOT interpret an
error response, including a body containing `error`, as a successful result or an empty result.

Before accepting the response, the OP MUST:

1. Match `nonce` to the pending operation and accept that operation's response at most once.
   Retries or delayed responses MUST NOT bind a completed operation to a new account or
   operation. The CP echoes the nonce; it need not maintain a global used-nonce database.
1. If `claim_set` is absent, require `account_ref` to be absent and process the response as
   an empty result. No new Claim Set or account binding is established, and the remaining
   Claim Set validation and storage steps below do not apply. The OP MUST NOT create or
   change an account binding from that result, store or disclose it as a Claim Set, or
   infer attribute absence, grant revocation, or Subject withdrawal from it. An empty
   result alone MUST NOT invalidate or suspend use of a previously stored Claim Set that
   still satisfies all applicable validation and authorization requirements.
1. If `claim_set` is present, match `account_ref` exactly to the CP `sub` from the validated
   Setup ID Token stored for that operation's OP account and CP issuer. It MUST NOT derive
   or replace that expected identifier from the new response or access token. A mismatch MUST fail collection;
   account relinking requires the procedure in (#token-request-and-account-binding).
1. Validate `claim_set` under (#claims-verification), including matching its `iss` to the
   operation's CP issuer and its `alg` to the selected `signing_alg`. It MUST verify that
   at least one requested attribute is present and every returned attribute was requested
   and authorized.
1. Process the authenticated response, its account reference, and the actual JWT as one
   validation unit. It MUST NOT recombine them through an unprotected queue or cache.

If any response validation above fails, including an unrequested or unauthorized returned
attribute, the OP MUST reject the entire response and MUST NOT store or disclose its Claim
Set. Omitting a claim from `_claim_names` cannot hide it from an RP receiving the JWT.
For these checks, attributes exclude the JWT protocol claims `iss`, `aud`, `iat`, `exp`,
`nbf`, and `jti`, whose validation is governed by (#claims-verification).

For a response containing a valid Claim Set, the OP MUST preserve a protected record binding
the actual JWT to the OP account, CP issuer, CP Subject Identifier, and the acquisition
validation result and time. Protection MUST cover both record integrity and association
with the correct JWT. A hash stored alongside
unprotected data does not by itself provide that protection. A deployment crossing an
untrusted processing or storage boundary needs integrity protection across that boundary.
For example, an authenticated storage service can enforce this association, or a MAC or
signature can protect a record covering both the JWT and binding fields when the storage
itself is not trusted. An additional CP-signed receipt can be defined by a profile where
independent evidence of acquisition is needed.

Before redisclosure, the OP MUST validate that protected binding record, the Claim Set
under (#claims-verification), and the current authorization, deletion, and withdrawal state.
A successful acquisition does not waive later key, trust, expiration, or freshness checks.
Reusing a stored Claim Set does not require a new CP operation nonce or CP contact.
The OP MUST NOT disclose the acquisition envelope, `account_ref`, or operation `nonce` to
the RP as part of the Aggregated Claim Set.

## Claims Delivery

The OP creates the Aggregated Claims response as described in Section 5.6.2 of [OIDC]. The RP
receives the entire signed JWT embedded in `_claim_sources`, including claims that are not listed
in `_claim_names`. The OP MUST ensure that every claim it discloses in the embedded JWT is
authorized for disclosure to that RP. If a Claim Set includes claims the OP cannot disclose,
the OP MUST obtain a suitable Claim Set from the CP or omit that JWT from the response.

For example, the payload of an OP ID Token can contain the following (the inner JWS is
abbreviated, and normal ID Token requirements still apply):

```json
{
  "iss": "https://op.example",
  "sub": "op-pairwise-sub-for-this-rp",
  "aud": "rp-client-id",
  "iat": 1794960000,
  "exp": 1794960300,
  "_claim_names": {"birthdate": "cp1"},
  "_claim_sources": {"cp1": {"JWT": "<CP-signed-JWT>"}}
}
```

The enclosing `sub` identifies the Subject at the OP. The CP's `account_ref` and acquisition
nonce are not included in the embedded JWT or passed on as acquisition evidence to the RP.

The OP SHOULD return Aggregated Claims in an ID Token obtained from the Token Endpoint or
in a UserInfo response rather than in an ID Token returned from the Authorization Endpoint.
This reduces exposure of the embedded CP-signed personal data through the browser and
front-channel response handling, as discussed in (#rp-request-integrity-and-broker-side-consent).

## Claims Verification

The OP MUST obtain Claim Sets from the CP's Claims Endpoint and MUST NOT substitute a
Setup or refreshed ID Token or a UserInfo JWT. It MUST validate each CP-signed Claim Set when
collecting it and before disclosing a stored Claim Set. The RP MUST validate the OP's enclosing ID Token or
UserInfo response according to [OIDC] and validate each embedded CP-signed JWT before accepting its claims.
Both verifiers MUST apply the signature and claim validation rules below.

### CP Metadata and Verification Keys

The verifier MUST obtain the CP's metadata and signature verification keys through one of
the following mechanisms, subject to its trust policy for the CP.

1. Use [OpenID.Discovery] to retrieve the CP's configuration, validate its `issuer` according
   to Section 4.3 of that specification, and retrieve the public keys from its `jwks_uri`.
1. Resolve and validate a Trust Chain for the CP using [OpenID.Federation], then obtain its
   application signing keys from the resolved `openid_provider` metadata using Section 5.2.1
   of that specification. Federation Entity Keys MUST NOT be substituted for the CP's
   application signing keys.
1. Use metadata and public keys provisioned for that CP issuer by a trusted deployment
   configuration or trust framework.

The CP issuer in the validated metadata or trusted configuration MUST exactly match the
JWT's `iss`. An unverified `iss` MAY be used as input to key resolution only as permitted by
the verifier's issuer acceptance and network access policies. Metadata and keys MUST remain
associated with that issuer, including when cached, and MUST satisfy the applicable validity
and trust reevaluation requirements. Successful discovery of a key or verification of a
signature MUST NOT by itself establish that the CP is trusted to issue the requested claims.

If a signing key is unavailable or no longer trusted under the applicable key policy, the
verifier MUST NOT accept the Claim Set on the basis of an earlier successful validation.
The OP MUST obtain a replacement Claim Set from the CP or omit the affected Claim Set, as
specified in (#claims-collection) and (#claims-delivery).

### Signature Validation

The verifier MUST require an asymmetrically signed JWS and reject an unsecured JWT, `alg=none`,
or a symmetric MAC algorithm. It MUST establish an allowed set of algorithms from its local
policy and the CP's validated `claims_signing_alg_values_supported` metadata before
verifying the signature. The JWT's `alg` MUST be in both sets. At acquisition, the OP MUST
also verify that `alg` equals the `signing_alg` bound to the collection operation.

The verifier MUST verify the signature according to [JWS] using a public key associated with
the validated CP issuer. Key selection MUST respect the key type, signing use, and algorithm
restrictions. A `kid`, if present, MUST select a suitable key only within that CP's trusted
key set. The JWT header MUST NOT independently establish a trusted key source or override the
allowed algorithms. The algorithm used in the cryptographic operation MUST match `alg`, and
the verifier MUST bind each public key to one algorithm using its JWK `alg` parameter or
issuer-specific trusted configuration, as required by Section 3.1 of [RFC8725]. If the JWK
includes `alg`, the verifier MUST check that it matches the JWT's `alg`. If the verifier
cannot establish the key's algorithm binding, it MUST reject the Claim Set.

### Claim Validation

After verifying the signature, the verifier MUST perform the following checks.

1. Require protected-header `typ` to equal `claims-aggregation+jwt` and reject a payload
   containing `sub`. Require `iss`, `aud`, `iat`, and `exp`; `iss` MUST be a non-empty string.
   The issuer MUST be the CP whose metadata and keys were validated. The OP MUST match the
   issuer and validate the acquisition or stored binding record under (#trust-model) and
   (#claims-endpoint-response).
   The RP MUST apply its trust policy to decide whether that CP is trusted for the claims.
   The RP relies on the OP for the subject binding described in (#trust-model).
1. Require exactly one `aud` value, expressed as a string or a single-element array of strings.
   The OP MUST compare it with its own `client_id` at the CP. The RP MUST compare it with the
   Issuer Identifier of the OP used for the OpenID Connect transaction. The RP MUST use the
   Issuer Identifier established during OpenID Connect validation. For Aggregated Claims in
   a UserInfo response, it MUST use the validated OP issuer retained from the OpenID Connect
   transaction that issued the access token, not infer a new issuer from the CP JWT or an
   unsigned UserInfo body. It MUST preserve that issuer-to-token association.
   The verifier MUST compare these strings without normalization as specified in Section 14
   of [OIDC].
1. Require `iat` and `exp` to be NumericDate values, with `exp` later than `iat`. The verifier
   MUST reject a JWT whose `iat` is in the future or whose `exp` has been reached. It MAY
   allow a small leeway for clock skew. If `nbf` is present, it MUST also validate that claim
   according to Section 4.1.5 of [JWT], with the same clock-skew allowance.

The RP MUST also verify the `_claim_names` and `_claim_sources` structure according to
Section 5.6.2 of [OIDC], including that each referenced JWT contains the claims mapped to it,
and apply the validation rules for each claim it uses.

If any required check fails, the OP MUST reject the invalid Claim Set and MUST NOT store or
disclose it. The RP MUST NOT use any claims from an invalid Claim Set and MUST treat the
claims mapped to it by `_claim_names` as unavailable. The RP MAY reject the entire enclosing
response. If it continues processing, it MUST independently validate the enclosing OP response
and every other Claim Set it uses, and enforce its application's required-claim policy before
completing the requested operation. Profiles MAY require rejection of the entire response.

### Local Freshness Policy and User-Directed Updates

The RP MUST apply its application's freshness requirements before using claims. It MAY
enforce a maximum acceptable JWT age based on the CP-signed `iat`, in addition to checking
`exp`. If a Claim Set is too old for the intended use, the RP MUST treat its claims as
unavailable for that use and enforce its required-claim policy.

The RP SHOULD explain to the Subject when updated information is needed. It MAY direct the
Subject to the OP's claim-management interface to request an update, after which the Subject
can retry the RP interaction using the existing OpenID Connect flow. Retrying authentication
alone does not require the OP to recollect CP claims. The RP MUST validate the returned
Claim Sets and apply its freshness policy again after an update.

Applications requiring constraints on the age of identity verification or evidence can use
the existing request and validation mechanisms in [OpenID4IDA] with supporting providers.
For example, the `max_age` query member in Section 5.5.2 constrains `verification.time` or
another requested date or timestamp. When using these constraints, the RP MUST evaluate the
returned verification or evidence timestamps against its requirements according to the
query semantics in [OpenID4IDA], separately from the JWT's `iat`.

Under this specification, the OP MAY reflect supported `verified_claims` constraints,
including `max_age`, in requests to a CP, or use them to select stored Claim Sets. Neither
forwarding those constraints nor filtering stored Claim Sets against them is required by
this specification. The RP MUST perform its acceptance checks after receipt regardless of
whether the OP performs either operation. An OP that separately implements [OpenID4IDA]
remains subject to that specification's applicable OP requirements. Its external assertion
format in Section 6.1 requires `sub` and prohibits `aud` and `exp`; that format is not the
signed Claim Set profile defined here. A CP can supply supported
`verified_claims` data in this profile, but that alone does not establish conformance to
that external assertion format. Mapping its request constraints into this endpoint requires
an extension; the base `claims` object accepts only `null` values. The OP MUST NOT rewrite
an existing signed assertion to convert it to this profile.


# Security Considerations

The security considerations of [OIDC], [OpenID.Federation], and [RFC8725] apply.

The algorithm in a JWT header is untrusted until signature verification succeeds. The rules
in (#signature-validation) prevent a token from selecting an algorithm outside the verifier's
policy or causing a CP public key to be used as an HMAC secret. Issuer-specific key resolution
in (#cp-metadata-and-verification-keys) preserves the binding between a CP and its signing keys.

The CP SHOULD choose Claim Set lifetimes according to the sensitivity and expected rate of
change of the claims, the intended period of pre-collection and storage, and its ability to
retain verification keys. Short lifetimes require more frequent collection, while long
lifetimes extend the period during which previously issued attributes can be presented.
Expiration limits the lifetime of the signed artifact. It does not guarantee that the
underlying attributes remain current or that the CP's grant remains authorized. Key withdrawal
can make a stored Claim Set unusable before its `exp`, as described in
(#cp-metadata-and-verification-keys).

The explicit type and absence of `sub` in (#signed-claim-set-format) provide validation
rules distinct from ID Tokens and UserInfo JWTs, as recommended by Section 3.12 of [RFC8725].
Calling a different URL alone does not prevent cross-JWT confusion. Verifiers still check
the type, issuer, audience, signature, and remaining claims, and do not fall back to an old
profile when those checks fail. The presence or absence of `nonce` or `auth_time` alone
does not establish a JWT's purpose.

Section 4.4 of [RFC9700] describes mix-up attacks. The check in
(#authorization-response-issuer-validation) allows an OP that uses multiple CPs to detect an
issuer mismatch before sending an authorization code to a Token Endpoint.

## Setup Transaction and Session Integrity

The Setup requirements in (#authorization-request-and-transaction-binding),
(#authorization-response-session-validation), (#authorization-response-issuer-validation),
and (#token-request-and-account-binding) protect the OP's connections to multiple CPs.
Authorization Code Flow, issuer-bound metadata resolution with valid caching, and RFC 9207 validation implement
the issuer-based countermeasure for connection confusion described in Section 2.2.2 of
[OAuth.Security.Update]. The OP also preserves the selected client registration and any
connection or tenant context throughout the transaction.

PKCE binds an authorization code to the OP's token request. An attacker can still initiate
Setup for the attacker's OP account and induce a victim to authorize access to the victim's CP
account. PKCE alone does not detect this cross-user session fixation attack, described in
Section 2.3 of [OAuth.Security.Update], with countermeasures in Section 2.3.2. Before
exchanging the code, the OP verifies the completion session's binding to the initiating
authenticated OP account. A valid `state` received through a URL is insufficient without this
session validation. Comparing a previously stored CP subject identifier detects account
changes. Checking for the same CP (`iss`, `sub`) on another OP account can also detect an
attempted new binding when that CP identity is already known to the OP. Neither check
establishes a relationship for a CP identity that has never been linked at the OP. The L1
trust assumptions in (#trust-model) continue to apply.

## RP Request Integrity and Broker-Side Consent

The requirements in (#rp-authentication-and-the-request-verification) apply to signed and
unsigned requests. Request signatures do not replace redirect URI validation, authorization
code binding, or the applicable Token Endpoint authentication and PKCE checks. PKCE proves
possession of a transaction-specific verifier; it is not client authentication.

The OP acts as the broker between downstream RPs and upstream CPs in the topology described
in Section 2.4 of [OAuth.Security.Update]. This specification uses the broker-side consent
screen countermeasure in Section 2.4.2.2 rather than registering every RP as a separate
client at every CP. The Subject's authorization at the OP in (#subject-granting) identifies
the RP and controls disclosure to it. The CP's grant authorizes collection by the OP; it
does not authorize disclosure to any particular RP. The RP-specific authorization
requirements apply equally when the OP reuses that collection grant or a stored Claim Set.

This choice permits collection independently of RP activity without requiring the CP to
learn which RP receives the claims. For an RP-triggered CP authorization request, the OP
obtains the necessary RP-specific authorization first. For pre-collected Claim Sets, the
OP enforces that authorization before disclosure. The withdrawal requirements in
(#authorization-withdrawal-and-grant-revocation) also apply when the OP has remembered
consent or the CP grant remains valid.

An ID Token returned from the Authorization Endpoint can expose embedded CP-signed Claim
Sets to browser scripts and front-channel response handling. Depending on the response
mode and implementation, those artifacts can persist in URLs, including fragments, browser
history, or application and diagnostic logs. Unlike an authorization code, the signed
personal data can be copied and presented to other parties, subject to their acceptance
checks. The back-channel delivery recommendation in (#claims-delivery) reduces this
exposure; it does not prevent an RP that receives a Claim Set from copying it. This is an
additional reason to minimize front-channel exposure alongside the leakage risks discussed
in Sections 4.2 and 4.3 of [RFC9700].

## Audience Binding

The RP uses the OP's Issuer Identifier to check the audience of each Claim Set. This check relies on
the CP binding that `client_id` to the correct client. The CP MUST establish the client as specified
in (#client-configuration-phase) before issuing a signed Claim Set for Claims Aggregation.
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

## Acquisition Response Integrity

The collection nonce correlates an authenticated CP response with a pending OP operation;
it is not an access credential or an issuance-idempotency key. The CP may process a retried
request more than once, but the OP accepts at most one response for its pending operation.
A holder of a stolen bearer token can request additional Claim Sets with new nonces, so a
CP nonce database would not prevent that use. TLS server authentication and the token
protections in (#cp-token-issuance-and-use) address that threat. The OP MUST validate the
CP endpoint's TLS server identity. Deployments can impose issuance rate limits without
making every CP maintain a shared nonce-replay database.

The OP binds the selected signing algorithm to the operation before sending the request
and checks the returned JWT against it. A request or response that traverses an untrusted
internal processing boundary needs integrity protection across that boundary as described
in (#claims-endpoint-response); token sender-constraining alone does not authenticate
arbitrary JSON request or response bodies across such a boundary.

## CP Credential Exposure and Claim Set Replay

Pre-collection permits an OP to hold a grant that covers future Subject-authorized uses
beyond a single RP request. The least-privilege requirements in (#setup-phase) and
(#claims-collection) limit requested access. Downscoping an access token does not by itself
reduce the authority of the original refresh token. The protections in
(#cp-token-issuance-and-use) and (#token-and-claim-set-storage) address the resulting
concentration of credentials and personal data at the OP.

The assertion audience restriction in (#op-client-authentication) implements the preferred
audience-injection countermeasure in Section 2.1.2.1 of [OAuth.Security.Update]. The OP's
Entity Identifier is its `client_id` at every CP, so uniqueness of client identifiers
across CPs is not an available countermeasure. Using different authentication keys for
different CPs can provide additional isolation only when each CP's accepted key set is
also restricted accordingly. Publishing several keys in a common RP key set does not by
itself establish that isolation.

The single Entity Configuration also limits how client authentication represents device
instances. In this profile, the client authentication keys are managed by the OP Entity,
and an on-device application acts as that Entity's user interface or agent. The CP resolves
one client identity and one RP metadata object for the OP's Entity Identifier; this
specification does not define a separate enrollment or authentication binding for each
device instance. Distributing the same authentication private key to all devices expands
the risk of key extraction. Listing every device key in the common RP JWK Set can cause
unbounded growth and expose device population and churn, without establishing separate
client identities at the CP.

Confidential-client status does not require server-side execution. Device-generated keys
and instance-specific registration can support secure client authentication, but combining
them with this profile's common Entity Identifier, OP issuer, and RP metadata requires a
separate profile. Such a profile could define per-instance Explicit Registration or Dynamic
Client Registration, or an Entity-backed client-attestation mechanism for instance keys
while retaining the Entity Identifier as `client_id`. It would need to define the binding
between each instance, its credentials, `client_id`, and the OP issuer, and the
authentication-method selection rules. Giving an instance a different `client_id` while
retaining a common OP issuer would change the identity relationship required by this base
profile. These instance profiles are outside the scope of this specification.

Client authentication and sender-constrained CP access tokens protect collection, not the
subsequent presentation of a signed Claim Set. A Claim Set's audience identifies the OP,
not an individual RP or presentation. An RP or another holder can copy that JWT and send
it elsewhere. Acceptance depends on the recipient's enclosing-response validation,
account-binding trust, and Claim Set verification rules in (#claims-verification); possession
of the embedded JWT alone does not authenticate the Subject. Short Claim Set lifetimes
limit the exposure period but do not prevent copying or reuse before expiration.

The L1 model therefore continues to rely on the OP's account binding and disclosure
controls. These protections neither require per-presentation CP contact nor cause CP grant
revocation to invalidate stored Claim Sets. Storage remains under the Subject's control
within the limits described in (#freshness-and-revocation-limits).

## Freshness and Revocation Limits

The signed `iat` establishes the age of the JWT. An OP collection timestamp or the enclosing
ID Token's `iat` MUST NOT replace it in freshness checks. A CP can issue a new JWT containing
attributes verified earlier. Applications needing freshness of identity verification or
evidence can use the corresponding signed data and validation rules in [OpenID4IDA], as
described in (#local-freshness-policy-and-user-directed-updates).

This specification treats a signed Claim Set held by the OP as an artifact under the
Subject's control. A CP's revocation of the OP's OAuth grant, including unilateral revocation,
cannot thereby prevent the Subject from continuing to present previously issued Claim Sets
until they expire, subject to the validation and acceptance requirements of this specification.
The Subject controls further disclosure at the OP as described in
(#authorization-withdrawal-and-grant-revocation). This protection is bounded by the `exp`
chosen by the CP, which can issue Claim Sets with short lifetimes. Within this model,
legitimate changes requiring prompt invalidation, such as revocation of a driver's license,
are handled through short lifetimes or a separate authenticated status mechanism for the
issued Claim Set. OAuth grant revocation alone does not provide that mechanism.

OAuth token and grant revocation controls further access to the CP. It does not by itself
invalidate signed Claim Sets already held by the OP or delivered to RPs, as described in
(#authorization-withdrawal-and-grant-revocation). Offline verification establishes the
properties of the signed artifact; it cannot establish that the underlying attributes have
remained unchanged since issuance. Deployments requiring a current status check on an issued
Claim Set need a separate authenticated status mechanism and acceptance policy. Such a check
concerns the issued Claim Set's status, independently of the OAuth collection grant. Short
JWT lifetimes and RP acceptance policies limit the age of artifacts accepted offline.

# Privacy Considerations

## OP Visibility and Reliance on Subject Instructions

The OP processes the contents of Claim Sets from CPs and knows which RPs receive them. This
combination can reveal attributes and relationships across services. In a deployment where
a third party operates the OP and can access that processing or its records, the Subject
places substantial trust in that operator. Encryption at rest protects stored data against
some compromises; it does not by itself hide data from the OP while processing it. A
distributed-claims deployment does not necessarily hide information from the OP either;
visibility depends on which components actually obtain and process the data.

At Setup, the Subject authorizes the CP to release claims to the OP for future use under
the Subject's direction. The CP relies on the OP to enforce the later RP-specific
authorization in (#subject-granting). A CP signature authenticates the issued data; it does
not prove that the OP obtained authorization for a particular disclosure. Federation trust
and policy information can inform a trust decision, but do not by themselves prove that
the OP honored the Subject's instructions in an individual transaction.

The least-privilege and disclosure requirements in (#setup-phase), (#claims-collection),
and (#claims-delivery) limit what the OP obtains and discloses. In particular, the RP
receives all claims in an embedded signed JWT, including claims not listed in
`_claim_names`. The OP cannot remove individual claims from that JWT while preserving the
CP's signature. A deployment seeking stronger limits on OP visibility or finer-grained
disclosure needs an appropriate architecture or extension, rather than relying on storage
encryption alone.

## Correlation and Transferable Signed Data

The CP's stable Subject Identifier is used for OP-facing account binding and is not
included in this profile's RP-facing JWT. Pairwise identifiers at the CP would otherwise
be scoped to the OP's Sector Identifier rather than to each downstream RP, as specified
in Section 8.1 of [OIDC]. Omitting the CP `sub` removes that direct downstream identifier;
it does not guarantee unlinkability. Authorized identifying attributes can still correlate
Subjects, and a CP can recognize information it issued when an RP shares it.
The OP's pairwise identifiers in enclosing responses do not hide the inner JWT's contents.

Reusing the same CP-signed JWT across presentations allows recipients that compare their
received JWTs to correlate those presentations, including across colluding RPs. The JWT
itself, including its signature, provides a common value for comparison even when identifiers
used elsewhere are ephemeral or pairwise. Obtaining a newly issued JWT does not necessarily
prevent correlation if it contains stable identifiers or identifying combinations of claims.

An RP can also pass a CP-signed JWT to a third party that can independently verify the CP's
signature and the signed contents. This makes disclosure of signed personal data more
consequential than disclosure of an unauthenticated assertion. The signature is evidence of
what the CP issued, not proof that the Subject presented it to a particular RP or that the
attributes remain current. The base format does not cryptographically prevent onward
transfer. The Subject's controls at the OP cannot recover copies already held by RPs.

Selective disclosure can reduce the attributes revealed to a recipient, but does not by
itself ensure unlinkability. For example, Section 10.1 of [SD-JWT] explains that recipients
can correlate reuse of an issuer-signed credential and that colluding issuers and verifiers
can recognize the same credential. SD-JWT is an example for future profiles, not a format
introduced by this specification. Such profiles would need compatible subject-binding,
audience, consent, and verification rules.

## Pre-Collection, Batch Issuance, and On-Demand Issuance

Pre-collection and reuse of stored Claim Sets can reduce the CP's visibility into the timing
of the Subject's interactions with RPs. Updating claims in response to an RP's request for
fresher information can trigger CP Claims Endpoint calls whose timing and frequency may be
correlated with downstream activity. The OP SHOULD explain both the correlation risk of
reusing a JWT and the CP timing-visibility risk of obtaining updates when obtaining the
Subject's authorization for collection and disclosure. The Subject can then choose whether
to authorize reuse or request an update, subject to the RP's acceptance policy. The OP MAY
use privacy policies and rate limits when servicing user-directed updates.

This avoids requiring a Claims Endpoint call for each presentation; it does not guarantee that
the CP learns nothing about RP use. RP-CP information sharing and retrieval of metadata,
verification keys, or status information can create other observation paths. Valid metadata
and key caches tied to the issuer can reduce some such contact, subject to the requirements
in (#cp-metadata-and-verification-keys).

An alternative design can pre-issue a batch of distinct credentials for one-time use,
combining advance collection with avoidance of a common reused artifact. This introduces
inventory and replenishment requirements. Section 10.1 of [SD-JWT] describes batch issuance
for presentation and verifier-verifier unlinkability, including the need to avoid other
common identifiers and timing values. It does not solve issuer-verifier collusion.

With this profile, the Subject can instead request a newly issued Claim Set for a use,
without a CP `sub` in the presented JWT. This avoids maintaining a stock of unused
credentials, but requires CP availability and continued willingness to issue, and exposes
issuance timing to the CP. It does not require revealing the RP's identity to the CP.
Stable attributes, identifying combinations of values, and distinctive timestamps can still
link separately issued JWTs. Wrapping the same inner JWT in different OP responses does not
hide its common contents or signature from recipients who compare them.

The stable account-binding identifier remains in the OP-facing acquisition envelope. The
OP validates it against the Setup ID Token, then discloses only the inner JWT. The new
endpoint avoids changing UserInfo's requirement that its `sub` match the ID Token `sub`.
Using a refreshed ID Token itself would not provide that separation: Section 12.2 of [OIDC]
requires its issuer, subject, and audience to remain those of the original ID Token.

This specification introduces no batch issuance protocol and does not require a newly
issued JWT per presentation. Reuse of stored Claim Sets and user-directed updates remain
Subject choices, subject to RP acceptance policy. These issuance and reuse tradeoffs are
not unique to either an OP-mediated or issuer-holder-verifier architecture.

## Subject Control of Retention and Disclosure

The controls in (#subject-control-of-stored-claim-sets) let the Subject distinguish stored
data from collection and disclosure permissions. They complement the CP's grant-management
interface: revoking a CP grant does not retract issued Claim Sets, while withdrawal at the
OP controls further OP disclosure. Neither operation retracts data already received by an
RP. A Subject may retain a Claim Set as a personal record even after it expires; expiration
restricts valid use rather than imposing deletion. The safeguards in
(#token-and-claim-set-storage) address the resulting storage risks without imposing a
protocol retention deadline or a particular archival encryption design.

Disclosure history can help the Subject identify RPs that already received their data,
including when seeking deletion from those RPs. That history is itself sensitive personal
data and remains subject to protection, minimization, and Subject deletion controls in
(#subject-control-of-stored-claim-sets). Export can give the Subject an independent copy of
an issued artifact, but does not remove the transferability or correlation risks described
in (#correlation-and-transferable-signed-data).


# IANA Considerations

This specification requests registration of two OAuth Authorization Server Metadata
parameters and one media type. The templates below do not indicate that registration has
already been completed.

## OAuth Authorization Server Metadata Registrations

The following entries are requested in the OAuth Authorization Server Metadata registry
[IANA.OAuth.Parameters], using the template in Section 7.1.1 of [RFC8414]. These metadata
parameters apply to the CP's resolved `openid_provider` metadata and its OpenID Connect
Discovery document as specified in (#discovery-phase).

### claims_endpoint

- Metadata Name: `claims_endpoint`
- Metadata Description: HTTPS URL of the Claims Provider's Claims Endpoint.
- Change Controller: OpenID Foundation Artifact Binding Working Group -
  openid-specs-ab@lists.openid.net
- Specification Document(s): This specification, (#discovery-phase) and
  (#claims-endpoint-request).

### claims_signing_alg_values_supported

- Metadata Name: `claims_signing_alg_values_supported`
- Metadata Description: JSON array of asymmetric JWS signing algorithms supported by the Claims
  Provider for signed Claim Sets.
- Change Controller: OpenID Foundation Artifact Binding Working Group -
  openid-specs-ab@lists.openid.net
- Specification Document(s): This specification, (#discovery-phase) and
  (#signed-claim-set-format).

## Media Type Registration

The following registration is requested in the Media Types registry [IANA.MediaTypes],
using the template in Section 5.6 of [RFC6838].

- Type name: `application`
- Subtype name: `claims-aggregation+jwt`
- Required parameters: None.
- Optional parameters: None.
- Encoding considerations: binary; a compact JWS as defined in [JWS].
- Security considerations: See (#security-considerations) and (#privacy-considerations).
- Interoperability considerations: See (#signed-claim-set-format), (#claim-set-profile),
  and (#claims-verification).
- Published specification: This specification, (#signed-claim-set-format) and
  (#claims-verification).
- Applications that use this media type: Implementations of this specification.
- Fragment identifier considerations: No fragment identifier syntax is defined for this media
  type. The existing `+jwt` fragment identifier rules apply.
- Additional information:
    - Deprecated alias names for this type: None.
    - Magic number(s): None.
    - File extension(s): None.
    - Macintosh file type code(s): None.
- Person & email address to contact for further information: Nat Sakimura - nat@nat.consulting.
- Intended usage: COMMON.
- Restrictions on usage: None.
- Author: Nat Sakimura and Edmund Jay.
- Change controller: OpenID Foundation Artifact Binding Working Group -
  openid-specs-ab@lists.openid.net
- Provisional registration? No.

## Other Protocol Elements

The `account_ref`, `nonce`, `claims`, `signing_alg`, and `claim_set` members are defined
within this API's JSON request and response objects. They are not new top-level JWT claims
or new Authorization or Token Endpoint parameters, and this specification requests no
registrations for them in those registries. Existing names in other registries do not
supply their API semantics. No new JOSE header parameter, signing algorithm, or structured
syntax suffix is defined. The existing `typ` header, RS256 algorithm, `+jwt` suffix, JWT
claims, and OAuth token/error mechanisms are reused. No new client capability metadata or
OAuth error value is registered by this specification.


{backmatter}

# Bibliography

[IANA.OAuth.Parameters] - IANA OAuth Parameters
[IANA.OAuth.Parameters]: https://www.iana.org/assignments/oauth-parameters/

[IANA.MediaTypes] - IANA Media Types
[IANA.MediaTypes]: https://www.iana.org/assignments/media-types/

[SD-JWT] - RFC 9901 - Selective Disclosure for JSON Web Tokens
[SD-JWT]: https://www.rfc-editor.org/rfc/rfc9901.html

[OAuth.Security.Update] - Updates to OAuth 2.0 Security Best Current Practice, draft-ietf-oauth-security-topics-update-03, Work in Progress
[OAuth.Security.Update]: https://www.ietf.org/archive/id/draft-ietf-oauth-security-topics-update-03.html

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

* Added registration templates for two CP metadata parameters and the signed Claim Set media type
* Removed dedicated OP/RP type-support metadata while retaining explicit JWT typing
* Defined an ordinary empty acquisition result without a new unavailable-claims error
* Restored Claims Endpoint terminology and defined an explicit JWT type without `sub`
* Required common RS256 signing and verification support for Claim Sets
* Separated acquisition account binding from RP-facing signed attributes and protected stored bindings
* Added endpoint and algorithm metadata and per-request signing selection
* Explained Core Aggregated Claims implementation guidance and the limits of subless presentation
* Defined Subject controls for stored Claim Set deletion and authorization review and withdrawal
* Added deletion/recollection safeguards, disclosure history controls, and optional Subject export
* Recommended CP grant-management interfaces and described OP visibility and transferable signed data
* Explained correlation and the tradeoffs of stored, batch-issued, and on-demand credentials
* Required confidential OP clients with `private_key_jwt` support and optional mTLS authentication
* Bound client assertion audiences to the CP issuer and defined token and storage protections
* Explained the limits of sender-constraining and replay protection for stored Claim Sets
* Defined RP request validation, authorization code and PKCE checks, and per-RP consent
* Required RP `policy_uri` metadata and corrected its use in the consent dialogue
* Bound remembered consent to CP sources and distinguished verified RP display information
* Recommended back-channel delivery of Aggregated Claims to limit front-channel exposure
* Defined local freshness policies, user-directed updates, and authorization withdrawal and revocation handling
* Defined CP signing algorithm selection, verification key resolution, and Claim Set validation
* Required issuance and expiration timestamps in CP-signed UserInfo JWTs
* Required Authorization Code Flow, PKCE S256, and transaction and session validation during Setup
* Bound CP endpoint resolution and code exchange to the selected issuer and connection context
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
