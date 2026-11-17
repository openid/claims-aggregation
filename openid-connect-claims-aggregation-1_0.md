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

[RFC7636] - Proof Key for Code Exchange by OAuth Public Clients
[RFC7636]: https://www.rfc-editor.org/rfc/rfc7636.html

[RFC8725] - JSON Web Token Best Current Practices
[RFC8725]: https://www.rfc-editor.org/rfc/rfc8725.html

[RFC9207] - OAuth 2.0 Authorization Server Issuer Identification
[RFC9207]: https://www.rfc-editor.org/rfc/rfc9207.html

[RFC9700] - Best Current Practice for OAuth 2.0 Security
[RFC9700]: https://www.rfc-editor.org/rfc/rfc9700.html

[OIDC] - OpenID Connect Core 1.0 incorporating errata set 1
[OIDC]: https://openid.net/specs/openid-connect-core-1_0.html

[OpenID.Discovery] - OpenID Connect Discovery 1.0
[OpenID.Discovery]: https://openid.net/specs/openid-connect-discovery-1_0.html

[OpenID.Registration] - OpenID Connect Registration 1.0
[OpenID.Registration]: http://openid.net/specs/openid-connect-registration-1_0.html

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
that supports signed UserInfo response and has the OP as a client.  

The provision for the Claims Provider are as follows: 

1. It MUST support signed UserInfo response. 
1. It MUST support OpenID Federation Automatic Registration as specified in (#client-configuration-phase).

### UserInfo Endpoint
The UserInfo Endpoint is described in 5.3 of OpenID Connect 1.0 [OIDC] as an OAuth 2.0 Protected Resource that returns Claims about the authenticated Subject.

For Claims Aggregation, the CP MUST set the `aud` Claim of the signed UserInfo JWT to the `client_id`
of the OP to which the access token was issued, in accordance with Section 5.3.2 of [OIDC].
The `aud` Claim MUST identify only that client, either as a string or as an array containing that string as its only element.

The CP MUST sign the UserInfo JWT using the asymmetric algorithm selected through
`userinfo_signed_response_alg` in the OP's resolved client metadata. It MUST include `iss`,
`sub`, `aud`, `iat`, and `exp` in that JWT. The `iss` MUST be the CP's Issuer Identifier, and
`sub` MUST identify the Subject at that CP as in the ID Token issued to the OP during Setup.
The `iat` and `exp` values MUST be NumericDate values as defined in [JWT], and `exp` MUST be
later than `iat`. These timestamps describe the issuance and expiration of the signed JWT.
They do not establish when the underlying attributes were last verified.

The CP MUST NOT use the same signing key with more than one signature algorithm. For each
key used to sign Claim Sets, it MUST publish the intended algorithm in the `alg` parameter
of every JWK representation it advertises for that key.

When rotating signing keys, the CP SHOULD keep each retired public key available through its
advertised verification-key sources until all Claim Sets signed with that key have expired,
including the clock-skew allowance used by the deployment. Compromised keys MAY be withdrawn
earlier under the deployment's key revocation policy.


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
UserInfo response, the OP MUST validate it according to [OIDC] and (#claims-verification),
including matching its `iss` and `sub` against the stored CP identifiers. The OP MUST use
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
Profiles can define additional subject binding or presentation-time authentication requirements.

# Discovery Phase

Before making an OpenID Connect Authentication Request to a CP, the OP needs to obtain
configuration information from the CP, 
including its Authorization Endpoint, Token Endpoint, and UserInfo Endpoint locations. 

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
The OP MUST NOT treat the Authorization Endpoint, Token Endpoint, or UserInfo Endpoint as
independently configurable values detached from the CP's Issuer Identifier.

The Claims Provider Metadata uses the following parameters from [OpenID.Discovery].

`userinfo_endpoint`
: **Required**. URL of the CP's UserInfo Endpoint that returns signed Claim Sets.

`userinfo_signing_alg_values_supported`
: **Required**. Non-empty JSON array of the JWS [JWS] signing algorithms (`alg` values) from
  [JWA] supported by the UserInfo Endpoint. It MUST contain at least one asymmetric signing
  algorithm. The value `none` MUST NOT be included.

The CP MUST publish this parameter in its `openid_provider` metadata and, if it also publishes
an [OpenID.Discovery] configuration document, in that document with the same supported values.

The CP MUST set `authorization_response_iss_parameter_supported` to `true` in its
`openid_provider` metadata as specified in [RFC9207].

The CP MUST support the Authorization Code Flow and PKCE with the `S256` code challenge method
as specified in [RFC7636]. Its `openid_provider` metadata MUST include `code` in
`response_types_supported` and `S256` in `code_challenge_methods_supported`. If the CP also
publishes a configuration document using [OpenID.Discovery], it MUST advertise these
capabilities and support for the authorization response `iss` parameter there as well.

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

- `userinfo_signed_response_alg`. The single JWS algorithm the OP requests the CP to use for
  signing UserInfo responses. The OP MUST select an asymmetric algorithm that it permits and
  that is listed in the CP's validated `userinfo_signing_alg_values_supported` metadata. The
  OP MUST NOT select `none` or a symmetric MAC algorithm. If no acceptable algorithm is
  available, the OP MUST abort client configuration.
- `policy_uri`. URL of the OP's privacy policy to be shown to the Subject during the Setup Phase.

The OP MUST omit `userinfo_encrypted_response_alg`.


# Setup Phase

The OP obtains the Subject's authorization to collect claims from each CP it will use. The OP
MUST use the OpenID Connect Authorization Code Flow with `response_type=code` to obtain the grant.
It SHOULD identify the requested claims using `scope`, `claims.userinfo`, or both.
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
Requesting a specific CP requires an extension. The RP applies its own freshness policy as
described in (#local-freshness-policy-and-user-directed-updates).


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

The OP MUST obtain Claim Sets from the CP's UserInfo Endpoint and MUST NOT substitute an ID
Token obtained during Setup. It MUST validate each CP-signed UserInfo JWT when collecting it
and before disclosing a stored Claim Set. The RP MUST validate the OP's enclosing ID Token or
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
policy and the CP's validated `userinfo_signing_alg_values_supported` metadata before
verifying the signature. The JWT's `alg` MUST be in both sets. The OP MUST also verify that
`alg` equals the `userinfo_signed_response_alg` selected in its resolved client metadata.

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

1. Require `iss`, `sub`, `aud`, `iat`, and `exp`. The `iss` and `sub` MUST be non-empty strings.
   The issuer MUST be the CP whose metadata and keys were validated. The OP MUST match the CP
   `iss` and `sub` to the identifiers bound to the authenticated OP account in (#trust-model).
   The RP MUST apply its trust policy to decide whether that CP is trusted for the claims.
   The RP relies on the OP for the subject binding described in (#trust-model).
1. Require exactly one `aud` value, expressed as a string or a single-element array of strings.
   The OP MUST compare it with its own `client_id` at the CP. The RP MUST compare it with the
   Issuer Identifier of the OP used for the OpenID Connect transaction. The RP MUST use the
   Issuer Identifier established during OpenID Connect validation. For Aggregated Claims in
   a UserInfo response, it uses the OP associated with the access token used for that request.
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
remains subject to that specification's applicable OP requirements. When its external
assertion format is used, the requirements in Section 6.1 of [OpenID4IDA] apply.


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

A CP's ID Token can contain the same issuer, subject, audience, and timestamps as a signed
UserInfo JWT. The base profile does not provide cryptographic separation of those JWT types
to the RP. It relies on the L1 trust model and the OP's requirement to use the UserInfo
Endpoint as the Claim Set source. The presence or absence of `nonce` or `auth_time` alone
does not establish the JWT's purpose. Profiles requiring the RP to distinguish these token
types independently MUST define mutually exclusive validation rules, for example distinct
explicit types and their validation, as described in Section 3.12 of [RFC8725].

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

Unless ephemeral identifiers are used at CPs, colluding RPs CAN correlate the subject using the `sub` value in the JWT included in the aggregated claim.

Reusing the same CP-signed JWT across presentations allows recipients that compare their
received JWTs to correlate those presentations, including across colluding RPs. The JWT
itself, including its signature, provides a common value for comparison even when identifiers
used elsewhere are ephemeral or pairwise. Obtaining a newly issued JWT does not necessarily
prevent correlation if it contains stable identifiers or identifying combinations of claims.

Pre-collection and reuse of stored Claim Sets can reduce the CP's visibility into the timing
of the Subject's interactions with RPs. Updating claims in response to an RP's request for
fresher information can trigger CP UserInfo calls whose timing and frequency may be
correlated with downstream activity. The OP SHOULD explain both the correlation risk of
reusing a JWT and the CP timing-visibility risk of obtaining updates when obtaining the
Subject's authorization for collection and disclosure. The Subject can then choose whether
to authorize reuse or request an update, subject to the RP's acceptance policy. The OP MAY
use privacy policies and rate limits when servicing user-directed updates.


{backmatter}

# Bibliography

[RFC7009] - OAuth 2.0 Token Revocation
[RFC7009]: https://www.rfc-editor.org/rfc/rfc7009.html

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
