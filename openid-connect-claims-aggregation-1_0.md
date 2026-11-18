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

An OpenID Provider (OP) can disclose claims about an End-User, such as a name
or date of birth, to a Relying Party (RP) with the End-User's consent. This
document profiles the Aggregated Claims model defined in Section 5.6.2 of
OpenID Connect Core 1.0 [OIDC]. In this model, the OP returns claims asserted
by one or more Claims Providers (CPs).

This document specifies the following interactions.

* The OP discovers CP metadata.
* The OP establishes itself as a client of the CP.
* The OP obtains claims from the CP.
* The RP requests claims from the OP.
* The OP returns claims from the CP to the RP as Aggregated Claims.
* The RP verifies the returned claims.

.# Warning

This document is not an OIDF International Standard. It is distributed for review and comment. It is subject to change without notice and may not be referred to as an International Standard.

Recipients of this draft are invited to submit, with their comments, notification of any relevant patent rights of which they are aware and to provide supporting documentation.

.# Foreword

The OpenID Foundation (OIDF) promotes, protects and nurtures the OpenID community and technologies. As a non-profit international standardizing body, it comprises over 160 participating entities (workgroup participants). The work of preparing implementer drafts and final international standards is carried out through OIDF workgroups in accordance with the OpenID Process. Participants interested in a subject for which a workgroup has been established have the right to be represented in that workgroup. International organizations, governmental and non-governmental, in liaison with OIDF, also take part in the work. OIDF collaborates closely with other standardizing bodies in the related fields.

.# Introduction

OpenID Connect is a selective claims disclosure mechanism. When a set of claims included in its response is about 
an entity authentication event, it works as an entity authentication federation mechanism, but it can deliver 
other claims selected by the subject as well. 

An OpenID Connect response can include claims from several sources. These sources can be authoritative
or corroborative. The roles in the Aggregated Claims model are described in (#actors).

An OP can return claims from CPs to an RP by value or by reference. With
Aggregated Claims, the OP obtains the claims from the CPs and returns them
by value. With Distributed Claims, the OP returns references and access
information so that the RP can obtain the claim values.

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
disclosing it. As described in (#trust-model), the RP relies on the OP for Subject
binding. Omitting `sub` does not prevent correlation through reuse of the same JWT or
through identifying attributes. The Subject can authorize reuse of
stored Claim Sets or request new issuance. Privacy Considerations describes the
tradeoffs for privacy and availability.

Another feature that this document provides is the way to avoid multiple consent screen 
per RP authorization request. If OpenID Connect Core spec is used to build Aggregated Claims Model 
naively, it may result in many consent screens per RP request. 
For example, if four CPs and one OP is involved in the request, then, there may be five consent screens. 
This is too onerous. This document defines a mechanism to consolidate it into one consent screen. 
This is done through one "OP User Setup Phase" per CP that the OP obtains the consent 
from the subject to obtain claims from the CP for the purpose of creating aggregated 
claims response for future RP requests in which OP will collect a new consent from the subject. 

The OP obtains an access token and, if needed and granted, a refresh token. The CP's Claims
Endpoint returns signed Claim Sets separately from OP-facing account-binding information.
Profiles and trust frameworks may require the use of refresh tokens.


The specification has four phases.

1. Discovery Phase. The OP discovers CP metadata.
1. Client Configuration Phase. The OP establishes itself as a client of the CP.
1. Setup Phase. The Subject authorizes the OP to obtain claims from the CP. The OP
   obtains an access token and may obtain a refresh token.
1. Delivery Phase (RP Phase). The RP sends an authentication and claims request to
   the OP. The OP obtains any needed Claim Sets from the CPs and returns Aggregated
   Claims. The RP verifies the response.

This document is intended for developers and systems architects who build
systems that use attributes and claims.



.# Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" in this document are to be interpreted as described in BCP
14 ([RFC2119] and [RFC8174]) when, and only when, they appear in all
capitals, as shown here.

List item numbers are local to each section. Cite an item by its section number and
item number, separated by a hyphen. For example, 9.6-4 refers to item 4 in Section 9.6.

{mainmatter}

# Scope

This document specifies the following interactions.

* The OP discovers CP metadata.
* The OP establishes itself as a client of the CP.
* The OP obtains claims from the CP.
* The RP requests claims from the OP.
* The OP returns claims from the CP to the RP as Aggregated Claims.
* The RP verifies the returned claims.

# Normative references
The following referenced documents are indispensable for the application of this document. For dated references, only the edition cited applied. For undated references, the latest edition of the referenced document (including any amendments) applies.

[RFC2119] - Key words for use in RFCs to Indicate Requirement Levels
[RFC2119]: https://www.rfc-editor.org/rfc/rfc2119.html

[RFC6749] - The OAuth 2.0 Authorization Framework
[RFC6749]: https://www.rfc-editor.org/rfc/rfc6749.html

[RFC6750] - The OAuth 2.0 Authorization Framework: Bearer Token Usage
[RFC6750]: https://www.rfc-editor.org/rfc/rfc6750.html

[RFC6838] - Media Type Specifications and Registration Procedures
[RFC6838]: https://www.rfc-editor.org/rfc/rfc6838.html

[RFC7009] - OAuth 2.0 Token Revocation
[RFC7009]: https://www.rfc-editor.org/rfc/rfc7009.html

[RFC7636] - Proof Key for Code Exchange by OAuth Public Clients
[RFC7636]: https://www.rfc-editor.org/rfc/rfc7636.html

[RFC8174] - Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words
[RFC8174]: https://www.rfc-editor.org/rfc/rfc8174.html

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

[JWA] - JSON Web Algorithms
[JWA]: https://www.rfc-editor.org/rfc/rfc7518.html

# Terms and definitions
For the purpose of this document, the terms defined in [RFC6749], [RFC6750], [RFC7636], [OpenID Connect Core][OIDC] and the following apply.

**Aggregated Claims** – claims asserted by a CP and returned by an OP using the
representation defined in Section 5.6.2 of [OIDC]

**Claim Set** – a CP-signed JWT containing claims issued through the CP's Claims Endpoint

# Symbols and abbreviated terms

**RP** – Relying Party

**OP** – OpenID Provider

**CP** – Claims Provider

**HTTP** - Hyper Text Transfer Protocol

**TLS** - Transport Layer Security

# Actors

## Example Interaction

The following example shows one CP and one RP. The OP discovers the CP
and establishes client registration before this exchange. See
(#discovery-phase) and (#client-configuration-phase).

~~~ mermaid
---
config:
  theme: neutral
  sequence:
    mirrorActors: false
---
sequenceDiagram
    autonumber
    actor S as Subject
    participant CP as Claims Provider (CP)
    participant OP as OpenID Provider (OP)
    participant RP as Relying Party (RP)

    rect rgb(243, 245, 248)
        Note over S,OP: Setup: authorize collection from the CP
        OP->>CP: Authorization request via user agent<br/>(state, PKCE S256)
        CP->>S: Show collection consent dialogue
        S-->>CP: Authorize collection
        CP-->>OP: Authorization response via user agent<br/>(code, state, iss)
        OP->>CP: Token request<br/>(code, code_verifier, client authentication)
        CP-->>OP: ID Token and access token<br/>(optional refresh token)
        Note over CP,OP: Validate the ID Token and bind the CP account
    end

    rect rgb(243, 245, 248)
        Note over CP,RP: Delivery: authorize and return claims to the RP
        RP->>OP: OpenID Connect Authentication<br/>Request (claims)
        opt OP needs new disclosure authorization
            OP->>S: Present the RP, claims and sources
            S-->>OP: Authorize disclosure to the RP
        end
        alt Suitable stored Claim Set
            Note over OP,RP: Check the stored Claim Set and current authorization
        else New collection needed (successful result shown)
            OP->>CP: POST to Claims Endpoint<br/>(access token, nonce, claims, signing_alg)
            CP-->>OP: Collection response<br/>(nonce, account_ref, claim_set)
            Note over CP,OP: Validate the response and preserve the binding
        end
        OP-->>RP: ID Token or UserInfo response<br/>(signed Claim Set in _claim_sources)
        Note over OP,RP: RP validates the OP response and Claim Set
    end
~~~
Figure: Example of Setup, Claim Set collection, and delivery

Messages 1–6 illustrate (#setup-phase).

Messages 7–9 illustrate (#claims-request-by-rp-to-op) and (#subject-granting).

Messages 10–11 illustrate (#claims-endpoint-request) and (#claims-endpoint-response).
See (#claims-collection) for the alternative that uses a stored Claim Set.

Message 12 illustrates (#claims-delivery). The RP's checks are in (#claims-verification).


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

The Claims Provider (CP) is an OpenID Provider that accepts the aggregating OP as a client.
The CP obtains the Subject's authorization for collection during Setup.
It issues signed Claim Sets through its Claims Endpoint.
The CP also supplies the account reference that the OP uses to associate each set with the Subject.

## OP

The aggregating OpenID Provider (OP) acts as an OpenID Connect client of the CP.
It serves RPs as their OpenID Provider.
At the Subject's direction, it collects Claim Sets and can store them for later use.
It associates each Claim Set with the Subject's OP account.
It returns the CP's signed Claim Sets as Aggregated Claims to RPs that the Subject authorizes.



# Trust Model

The RP relies on the OP to link each CP-signed Claim Set to the authenticated Subject.
The RP verifies each CP-signed Claim Set separately from its validation of the OP's response.
The OP asserts that each included Claim Set concerns the Subject in the response's `sub` claim.

1. The OP MUST bind the CP's Issuer Identifier and Subject Identifier (`iss`, `sub`), obtained
   from the validated CP ID Token during Setup, to the authenticated OP account that initiated
   Setup.
1. The OP MUST bind the corresponding authorization grant and its access and refresh tokens to
   the same OP account.
1. Token refresh and downscoping MUST preserve this binding.
1. When collecting a Claim Set, the OP MUST validate the CP response according to
   (#claims-endpoint-response) and the signed JWT according to (#claims-verification),
   including matching the response `account_ref` against the stored CP Subject Identifier and
   the JWT `iss` against the stored CP Issuer Identifier.
1. The OP MUST use those tokens and any Claim Sets obtained with them only for the bound OP
   account.

This requirement also applies to stored Claim Sets.

The OP and the CP establish trust for client registration through [OpenID.Federation]. The CP's
grant authorizes the OP to collect claims. Disclosure to a particular RP requires the Subject's
separate authorization at the OP as described in (#subject-granting).

6. The RP MUST validate the OP's ID Token or UserInfo response according to [OIDC].
1. The RP MUST apply its trust policy to decide whether it trusts the OP to associate claims
   with the Subject and whether it trusts each CP as a source for the claims it uses.
1. The RP MAY use Federation to establish trust in either party.

A deployment can use Federation Trust Marks to indicate conformance with its trust
framework. The bare CP-signed JWT contains no CP Subject Identifier and does not
independently prove which Subject it concerns. The RP relies on the OP's enclosing response
and the protected acquisition and storage binding.

9. A bare JWT imported from another source MUST NOT by itself establish an account binding.
1. Restoration of a stored Claim Set MUST also restore and validate its protected
   account-binding record.

Export does not make the JWT usable with a different OP audience. Profiles can define
additional subject binding or presentation-time authentication requirements.

# Discovery Phase

## CP Discovery and Metadata

Before making an OpenID Connect Authentication Request to a CP, the OP needs to obtain
configuration information from the CP, 
including its Authorization Endpoint, Token Endpoint, and Claims Endpoint locations.

This information is obtained via Discovery, as described in OpenID Connect Discovery 1.0 [OpenID.Discovery], or may be obtained via other mechanisms.

1. For each Setup transaction, the OP MUST identify the CP by its Issuer Identifier and use
   metadata resolved for that issuer.
1. The OP MUST validate the issuer as required by Section 4.3 of [OpenID.Discovery] or Section
   5.1.3 of [OpenID.Federation].
1. Other metadata acquisition mechanisms MUST provide the same validated issuer binding.
1. The OP MAY reuse metadata cached for that issuer while it remains valid under the
   applicable caching rules and, when using Federation, the Trust Chain validity requirements
   in Section 12.3 of [OpenID.Federation].
1. Once those validity conditions cease to hold, the OP MUST successfully refresh and validate
   the metadata and, when applicable, reevaluate trust before continuing the transaction.
1. The OP MUST retain the association between the issuer and the resolved endpoints throughout
   the transaction.
1. The OP MUST NOT treat the Authorization Endpoint, Token Endpoint, or Claims Endpoint as
   independently configurable values detached from the CP's Issuer Identifier.
1. The CP MUST publish the following metadata in its `openid_provider` metadata and, if it
   also publishes an [OpenID.Discovery] configuration document, in that document with the same
   values.

These parameters extend the metadata in [OpenID.Discovery].

9. The CP MUST include `claims_endpoint` as the HTTPS URL of its Claims Endpoint.
1. The CP MUST omit the fragment component from that URL.
1. The CP MUST include `claims_signing_alg_values_supported` as a non-empty JSON array of
   asymmetric JWS algorithms for Claim Sets.
1. The CP MUST exclude `none` and symmetric MAC algorithms from this array.
1. The CP MUST support each advertised algorithm when the OP selects it in the Claims
   Endpoint request.
1. The CP MUST include `RS256` in this array.
1. The OP MUST find an advertised algorithm that its local policy permits or abort
   collection.
1. The CP and OP MAY advertise and select, respectively, additional asymmetric algorithms.
1. The endpoint and its signing algorithms MUST remain bound to the validated CP issuer.

The CP's UserInfo metadata does not select the Claim Set signing algorithm.

18. The CP MUST set `authorization_response_iss_parameter_supported` to `true` in its
    `openid_provider` metadata as specified in [RFC9207].
1. The CP MUST support the Authorization Code Flow and PKCE with the `S256` code challenge
   method as specified in [RFC7636].
1. Its `openid_provider` metadata MUST include `code` in `response_types_supported` and
   `S256` in `code_challenge_methods_supported`.
1. If the CP also publishes a configuration document using [OpenID.Discovery], it MUST
   advertise these capabilities and support for the authorization response `iss` parameter
   there as well.

### Claims Endpoint

1. The CP MUST expose a Claims Endpoint.

The Claims Endpoint is an OAuth 2.0 protected resource where the OP obtains CP-signed Claim Sets.
It differs from the UserInfo Endpoint and the RP-facing endpoint for Distributed Claims in [OIDC].
See (#claims-endpoint-request) and (#claims-endpoint-response) for the wire protocol.

## Claim Set Profile

This specification defines one signed Claim Set profile, identified by the explicit JWT
`typ` in (#signed-claim-set-format). It does not define a new RP capability metadata member
or an Authentication Request parameter to negotiate that type. The OP advertises support for
Aggregated Claims as described below.

1. Deployments MAY establish OP/RP profile support through configuration, registration
   arrangements, or a trust framework, consistently with Section 5.6.2 of [OIDC].

The type requirement applies to Claim Sets issued by this specification's Claims Endpoint;
it does not impose that type on every JWT used for Aggregated Claims under [OIDC].

2. Within this profile, the OP and RP MUST apply (#claims-verification).
1. If validation fails, the OP and RP MUST NOT silently fall back to an ID Token, UserInfo
   JWT, or another profile.
1. The CP MUST implement `RS256` signing for Claim Sets.
1. The OP MUST implement `RS256` signature verification for Claim Sets.
1. The RP MUST implement `RS256` signature verification for Claim Sets.
1. The OP MUST support selecting `RS256` in Claims Endpoint requests.
1. Implementations MAY support other asymmetric algorithms subject to (#signature-validation).
1. The CP MUST support the format in (#signed-claim-set-format).

Existing stored JWTs with `sub` do not conform to this profile. Support for another profile
requires separate validation rules and deployment arrangements outside this specification.

## Aggregating OP Metadata

1. The OP MUST include `aggregated` in `claim_types_supported` and set
   `claims_parameter_supported` to `true` in its `openid_provider` metadata.
1. If the OP also publishes a configuration document using [OpenID.Discovery], it MUST
   advertise the same capabilities there.

These parameters describe the OP's capabilities for serving RPs. A CP that only serves Claim
Sets to the OP has no requirement to advertise `aggregated` in that role.

3. For authorization code responses to RPs, the OP MUST support PKCE with `S256` as specified
   in [RFC7636].
1. The OP MUST include `S256` in `code_challenge_methods_supported` in its `openid_provider`
   metadata and, if published, its [OpenID.Discovery] configuration document.
1. The OP MUST support Aggregated Claims as an OpenID Provider under [OIDC].


# Client Configuration Phase

## Automatic Registration

The OP acts as an OpenID Connect client of the CP.

1. The OP and the CP MUST use Automatic Registration as specified in Section 12.1 of
   [OpenID.Federation].
1. The OP MUST publish `openid_provider` and `openid_relying_party` metadata in its Entity
   Configuration under the same Entity Identifier.
1. The OP MUST use this Entity Identifier as both its Issuer Identifier and its `client_id` at
   the CP.
1. The OP and the CP MUST perform Trust Chain and metadata resolution as required by
   [OpenID.Federation].

For example, an OP with the Issuer Identifier `https://op.example` uses `https://op.example` as its
`client_id` at the CP and publishes its Entity Configuration at
`https://op.example/.well-known/openid-federation`.

## Client Metadata

1. The OP MUST include `policy_uri`, defined in [OpenID.Registration], in its
   `openid_relying_party` metadata so the CP can show its privacy policy during Setup.

Claim Set signing algorithms are selected per collection request from the CP's validated
`claims_signing_alg_values_supported`, subject to OP policy. They are not selected using
`userinfo_signed_response_alg`. UserInfo response signing and encryption metadata do not
control the Claims Endpoint. The OP's single Federation RP metadata object therefore
does not need to declare a different Claim Set signing algorithm for each CP.

## OP Client Authentication

1. The OP MUST act as a confidential client of the CP.
1. The OP MUST support `private_key_jwt` client authentication.
1. The CP MUST support `private_key_jwt` client authentication.

The OP declares one `token_endpoint_auth_method` in its `openid_relying_party` metadata.
The declaration applies to every CP that uses that Entity Configuration.
[OIDC] defines `private_key_jwt`.
[OpenID.Federation] governs client authentication during Automatic Registration, including PAR.

4. The OP MUST declare `private_key_jwt` in the base profile.
1. The OP MUST authenticate with its declared method at the CP's Token Endpoint.
1. A profile or trust framework MAY require `self_signed_tls_client_auth` for all participating OPs and CPs.
1. The OP MUST declare `self_signed_tls_client_auth` when its profile or trust framework requires it.
1. The OP MUST NOT use `none` or shared-secret client authentication.

mTLS support is optional in the base profile.

The CP advertises these methods in `token_endpoint_auth_methods_supported` in its `openid_provider` metadata.
The following requirements also apply to any [OpenID.Discovery] configuration document the CP publishes.

9. The CP MUST advertise `private_key_jwt`.
1. The CP MUST advertise `self_signed_tls_client_auth` if it supports that method.
1. At other authenticated CP endpoints, the OP MUST use a mutually supported method consistent with resolved metadata.
1. The OP MUST send each authenticated request to the endpoint in the selected CP's validated metadata.

The following requirements apply to `private_key_jwt` at each CP endpoint that uses it.
Examples include the Token, PAR, and revocation endpoints.
[OAuth.Security.Update] defines the audience restriction.

13. The OP MUST set `aud` to the validated CP Issuer Identifier as a string or single-element array.
1. The OP MUST obtain that identifier as specified in (#discovery-phase).
1. The CP MUST reject an assertion if its `aud` fails these requirements.
1. The CP MUST validate the assertion signature with the OP's resolved `openid_relying_party` keys.
1. The OP SHOULD use short-lived assertions.
1. The OP MUST follow any assertion lifetime limits from its profile or trust framework.
1. The CP MUST reject assertion reuse.
1. The CP MUST retain each accepted (`client_id`, `jti`) pair through `exp`, including any permitted clock skew.

An assertion lifetime of a few minutes is one option.

[RFC8705] governs certificate and client binding when the OP uses `self_signed_tls_client_auth`.

21. The CP MUST match the presented certificate against the OP's resolved RP JWK Set at each such endpoint.


# Setup Phase

## OP Collection Authorization

The OP obtains the Subject's authorization to collect claims from each CP it will use.

1. The OP MUST use the OpenID Connect Authorization Code Flow with `response_type=code` to
   obtain the grant.
1. The OP SHOULD identify the requested claims and collection permissions using scopes
   supported by the CP.
1. The grant MUST authorize access to the Claims Endpoint for the requested claims.

This specification does not assign new meaning to `claims.userinfo` or `claims.id_token` for
that resource; mapping claim permissions to scopes is defined by the CP or an applicable
profile or trust framework.

4. The OP MUST NOT assume that a UserInfo-only token authorizes access to the Claims Endpoint.

An existing grant without the required resource permission requires new authorization before
collection.

5. The OP SHOULD limit the requested grant to claims and operations needed for the collection
   purposes authorized by the Subject, as described in Section 2.3 of [RFC9700].
1. The OP MUST associate the grant and tokens with the authenticated OP account as specified
   in (#trust-model).
1. When requesting a refresh token for offline access, the OP MUST include `offline_access` in
   `scope`.
1. The OP and CP MUST follow the consent requirements in Section 11 of [OIDC], including
   `prompt=consent` unless other conditions permitting offline access are in place.
1. The OP MUST collect claims as the CP's OpenID Connect client at the Subject's direction.

## CP Consent Dialogue

1. The CP MUST show the Subject a dialogue explaining that the OP will obtain signed Claim
   Sets to provide claims to RPs at the Subject's direction.
1. The CP MUST include in the dialogue a link to the `policy_uri` in the OP's client metadata.
1. The CP MUST require active interaction from the Subject before granting access.
1. The CP MUST explain that the OP can continue to use or disclose collected Claim Sets until
   they expire, even after the CP revokes the grant.
1. The CP MUST explain that the Subject controls further disclosure at the OP.
1. The CP MUST explain that the Subject uses the OP's controls to stop disclosure as described
   in (#authorization-withdrawal-and-grant-revocation).

### CP Grant Management

1. The CP SHOULD let the authenticated Subject review standing grants to OPs through a user interface.
1. The CP SHOULD let the authenticated Subject revoke standing grants through that interface.
1. The CP SHOULD show the claims and operations each grant permits in that interface.

## CP Token Issuance and Use

1. The CP SHOULD issue short-lived access tokens.
1. The CP SHOULD set access token lifetimes according to claim sensitivity and exposure.
1. The CP SHOULD restrict each access token to its Claims Endpoint.
1. The CP SHOULD restrict each access token to the claims and operations that the Subject authorizes.

These restrictions apply regardless of the token format. The CP checks resource and access
permissions as specified in (#claims-endpoint-request).

5. The CP SHOULD issue sender-constrained access tokens.
1. The OP SHOULD use sender-constrained access tokens.

The OP and CP can use certificate binding [RFC8705] or DPoP [RFC9449].
The Claims Endpoint applies the relevant proof requirements in (#claims-endpoint-request).
mTLS client authentication alone does not imply certificate-bound access tokens.

7. The CP MUST follow [RFC9700] when it decides whether to issue refresh tokens.
1. The CP MUST apply the refresh token scope and resource binding requirements in [RFC9700].
1. The OP MUST preserve the account binding when it replaces a refresh token.
1. The CP SHOULD support token revocation as specified in [RFC7009].

[RFC6749] governs refresh token authentication and replacement.
The CP can rotate refresh tokens to detect replay.
Token expiration, rotation, and revocation govern further collection.
(#authorization-withdrawal-and-grant-revocation) describes their effect on stored Claim Sets.

## Authorization Request and Transaction Binding

1. The OP MUST authenticate the Subject before starting Setup.
1. The OP MUST create an authorization transaction for Setup.
1. The OP MUST bind the transaction to the authenticated OP account.
1. The OP MUST bind the transaction to the initiating user-agent session.
1. The OP MUST record the selected CP's resolved metadata in the transaction.
1. The OP MUST record its client registration at that CP in the transaction.
1. The OP MUST record the request's `redirect_uri` in the transaction.
1. The OP MUST bind any selected CP connection configuration to the transaction.
1. The OP MUST bind any selected tenant to the transaction.

(#authorization-response-issuer-validation) specifies how the OP binds the selected CP issuer.
The CP identifies Claims Aggregation clients by their `client_id` under (#client-configuration-phase).

10. The OP MUST use [RFC7636] PKCE with an explicit `S256` method for every Setup request.
1. The OP MUST check the validated CP metadata for `S256` support before sending the request.
1. The OP MUST abort Setup if that metadata does not advertise `S256` support.
1. The OP MUST bind the PKCE verifier to the transaction.
1. The CP MUST reject authorization requests from Claims Aggregation clients without an `S256` challenge.
1. The CP MUST apply the authorization server requirements for PKCE in [RFC9700].
1. The OP MUST send an unpredictable, transaction-specific `state` value.
1. The OP MUST securely bind `state` to the transaction and initiating user-agent session.
1. The OP MUST limit the lifetime of each transaction.
1. The OP MUST accept each transaction at most once.
1. The OP MUST reject expired transactions.
1. If the OP sends a `nonce`, it MUST bind that value to the transaction.

[OIDC] governs validation of the ID Token's `nonce`.

## Authorization Response Session Validation

The OP applies the response checks after either recovery procedure and before it sends the code.

1. The OP MUST match the returned `state` to the pending transaction before sending the authorization code.
1. The OP MUST verify the completion session's binding to the initiating OP account before sending the code.
1. The OP MUST abort Setup if `state` is missing or either check fails.
1. The OP MUST abort Setup for expired or previously used transactions.
1. The OP MUST NOT establish the OP account from a URL-carried `state` or session identifier alone.
1. The OP MUST NOT establish the user-agent session from a URL-carried `state` or session identifier alone.
1. The OP MUST use one procedure below if the initiating session is unavailable at the redirection endpoint.

**One-time handle.** The following requirements apply when the OP uses a handle.

8. The OP MUST store the authorization response with its pending transaction.
1. The OP MUST generate an unpredictable, short-lived handle for the stored response and transaction.
1. The OP MUST return the user agent to the initiating origin or application with that handle.
1. The OP MUST require the original session cookie or an equivalent session credential from the initiating application.
1. The OP MUST verify that credential's binding to the initiating OP account and transaction.
1. The OP MUST consume the handle at most once.
1. The OP MUST NOT complete Setup based on the handle alone.
1. The OP MUST set the handle to expire no later than the pending transaction.
1. The OP MUST limit the handle's lifetime to the CP code's remaining lifetime if known.
1. If the CP rejects the code as expired, the OP MUST invalidate the handle.
1. If the CP rejects the code as expired, the OP MUST require a new Setup transaction.

**Reauthentication.** The following requirements apply when the OP uses reauthentication.

19. The OP MUST reauthenticate the Subject before sending the authorization code.
1. The OP MUST match the reauthenticated account to the initiating account before sending the authorization code.

The following requirement applies to both procedures.

21. The OP MUST limit further redirection to destinations it controls and attackers cannot override.

## Authorization Response Issuer Validation

1. The CP MUST include the [RFC9207] `iss` parameter in every Setup authorization response.
1. The OP MUST bind the expected issuer from validated CP metadata to the Setup transaction and user-agent session.
1. The OP MUST validate the response `iss` against the bound issuer per [RFC9207] before code exchange.
1. The OP MUST reject any Setup authorization response that omits `iss`.

## Token Request and Account Binding

1. The OP MUST use the client registration, `redirect_uri`, and PKCE verifier bound to the
   validated transaction for the code exchange.
1. The OP MUST NOT select a different CP, connection configuration, tenant, or Token Endpoint
   based on the received response.
1. After validating the CP's ID Token according to [OIDC], the OP MUST establish the account
   binding in (#trust-model) before using or storing the resulting tokens or Claim Sets for
   that account.
1. If the OP has a stored CP subject binding for the OP account and the same CP issuer, it
   MUST compare the new CP `sub` with the stored value.
1. If it detects a different CP `sub`, the OP MUST treat it as account relinking and obtain
   explicit confirmation from the authenticated Subject before replacing the binding.
1. Before establishing a new binding, the OP SHOULD check whether the validated CP (`iss`,
   `sub`) is already bound to another OP account within the applicable account namespace,
   including the tenant where accounts are tenant-scoped.
1. If such a binding exists, the OP MUST either reject the new binding or require additional
   verification under the deployment's account-linking policy before making the CP's tokens or
   Claim Sets available to the new OP account.
1. The OP MUST NOT automatically transfer or remove the existing binding.
1. Deployments that permit a CP account to be linked to multiple OP accounts MUST define the
   conditions for doing so in that policy.

# Delivery Phase (RP Phase)

## Delivery Overview

The Delivery Phase typically includes the following steps.

1. (Claims Request) The RP sends an OpenID Connect Authentication Request to the OP.
1. (Request Verification) The OP validates the request.
1. (Subject Granting) The OP establishes the Subject's authorization for disclosure
   to the RP as described in (#subject-granting).
1. (Claims Collection) The OP obtains suitable Claim Sets as described in
   (#claims-collection).
1. (Claims Delivery) The OP returns the authorized Aggregated Claims to the RP as
   described in (#claims-delivery).
1. (Claims Verification) The RP verifies the response.

## Claims Request by RP to OP

1. The RP MUST use an OpenID Connect Authentication Request as defined in [OIDC].
1. To request individual claims, the RP MUST use the standard `claims` parameter with
   `userinfo`, `id_token`, or both, as described in Section 5.5 of [OIDC].
1. The OP MUST support this parameter.

The RP can also use `scope` as defined in [OIDC].

4. The RP MUST provide `policy_uri` in its client metadata as defined in Section 2 of
   [OpenID.Registration]. This specification requires that otherwise optional parameter so the
   OP can show the RP's privacy policy to the Subject during authorization.
1. The OP selects CPs associated with the Subject's account and MUST use the Aggregated Claims
   format for claims it returns from those CPs.

The RP can apply its own policy to the CP's signed `iss` when deciding whether to use the
claims. The request syntax defined here covers claim names. Requesting a specific CP
requires an extension. The RP applies its own freshness policy as described in
(#local-freshness-policy-and-user-directed-updates).


## RP authentication and the request verification

1. The OP MUST apply the redirect URI matching rules in [RFC9700].
1. The OP MUST apply the authorization server requirements for PKCE in [RFC9700].
1. The RP MUST apply the protections against CSRF and authorization code injection in [RFC9700].

This profile adds the following PKCE requirements.

4. The RP MUST use `S256` whenever it uses PKCE.
1. The RP MUST securely bind its transaction-specific PKCE verifier to the initiating client and user agent.
1. The OP MUST reject a public RP's request for an authorization code without an `S256` challenge.
1. The OP MUST reject requests with `code_challenge` unless `code_challenge_method` is explicitly `S256`.

## Subject Granting

1. After verifying the request, the OP MUST authenticate the Subject if necessary and obtain
   the Subject's authorization to disclose claims to the requesting RP.
1. The OP MUST obtain that RP-specific authorization before initiating a CP authorization
   request on behalf of that RP and, in all cases, before disclosing claims, including
   previously collected Claim Sets.
1. When obtaining consent, the OP MUST show the Subject a dialogue.
1. In the dialogue, the OP MUST identify the requesting RP by its `client_id` and, if present,
   its `client_name` from the client metadata registered or resolved for that `client_id`.
1. In the dialogue, the OP MUST identify each claim's CP source based on its validated Issuer
   Identifier.
1. The OP MUST show the claims it will disclose to the RP, including any additional claims in
   an embedded JWT as described in (#claims-delivery).
1. The OP MUST tell the Subject that it will disclose the CP's Issuer Identifier and any
   identifying attributes in that JWT to the RP. The OP-facing account reference is not
   disclosed by this profile.
1. The OP MUST link to the RP's `policy_uri` from that client metadata.
1. The OP MUST obtain the Subject's consent through explicit action.
1. The OP SHOULD prefer RP identity information verified under the applicable trust framework
   when presenting the RP to the Subject.

Such information can include `organization_name` verified through Federation metadata policy
or an applicable Trust Mark attesting to that identity information. Resolving signed
metadata or validating a Trust Mark does not by itself verify every displayed name.

11. The OP MUST NOT present an unverified `client_name` or other self-asserted identity
    information as verified.
1. The OP SHOULD select language-tagged display values, such as `client_name#ja`, according
   to the Subject's language preferences, with fallback as described in Section 2.1 of
   [OpenID.Registration].
1. The OP MAY remember a consent decision for the same authenticated Subject and RP
   `client_id`, limited to the authorized claims and their CP sources identified by validated
   Issuer Identifiers.
1. The OP MUST NOT skip the dialogue based on consent given to a different RP or on the CP
   grant authorizing the OP to collect claims.
1. The OP MUST NOT use remembered consent after withdrawal, for claims outside its authorized
   scope, or for a different CP source that the Subject has not authorized.

Withdrawal is handled as specified in (#authorization-withdrawal-and-grant-revocation).

16. When the RP requests `prompt=consent`, the OP MUST obtain fresh consent through explicit
    action.
1. When `prompt=none` is requested, the OP MUST NOT display a dialogue.
1. If valid consent covering the disclosure to that RP is unavailable, it MUST return
   `consent_required` as defined in Section 3.1.2.6 of [OIDC].

Other authentication or interaction requirements are handled using the applicable errors in
that section.

## Claims Collection

### Collection and Reuse

1. The OP MAY collect Claim Sets before an RP requests them if the CP grant and the Subject's
   authorization permit it.
1. The OP MAY reuse a stored Claim Set if it still meets the applicable validity,
   authorization, and account-binding requirements, including the OP's collection and storage
   policies.
1. The OP SHOULD provide a means for the authenticated Subject to request updated claims from
   a selected CP.
1. The OP MAY perform a new collection using the Subject's existing authorization and valid CP
   tokens, or obtain the necessary authorization at the CP as described in (#setup-phase).
1. The OP MAY apply privacy policies and rate limits to such updates.

Renewing an access token alone does not update a stored Claim Set.

6. The OP MUST preserve the CP-signed JWT and its `iat` when storing and disclosing it.
1. For a new collection, the OP SHOULD use an access token with the narrowest scope available
   for the claims it needs.
1. If the available access token grants broader access than needed, and a refresh token and a
   suitable narrower scope are available, the OP SHOULD request a downscoped access token
   using `grant_type=refresh_token` and `scope`, as described in Section 12 of [OIDC] and
   Section 6 of [RFC6749].
1. The OP MUST request a scope within the scope of the original grant.
1. The OP MUST successfully reevaluate trust in the CP before continuing to make requests
   after the Trust Chain expires, as specified in Section 12.3 of [OpenID.Federation].
1. If a new collection is needed and the OP cannot obtain a suitable Claim Set using a valid
   access token or a refresh token, it MUST obtain the necessary authorization from the
   Subject at the CP or omit the affected claims.

### Token and Claim Set Storage

1. The OP MUST protect stored CP access tokens, refresh tokens, client authentication and
   proof-of-possession private keys, and signed Claim Sets against unauthorized disclosure,
   modification, and use.
1. The OP MUST enforce the account and CP bindings in (#trust-model) when accessing stored
   material.
1. These protections MUST cover persistent stores, backups, and operational access.
1. The OP MUST prevent tokens, private keys, and Claim Sets from being exposed through logs or
   diagnostics accessible to unauthorized parties.
1. The OP SHOULD encrypt sensitive stored material at rest and protect encryption keys
   separately from the data.
1. Key isolation and access controls SHOULD limit the impact of a compromised component.
1. The OP MAY store signed Claim Sets under the controls in this section.

The storage architecture, including the use of Subject-controlled encryption keys, is an
implementation choice. These safeguards do not impose a retention deadline on Claim Sets or
change the Subject's control over their disclosure.

### Subject Control of Stored Claim Sets

1. The OP MUST provide an authenticated Subject with a user interface to inspect stored Claim
   Sets and their CP sources, delete selected stored Claim Sets, and review and withdraw the
   OP's collection and RP-specific disclosure authorizations.
1. The interface MUST distinguish deletion of stored data, stopping further collection,
   stopping disclosure, and revoking a grant at the CP.
1. The OP SHOULD direct the Subject to a CP's grant-management interface when one is
   available.

No new grant-management URL metadata is defined by this specification.

4. When the Subject requests deletion, the OP MUST remove the selected Claim Sets from its
   active stores.
1. The OP MUST NOT disclose retained copies of those deleted Claim Sets.
1. The OP MUST explain the scope and timing of deletion, including any backup retention, and
   that deletion at the OP does not erase copies already delivered to RPs.
1. Before returning backup data to active use, the OP MUST apply the Subject's recorded
   deletion and withdrawal decisions so that restoration does not silently reactivate deleted
   data or withdrawn permissions.

Retained backups remain subject to (#token-and-claim-set-storage).

Deletion alone does not withdraw collection authorization; a new authorized collection can
obtain the claims again.

8. The OP MUST make that distinction clear and allow the Subject to stop further collection as
   specified in (#authorization-withdrawal-and-grant-revocation).

Withdrawal of disclosure authorization stops the corresponding disclosure, independently of
whether the Subject retains a private copy. Revoking the CP grant governs further CP access,
not the validity of previously issued Claim Sets.

9. The OP SHOULD NOT automatically recollect claims deleted by the Subject from the same CP
   without a subsequent explicit instruction from the Subject to collect those claims again.

An RP request or previously remembered disclosure consent does not by itself constitute such
an instruction.

10. The OP SHOULD offer a single operation to delete selected Claim Sets and withdraw the
    corresponding collection authorization.

Withdrawal through that operation is subject to
(#authorization-withdrawal-and-grant-revocation).

11. The OP SHOULD let the authenticated Subject review disclosure history identifying which
    RPs received which Claim Sets, their CP sources, and when disclosure occurred.
1. The OP MUST protect any retained history according to (#token-and-claim-set-storage).
1. The OP MUST apply the Subject's deletion and backup-restoration controls to the history,
   subject to applicable legal retention obligations.
1. The OP MUST exclude records retained solely to meet those obligations from ordinary
   viewing and disclosure flows.
1. The OP MUST apply the same storage protections to those records.
1. The OP MUST restrict access to those records to authorized purposes for meeting those
   obligations.
1. The OP SHOULD minimize the information retained for that history rather than retain
   complete signed JWTs solely to provide it.
1. The OP MAY let the authenticated Subject export their stored CP-signed Claim Sets without
   altering the signed JWTs.

Such export does not change their audience, account-binding, or verification requirements.

19. The OP SHOULD explain that exported artifacts remain transferable signed personal data
    with the correlation and onward-transfer risks described in
    (#correlation-and-transferable-signed-data).

This specification does not impose a retention deadline on the Subject's stored Claim
Sets. A Subject can choose to retain an expired Claim Set as a record; its retention does
not permit accepting or disclosing it as valid after `exp`. The validation requirements in
(#claims-verification) continue to apply. Storage and encryption architecture, including
Subject-controlled archival keys, remain implementation choices.

### Authorization Withdrawal and Grant Revocation

1. The OP MUST preserve the association of stored Claim Sets with the authenticated OP account
   and the CP identifiers established in (#trust-model).

Further collection from the CP is governed by the OAuth grant and token validity
requirements of [RFC6749] and [RFC6750]. Token revocation, when supported, follows
[RFC7009].

2. The OP MUST handle token errors through the applicable recovery or reauthorization
   procedure when further collection is needed.

Expiration or revocation of a CP access token, refresh token, or grant does not by itself
invalidate previously collected signed Claim Sets.

3. The OP MAY continue to disclose a stored Claim Set under the Subject's authorization if it
   satisfies the applicable signature, expiration, account-binding, and trust-policy
   requirements.

The RP applies its own acceptance and freshness policies to that Claim Set. Obtaining fresh
CP authorization or successfully calling the CP again is not a prerequisite for such use.

4. If the Subject withdraws authorization for collection or disclosure at the OP, the OP MUST
   stop the corresponding collection or disclosure until the Subject authorizes it again.
1. Withdrawal limited to a particular RP MUST stop disclosure of affected Claim Sets to that
   RP, according to the scope of the withdrawal.

The `invalid_token` error in [RFC6750] can indicate expiration, revocation, or other failure,
and the `invalid_grant` error in [RFC6749] can also have several causes. Neither error alone
establishes the scope of a revocation or the validity of a stored Claim Set. A failed
collection or refresh attempt does not by itself require suspension of disclosure of an
otherwise acceptable stored Claim Set.


### Claims Endpoint Request

The Claims Endpoint follows the protected resource rules in [RFC6749].
[RFC6750] governs bearer token presentation and errors.
[RFC9449] governs DPoP presentation and errors.
[RFC8705] governs certificate binding.

1. The OP MUST send an HTTPS POST to the CP's validated `claims_endpoint`.
2. The OP MUST use `application/json` as the request media type.
3. The OP MUST use an access token authorized for the Claims Endpoint.
4. The OP MUST send a JSON object as the request body.
5. The CP MUST reject unrecognized members at the top level of the request.
6. The CP MUST reject duplicate names at the request's top level or within its `claims` object.

The CP compares decoded member names using exact, case-sensitive equality.
An extension can define new request members and how the OP learns that the CP supports them.
The requested claim names inside `claims` follow the attribute omission rules below.

The base request carries `nonce`, `claims`, and `signing_alg`.

7. The OP MUST include a non-empty `nonce` string.
8. The CP MUST reject a request without a non-empty `nonce` string.
9. The OP MUST generate a fresh nonce for each collection operation using a cryptographically secure random number generator.
10. The OP SHOULD use at least 128 bits of random input for the nonce.
11. The OP MUST NOT reuse the RP's authentication nonce.
12. The OP MUST NOT use the nonce as evidence of Subject identity.
13. The OP MUST limit each collection operation's lifetime.

The OP establishes the following bindings before sending the request.

14. The OP MUST bind the nonce to the pending collection operation.
15. The OP MUST bind the nonce to the OP account.
16. The OP MUST bind the nonce to the CP issuer and Subject Identifier from Setup.
17. The OP MUST bind the selected `signing_alg` to the pending operation.

The following requirements apply to the request's claim and algorithm selection.

18. The OP MUST include a non-empty JSON object named `claims`.
19. The OP MUST use member names in `claims` to identify requested top-level claims.
20. The OP MUST set each requested claim's value to `null` in the base profile.
21. The OP MUST NOT request `iss`, `sub`, `aud`, `iat`, `exp`, `nbf`, or `jti` as attributes.
22. The OP MUST include a single asymmetric JWS algorithm in `signing_alg`.
23. The OP MUST select `signing_alg` from the CP's validated `claims_signing_alg_values_supported`.
24. The OP MUST select a `signing_alg` that its policy permits.
25. The CP MUST reject an unsupported `signing_alg`.

Claim-specific query syntax requires an extension. The `claims` member does not expand
the grant's permissions.

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

The base request selects top-level claims, not nested fields within a compound claim.
For example, `"claims": {"verified_claims": null}` requests that top-level claim; it does
not convey a selection of particular attributes, evidence, or timestamps within it. A CP
or trust framework can define narrow scopes or output sets for specific uses, but this
specification does not define a general nested query syntax for the Claims Endpoint.
The OP cannot remove nested fields from an already signed Claim Set while preserving the
CP signature. All disclosed contents remain subject to (#subject-granting) and
(#claims-delivery); the OP obtains a suitable Claim Set or omits it when those requirements
cannot be met.

26. The CP MUST limit returned attributes to those that the OP requests and the grant and Subject authorize.
27. The CP MAY omit requested attributes, including for privacy reasons.
28. The CP MUST NOT treat omission of an attribute as an error.
29. The CP MUST NOT imply a reason for omitting an attribute.
30. The CP MUST NOT reject an otherwise valid request solely for an unknown requested attribute name.

For example, omission can reflect attribute absence, missing verification, or a Subject's choice to withhold the attribute.
(#claims-endpoint-response) defines the empty result.

Token and scope errors follow the applicable rules in [RFC6750] and [RFC9449].

31. The CP MUST give token and scope errors precedence over JSON request errors.

The following requirements apply to malformed or unsupported requests, including invalid
request structure and unsupported `signing_alg` values.
An unrecognized top-level member or a duplicate name in either object makes the request malformed.

32. The CP MUST return HTTP 400.
33. The CP MUST use `application/json` as the error response media type.
34. The CP MUST send a JSON object as the error response body.
35. The CP MUST set `error` to `invalid_request` in that object.
36. The CP MAY include a human-readable `error_description` string in that object.

The following privacy requirement applies to all error responses.

37. The CP MUST NOT disclose the account reference, claim values, or sensitive reasons for withholding attributes in errors.

The OP repeats collection for each CP as necessary.

### Claims Endpoint Response

The following requirements apply to a successful response.

1. The CP MUST return HTTP 200.
2. The CP MUST use `application/json` as the response media type.
3. The CP MUST send `Cache-Control: no-store`.
4. The CP MUST use a JSON object as the response body.
5. The CP MUST echo the associated request's `nonce` unchanged.

The base response also carries `account_ref` and `claim_set` when it supplies attributes.

6. The CP MUST include `claim_set` when it supplies requested attributes.
7. The CP MUST encode `claim_set` as a non-empty string containing the JWT defined in (#signed-claim-set-format).
8. The CP MUST include a non-empty `account_ref` string when it includes `claim_set`.
9. The CP MUST derive `account_ref` from the account that the access token authorizes.
10. The CP MUST set `account_ref` to the Setup ID Token's `sub` for that account and OP.
11. The CP MUST NOT echo a caller-supplied account reference.
12. The CP MUST ensure that the Claim Set's attributes concern the account identified by `account_ref`.
13. The CP MUST omit `claim_set` when it supplies no requested attributes.
14. The CP MUST omit `account_ref` when it omits `claim_set`.
15. The CP MUST NOT represent an empty result with `null`, an empty string, or a protocol-only JWT.

The following successful response carries the Claim Set decoded below.
The account reference and nonce are illustrative, and the compact JWS is abbreviated.

```json
{
  "account_ref": "cp-sub-7f39",
  "nonce": "request-specific-random-value",
  "claim_set": "<CP-signed-JWT>"
}
```

If no requested attributes are supplied, the CP returns HTTP 200 with the same content
type and cache directive. In the base response, the only member is the operation nonce:

```json
{
  "nonce": "request-specific-random-value"
}
```

This empty result reports only that this collection supplied no attributes.

The decoded protected header and payload of that `claim_set` are:

```json
{"typ":"claims-aggregation+jwt","alg":"RS256"}
```

```json
{
  "iss": "https://cp.example",
  "aud": "https://op.example",
  "iat": 1893455940,
  "exp": 1893456240,
  "birthdate": "1990-01-01"
}
```

The example uses the common mandatory-to-implement algorithm `RS256`.
The `valid` test vector in [ClaimsAggregation.TestVectors] provides the complete signed
CP JWT and the signed OP presentation shown in (#claims-delivery), along with the
test keys and instructions for verifying both at 2030-01-01T00:00:00Z.
The response's cache directive prevents HTTP caching; it does not prohibit
Subject-authorized storage under (#claims-collection).

The OP applies the following checks to a purported successful response.

16. The OP MUST reject a response with a status other than HTTP 200.
17. The OP MUST reject a response without the required media type.
18. The OP MUST reject a response whose body fails the specified JSON requirements.
19. The OP MUST NOT treat a response containing `error` as a successful or empty result.
20. The OP MUST reject duplicate top-level member names using the comparison in (#claims-endpoint-request).
21. The OP MUST ignore unrecognized top-level response members other than `error`.
22. The OP MUST NOT forward ignored members to the RP.
23. The OP MUST match the decoded response nonce to the pending operation's nonce using exact, case-sensitive equality.
24. The OP MUST reject responses for expired or completed operations.
25. The OP MUST accept at most one response per operation.
26. The OP MUST NOT rebind a completed operation to a new account or operation.

Ignoring a member leaves the other validation requirements in effect.
An extension establishes OP support before the CP relies on the OP to process an extension member.
The CP does not need a global database of used nonces.

The following requirements apply when the response lacks `claim_set`.

27. The OP MUST reject the response if it contains `account_ref`.
28. The OP MUST treat a valid response without `account_ref` or `claim_set` as an empty result.
29. The OP MUST NOT establish an account binding from an empty result.
30. The OP MUST NOT change an account binding based on an empty result.
31. The OP MUST NOT store an empty result as a Claim Set.
32. The OP MUST NOT disclose an empty result as a Claim Set.
33. The OP MUST NOT infer attribute absence from an empty result.
34. The OP MUST NOT infer grant revocation from an empty result.
35. The OP MUST NOT infer Subject withdrawal from an empty result.
36. The OP MUST NOT invalidate an otherwise acceptable stored Claim Set solely because collection returns an empty result.
37. The OP MUST NOT suspend disclosure of an otherwise acceptable stored Claim Set solely because collection returns an empty result.

Claim Set validation and storage checks apply only when the response contains a Claim Set.

The OP applies the following checks when the response contains `claim_set`.

38. The OP MUST match `account_ref` exactly to the validated Setup `sub` for the operation's OP account and CP issuer.
39. The OP MUST NOT derive the expected `sub` from the response or access token.
40. The OP MUST NOT replace the expected `sub` with a value from the response or access token.
41. The OP MUST validate `claim_set` under (#claims-verification).
42. The OP MUST match the JWT's `iss` to the operation's CP issuer.
43. The OP MUST verify that the JWT contains at least one requested attribute.
44. The OP MUST verify that it requested every returned attribute.
45. The OP MUST verify that its authorization covers every returned attribute.
46. The OP MUST process the authenticated response, account reference, and exact JWT as one validation unit.
47. The OP MUST NOT recombine those inputs through an unprotected queue or cache.

(#signature-validation) specifies the check against the selected `signing_alg`.
(#token-request-and-account-binding) specifies account relinking.

48. If any response check fails, the OP MUST reject the entire response.
49. The OP MUST NOT store a Claim Set from a rejected response.
50. The OP MUST NOT disclose a Claim Set from a rejected response.

Omitting a claim from `_claim_names` cannot hide it from an RP receiving the JWT.
For these checks, attributes exclude `iss`, `aud`, `iat`, `exp`, `nbf`, and `jti`.
(#claims-verification) governs those protocol claims.

The OP preserves the validated association in a protected acquisition record.

51. The OP MUST retain a protected acquisition record for each successfully collected Claim Set.
52. The OP MUST record the OP account in the acquisition record.
53. The OP MUST record the CP issuer and Subject Identifier in the acquisition record.
54. The OP MUST record the acquisition validation result in the acquisition record.
55. The OP MUST record the acquisition validation time in the acquisition record.
56. The OP MUST protect the integrity of the acquisition record.
57. The OP MUST protect the record's association with the exact JWT.

A hash stored alongside unprotected data does not by itself provide that protection. A
deployment crossing an untrusted processing or storage boundary needs integrity protection
across that boundary. For example, an authenticated storage service can enforce this
association, or a MAC or signature can protect a record covering both the JWT and binding
fields when the storage itself is not trusted. An additional CP-signed receipt can be
defined by a profile where independent evidence of acquisition is needed. The deployment
cases and limits of that additional evidence are discussed in
(#acquisition-response-integrity).

The OP applies the following checks before redisclosing a stored Claim Set.

58. The OP MUST validate the protected acquisition record.
59. The OP MUST verify that the current authorization permits disclosure.
60. The OP MUST verify that the Subject has not deleted the Claim Set.
61. The OP MUST verify that the Subject has not withdrawn authorization for this disclosure.

(#verification-responsibilities) requires validation of the stored Claim Set before disclosure.
A successful acquisition does not waive later key, trust, expiration, or freshness checks.
Reusing a stored Claim Set does not require a new CP operation nonce or CP contact.

62. The OP MUST omit the acquisition envelope from the Aggregated Claims response.
63. The OP MUST omit `account_ref` from the Aggregated Claims response.
64. The OP MUST omit the operation nonce from the Aggregated Claims response.

#### Signed Claim Set Format

1. The CP MUST issue each Claim Set as a compact, asymmetrically signed JWS containing a JSON object.
1. The CP MUST set the protected header's `typ` to `claims-aggregation+jwt`.

[JWS] permits omission of the media type's `application/` prefix in `typ`.
This type identifies the inner Claim Set within the acquisition envelope or the OP's response.

3. The CP MUST include `iss`, `aud`, `iat`, and `exp` in the payload.
1. The CP MUST set `iss` to its validated Issuer Identifier.
1. The CP MUST set `aud` to the OP's Entity Identifier as a string or single-element array.
1. The CP MUST use [JWT] NumericDate values for `iat` and `exp`.
1. The CP MUST set `exp` to a time later than `iat`.

The OP uses its Entity Identifier as described in (#client-configuration-phase).
These timestamps describe JWT issuance and expiration. Attribute verification can occur at a different time.

8. The CP MUST omit `sub` from the Claim Set.
1. The CP MUST omit `account_ref` from the Claim Set.
1. The CP MUST omit equivalent CP account identifiers that it uses for account binding.

The Subject can authorize disclosure of identifying attributes.
(#correlation-and-transferable-signed-data) describes their correlation risks.

11. The CP MUST place claims for the RP in top-level JWT members.
1. The CP MUST sign the JWT with the `signing_alg` it accepts in the Claims Endpoint request.

The OP can reference those claims in `_claim_names` as specified in [OIDC].
The format uses no holder proof or per-presentation identifier.
It does not require a `jti` claim.

The name Claims Endpoint and the metadata names `claims_endpoint` and
`claims_signing_alg_values_supported` restore terminology from an earlier draft.
This profile separates the OP-facing account reference from the signed JWT that the RP receives.

See (#iana-considerations) for the CP metadata and Claim Set media type registration requests.

[[ Editor's note: The registration templates are defined below; formal registration has
not yet been completed. Before submission, references must identify a stable, publicly
available specification version. Previous use of a name in a draft is not a registration. ]]

### JSON Member Handling Examples

Some JSON parsers silently keep a single value for a repeated member name. Implementers
can use a parser with duplicate-name detection or check decoded names as the parser emits
them, before converting the object to a map. Checking the resulting map cannot detect
duplicates that the parser already discarded. For the response, these envelope checks
apply to the top-level JSON object. The `claim_set` string is validated separately under
(#claims-verification).

The following fragments illustrate member handling. Each fragment is added to an
otherwise valid message unless indicated.

| Message | JSON fragment or body | Expected handling |
| --- | --- | --- |
| Request with an unrecognized top-level member | `"example_option": true` | Reject with `invalid_request`. |
| Request with an unavailable attribute name | `"claims": {"example_attribute": null}` (replacing the original selection) | Process normally and omit the unavailable attribute. |
| Request with an unsupported query value | `"claims": {"birthdate": {"essential": true}}` (replacing the original selection) | Reject with `invalid_request`. |
| HTTP 200 response with an extra member | `"example_hint": "informational"` | Ignore the extra member and apply all applicable response checks. |
| HTTP 200 response with a duplicate member | `{"nonce":"first","nonce":"second"}` (entire body) | Reject the response. |
| HTTP 200 response with an error member | `{"nonce":"request-specific-random-value","error":"invalid_request"}` (entire body) | Reject the response as a successful result, including as an empty result. |

## Claims Delivery

[OIDC] governs claim destinations, omission rules, and the Aggregated Claims representation.

1. The OP MUST apply the applicable request constraints to each response.
2. The OP MUST omit `_claim_names` entries for claims it cannot supply in an authorized, valid Claim Set.
3. The OP MUST limit each embedded JWT to claims the Subject authorizes for disclosure to that RP.
4. The OP MUST replace or omit any Claim Set with claims outside the RP's disclosure authorization.
5. The OP MUST preserve mappings for other claims it returns, including Distributed Claims.
6. The OP MUST preserve the sources that those mappings reference.
7. The OP MUST omit each `_claim_sources` entry that no remaining `_claim_names` entry references.
8. If `_claim_names` would be empty, the OP MUST omit both `_claim_names` and `_claim_sources`.
9. The OP MUST NOT forward CP error details to explain an omission.
10. The RP MUST enforce its application's required-claim policy before completing the requested operation.

The RP receives all claims in the embedded JWT, including claims without a mapping in `_claim_names`.
(#authorization-withdrawal-and-grant-revocation) specifies when the OP can use previously collected Claim Sets.
The `essential` flag alone does not make an omission an authentication error under [OIDC].

For example, the RP requests `birthdate` and `address` in the ID Token:

```json
{
  "id_token": {
    "birthdate": null,
    "address": {"essential": true}
  }
}
```

The CP supplies only `birthdate`. The OP returns the following presentation.
Only `birthdate` has a `_claim_names` mapping, and the response contains only
the source referenced by that mapping. If the RP requires `address` for its
operation, it does not complete that operation.

The decoded OP presentation below embeds the same CP-signed JWT received in
`claim_set` in (#claims-endpoint-response), without changing its compact JWS
serialization. The inner JWS is abbreviated here. When the OP returns the
Aggregated Claims in an ID Token, the normal ID Token requirements still apply.

```json
{
  "iss": "https://op.example",
  "sub": "op-vector-subject",
  "aud": "rp-client",
  "iat": 1893455999,
  "exp": 1893456060,
  "_claim_names": {"birthdate": "cp1"},
  "_claim_sources": {"cp1": {"JWT": "<CP-signed-JWT>"}}
}
```

The enclosing `sub` identifies the Subject at the OP. The CP's `account_ref` and acquisition
nonce are not included in the embedded JWT or passed on as acquisition evidence to the RP.

11. The OP SHOULD return Aggregated Claims in a Token Endpoint ID Token or a UserInfo response.

This limits the front-channel exposure described in (#rp-request-integrity-and-broker-side-consent).

## Claims Verification

### Verification Responsibilities

1. The OP MUST obtain Claim Sets from the CP's Claims Endpoint.
2. The OP MUST NOT substitute a Setup ID Token, a refreshed ID Token, or a UserInfo JWT.
3. The OP MUST validate each CP-signed Claim Set when collecting it.
4. The OP MUST validate each stored Claim Set before disclosing it.
5. The RP MUST validate each embedded CP-signed JWT before accepting any claim from it.

### CP Metadata and Verification Keys

The following sources supply CP metadata and its verification keys.

- [OpenID.Discovery] supplies validated provider metadata and application keys via `jwks_uri`.
- [OpenID.Federation] supplies application signing keys in resolved `openid_provider` metadata.
- Trusted deployment configuration or a trust framework can provision metadata and keys for a CP issuer.

1. The verifier MUST obtain the CP's metadata and verification keys from one of these sources.
2. The verifier MUST select a source according to its trust policy for the CP.
3. The verifier MUST NOT substitute Federation Entity Keys for the CP's application signing keys.
4. The verifier MUST match the JWT's `iss` exactly to the CP issuer in validated metadata or trusted configuration.
5. The verifier MAY use unverified `iss` for key resolution only as its issuer acceptance and network policies permit.
6. The verifier MUST associate the CP's metadata and keys with that issuer, including in caches.
7. The verifier MUST apply the applicable validity requirements to metadata and keys.
8. The verifier MUST apply the applicable trust reevaluation requirements to metadata and keys.
9. The verifier MUST NOT rely on key discovery or signature verification alone to trust a CP for claims.
10. The verifier MUST NOT rely on prior validation if the signing key becomes unavailable or untrusted.
11. In that case, the OP MUST obtain a replacement Claim Set from the CP or omit the affected set.

The CP and verifier follow the algorithm verification rules in [RFC8725].

12. The CP MUST publish each Claim Set signing key's algorithm in every advertised JWK's `alg`.
13. The CP SHOULD keep retired public keys available through its advertised key sources until their signed Claim Sets expire.
14. The CP SHOULD include its clock-skew allowance in that key retention period.
15. The CP MAY withdraw compromised keys earlier under its deployment's key revocation policy.

### Signature Validation

[JWS] governs signature verification.

1. The verifier MUST require an asymmetrically signed JWS.
2. The verifier MUST determine its allowed algorithms before verifying the signature.
3. The verifier MUST require `alg` in both local policy and the CP's validated `claims_signing_alg_values_supported`.
4. At acquisition, the OP MUST match `alg` to the `signing_alg` bound to the collection operation.
5. The verifier MUST use a public key bound to the validated CP issuer for signature verification.
6. The verifier MUST honor key type, signing use, and algorithm restrictions when selecting a key.
7. The verifier MUST resolve any `kid` only within the CP's trusted key set.
8. The verifier MUST NOT trust a key source solely because the JWT header identifies it.
9. The verifier MUST bind each key to one algorithm using JWK `alg` or trusted issuer-specific configuration.
10. If the JWK includes `alg`, the verifier MUST match it to the JWT's `alg`.
11. The verifier MUST reject the Claim Set if it cannot establish the key's algorithm binding.

### Claim Validation

The verifier checks claims after validating the signature.
[JWT] governs time claim types, expiration, and not-before processing.

1. The verifier MUST require `claims-aggregation+jwt` in the protected header's `typ`.
2. The verifier MUST reject a Claim Set whose payload contains `sub`.
3. The verifier MUST require `iss`, `aud`, `iat`, and `exp`.
4. The verifier MUST require a non-empty string for `iss`.
5. The OP MUST validate the acquisition or stored binding under (#claims-endpoint-response).
6. The RP MUST apply its trust policy to decide whether it trusts the CP for these claims.
7. The verifier MUST require exactly one `aud` value as a string or single-element array.
8. The OP MUST match `aud` exactly to its `client_id` at the CP.
9. The RP MUST match `aud` exactly to the OP issuer it validated through OpenID Connect.
10. The verifier MUST require `exp` to be later than `iat`.
11. The verifier MUST reject a JWT with an `iat` in the future.
12. The verifier MAY allow a small clock skew when comparing times to its clock.
13. The verifier MUST apply any clock-skew allowance consistently to `iat`, `exp`, and `nbf`.

The following requirements apply when the RP receives Aggregated Claims through UserInfo.

14. The RP MUST use the validated OP issuer from the transaction that issued the access token.
15. The RP MUST NOT infer a new issuer from the CP JWT or an unsigned UserInfo response.
16. The RP MUST preserve the OP issuer's association with that access token.

The RP relies on the OP for the Subject binding described in (#trust-model).

17. The RP MUST validate the Aggregated Claims structure according to [OIDC].
18. The RP MUST apply the validation rules for each claim it uses.
19. The OP MUST reject a Claim Set that fails any required check.
20. The OP MUST NOT store an invalid Claim Set.
21. The OP MUST NOT disclose an invalid Claim Set.
22. The RP MUST NOT use claims from an invalid Claim Set.
23. The RP MUST treat claims mapped to an invalid Claim Set as unavailable.
24. The RP MAY reject the entire enclosing response.
25. Profiles MAY require rejection of the entire enclosing response.

The verification rules in (#verification-responsibilities) apply to every Claim Set the RP uses.
(#claims-delivery) specifies when the RP can complete the requested operation.

### Local Freshness Policy and User-Directed Updates

1. The RP MUST apply its application's freshness requirements before using claims.
2. The RP MAY enforce a maximum JWT age based on the CP-signed `iat`.
3. If a Claim Set is too old, the RP MUST treat its claims as unavailable for that use.
4. The RP SHOULD explain to the Subject when updated information is necessary.
5. The RP MAY direct the Subject to the OP's claim-management interface to request an update.

The Subject can retry the OpenID Connect interaction after an update.
Retrying authentication alone does not require the OP to recollect claims.
The RP applies the same verification and freshness rules to updated Claim Sets.

[IDA.Schema] defines the `verified_claims` structure.
Using it does not by itself implement the [OpenID4IDA] query protocol or external assertion format.

Implementations that support [OpenID4IDA] can use its existing request and validation mechanisms.
For example, `max_age` constrains `verification.time` or another requested date or timestamp.

6. The RP MUST evaluate assurance timestamps separately from the JWT's `iat` when it uses [OpenID4IDA] freshness constraints.
7. The OP MAY use supported constraints to select stored Claim Sets.

A new JWT does not show when the CP last verified the claims.
Meeting a verification-age requirement can require renewed verification at the CP.
Mapping constraints into a Claims Endpoint request requires a separate extension or profile.
The base `claims` object accepts only `null` values.
The OP can support [OpenID4IDA] without forwarding constraints or using them to select stored Claim Sets under this specification.
The RP applies its acceptance checks even if the OP selects a Claim Set using those constraints.
[OpenID4IDA] still governs its implementers' query, filtering, and omission behavior.

The [OpenID4IDA] external assertion format uses `typ=provided-claims+jwt` and requires `sub`.
That format prohibits `aud` and `exp`.

8. The OP MUST NOT rewrite an existing signed assertion to convert it to this profile.

Interoperability with that external assertion format requires a separate profile.


# Security Considerations

## General Security Considerations

The security considerations of [OIDC], [OpenID.Federation], and [RFC8725] apply.

The algorithm in a JWT header is untrusted until signature verification succeeds. The rules
in (#signature-validation) prevent a token from selecting an algorithm outside the verifier's
policy or causing a CP public key to be used as an HMAC secret. Issuer-specific key resolution
in (#cp-metadata-and-verification-keys) preserves the binding between a CP and its signing keys.

1. The CP SHOULD choose Claim Set lifetimes according to the sensitivity and expected rate of
   change of the claims, the intended period of pre-collection and storage, and its ability
   to retain verification keys.

Short lifetimes require more frequent collection, while long lifetimes extend the period
during which previously issued attributes can be presented. Expiration limits the lifetime
of the signed artifact. It does not guarantee that the underlying attributes remain current
or that the CP's grant remains authorized. Key withdrawal can make a stored Claim Set
unusable before its `exp`, as described in (#cp-metadata-and-verification-keys).

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
establishes a relationship for a CP identity that has never been linked at the OP. The trust
assumptions in (#trust-model) continue to apply.

## RP Request Integrity and Broker-Side Consent

The checks in (#rp-authentication-and-the-request-verification) apply to signed and unsigned requests.

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

The RP uses the OP's Issuer Identifier to check the audience of each Claim Set. This check
relies on the CP binding that `client_id` to the correct client.

1. The CP MUST establish the client as specified in (#client-configuration-phase) before
   issuing a signed Claim Set for Claims Aggregation.
1. The CP MUST NOT allow a different client to use that `client_id`, including through a
   separate registration.

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

### Operation and Response Binding

The collection nonce correlates an authenticated CP response with a pending OP operation; it
is not an access credential or an issuance-idempotency key. The CP may process a retried
request more than once, but the OP accepts at most one response for its pending operation. A
holder of a stolen bearer token can request additional Claim Sets with new nonces, so a CP
nonce database would not prevent that use. TLS server authentication and the token
protections in (#cp-token-issuance-and-use) address that threat.

1. The OP MUST validate the CP endpoint's TLS server identity.

Deployments can impose issuance rate limits without making every CP maintain a shared
nonce-replay database.

The OP binds the selected signing algorithm to the operation before sending the request
and checks the returned JWT against it. A request or response that traverses an untrusted
internal processing boundary needs integrity protection across that boundary as described
in (#claims-endpoint-response); token sender-constraining alone does not authenticate
arbitrary JSON request or response bodies across such a boundary.

### Trusted Collection and Protected Handoffs

For acquisition, the trusted collection boundary comprises the components relied on to preserve
the authenticated CP response and the independently selected operation context until validation
and protection of the resulting binding record. A deployment identifies these components and the
compromises it intends to withstand. Common ownership, an OP-managed label, or the number of TLS
connections does not by itself establish that boundary. Access controls, account and tenant
separation, and authenticated internal handoffs support its enforcement.

When a trusted OP collector receives the CP response over authenticated TLS, performs the checks
in (#claims-endpoint-response), and protects the complete account/artifact association, the base
protections are sufficient. The account check compares `account_ref` with the CP `sub` from the
validated Setup ID Token; it is not an independent Subject check inside the CP-signed JWT. A
TLS-terminating gateway can be part of that trusted collector when its preservation of the
response and context is an accepted deployment assumption. A deployment seeking protection
against compromise of that gateway instead treats it as outside the trusted acquisition
boundary.

A queue, cache, or object store outside that boundary does not alone require another CP
signature. A trusted collector can validate the response and protect the complete binding record
before handing it off, with verification at the trusted consumer. An OP MAC, signature, or
suitably bound authenticated encryption can protect the actual JWT together with its OP account,
CP identifiers, and acquisition context. Protecting only the JWT while leaving its account
association editable does not meet the binding requirement. Backup restoration also needs the
current deletion and withdrawal decisions in (#subject-control-of-stored-claim-sets); an
authentic old record alone does not establish that it is the latest authorized state.

### Additional CP-Origin Evidence

An additional CP signature can be useful when an intermediary outside the trusted collection
boundary terminates TLS and can alter plaintext before an honest OP component validates it. For
example, such an intermediary could obtain a valid Claim Set for CP account B addressed to the
same OP, containing the requested attributes and using the selected signing algorithm, then
construct an envelope with `account_ref` for account A, A's pending operation nonce, and B's
JWT. Matching `account_ref` to the expected A and checking the JWT's issuer, audience,
signature, and lifetime would not detect that substitution: the signed JWT contains no CP
Subject Identifier. Leaving `account_ref` as B would instead fail the account comparison. An OP
MAC added after the intermediary has changed the combination protects that changed combination,
not its CP origin.

Such a path needs CP-origin integrity through to the trusted validator to satisfy the existing
acquisition binding requirements. A CP-signed envelope or receipt can provide that integrity. An
authenticated connection that avoids trusting the intermediary with plaintext is another
approach. This does not make an extra receipt necessary for every TLS terminator or every stored
Claim Set.

Another use case is an independently authorized auditor that needs CP-origin evidence of the
account/artifact association rather than an OP's assertion of it. If the audit policy accepts
OP-authored records, an OP signature can suffice. If the question concerns only which attributes
the CP signed, the existing Claim Set signature already supplies that evidence. A CP-signed
receipt is useful for the additional association only when evidence from the CP is required.
This audit use is separate from normal RP disclosure; access to stable CP account references and
acquisition records requires its own authorized purpose, minimization, and retention controls.
Normal RP disclosure continues to use the trust model in (#trust-model).

### Receipt Scope and Reuse Limits

A separate receipt profile would need to bind a distinct receipt purpose, the CP issuer, the
recipient OP, the CP-derived account reference, and the acquisition operation nonce to the exact
signed Claim Set or a collision-resistant commitment with a precisely defined algorithm and byte
representation. The OP recipient is one identifier: its Entity Identifier, Issuer Identifier,
and CP-facing `client_id` are equal in this profile. A commitment to the exact compact JWS
avoids relying on reserialization of decoded claims. Omitting either the account reference or
the artifact commitment would not protect their pairing. Receipt validation would also need
trusted key and algorithm selection, pending-operation checks, and explicit handling of a
missing or stripped proof when that proof is required. The treatment of empty results would need
to be specified by that profile. This specification defines no new receipt format, parameter, or
mandatory additional CP signature.

A verified receipt establishes a statement under the accepted CP signing key and policy. It does
not prove that the CP transmitted an HTTP response, that the OP received or validated it, that
the CP's account association is truthful, or that the Subject consented to a later RP
disclosure. An issuance timestamp is not proof of delivery or of a new identity-verification
process. The protected OP account binding remains necessary; a receipt cannot by itself
reconstruct a lost association with an authenticated OP account. A receipt cannot prevent a
malicious OP from violating the trust assumptions in (#trust-model). It also cannot prevent
misuse of stolen tokens, suppression of responses, or rollback of authorization state.

A signature provides integrity and origin evidence, not confidentiality. Public-key encryption
to the OP alone does not establish CP origin, since another party can encrypt to that public
key. Deployments needing both secrecy and CP-origin integrity across an additional boundary need
an appropriate authenticated-origin and confidentiality design. Neither encrypted storage alone
nor a receipt authorizes disclosure. Acquisition receipts remain OP-facing rather than being
included in the Aggregated Claims delivered to RPs. Their storage, audit access, and backup
handling remain sensitive-data processing.

If a receipt profile defines an initial acceptance deadline, a receipt first presented after
that deadline cannot establish a new acquisition binding. Once acquisition has been validated in
time and preserved in a protected record, expiry of that deadline alone does not require CP
contact or suspend an otherwise acceptable stored Claim Set. Conversely, a receipt still within
its acceptance window does not extend the inner JWT's `exp` or waive current key, signature,
audience, trust, freshness, or Subject authorization checks. These are acquisition and storage
considerations, not a new presentation-time CP status check or a change to the grant-revocation
rules in (#authorization-withdrawal-and-grant-revocation).

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

Under the trust model in (#trust-model), the RP relies on the OP's account binding and disclosure
controls. These protections neither require per-presentation CP contact nor cause CP grant
revocation to invalidate stored Claim Sets. Storage remains under the Subject's control
within the limits described in (#freshness-and-revocation-limits).

## Freshness and Revocation Limits

The signed `iat` establishes the age of the JWT.

1. An OP collection timestamp or the enclosing ID Token's `iat` MUST NOT replace it in
   freshness checks.

A CP can issue a new JWT containing attributes verified earlier. Applications needing
freshness of identity verification or evidence can use the corresponding signed data and
validation rules in [OpenID4IDA], as described in
(#local-freshness-policy-and-user-directed-updates).

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
correlated with downstream activity.

1. The OP SHOULD explain both the correlation risk of reusing a JWT and the CP
   timing-visibility risk of obtaining updates when obtaining the Subject's authorization for
   collection and disclosure.

The Subject can then choose whether to authorize reuse or request an update, subject to the
RP's acceptance policy.

2. The OP MAY use privacy policies and rate limits when servicing user-directed updates.

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

## Registration Overview

This specification requests registration of two OAuth Authorization Server Metadata
parameters and one media type. The templates below do not indicate that registration has
already been completed.

## OAuth Authorization Server Metadata Registrations

### Registry and Template

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

[IDA.Schema] - OpenID Identity Assurance Schema Definition 1.0 incorporating errata set 1
[IDA.Schema]: https://openid.net/specs/openid-ida-verified-claims-1_0.html

[IANA.OAuth.Parameters] - IANA OAuth Parameters
[IANA.OAuth.Parameters]: https://www.iana.org/assignments/oauth-parameters/

[IANA.MediaTypes] - IANA Media Types
[IANA.MediaTypes]: https://www.iana.org/assignments/media-types/

[SD-JWT] - RFC 9901 - Selective Disclosure for JSON Web Tokens
[SD-JWT]: https://www.rfc-editor.org/rfc/rfc9901.html

[OAuth.Security.Update] - Updates to OAuth 2.0 Security Best Current Practice, draft-ietf-oauth-security-topics-update-03, Work in Progress
[OAuth.Security.Update]: https://www.ietf.org/archive/id/draft-ietf-oauth-security-topics-update-03.html

[ClaimsAggregation.TestVectors] - Claims Endpoint prototype and reproducible RS256 test vectors
[ClaimsAggregation.TestVectors]: https://github.com/sakimura/claims-endpoint-prototype/tree/f5f6be8e5e7e3853711a02952f754a93ec4c3963

# Notices

Copyright (c) 2026 The OpenID Foundation.

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

* Clarified Claims Endpoint JSON member handling and nonce generation
* Explained acquisition trust boundaries, optional CP-origin evidence, and receipt limitations
* Clarified compound-claim selection and the boundaries of identity assurance schema, queries, and assertions
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
* Defined the OP's role in Subject binding and described the risk of cross-user claim substitution
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
