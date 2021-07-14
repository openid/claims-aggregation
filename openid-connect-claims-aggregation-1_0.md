%%%
title = "OpenID Connect Claims Aggregation"
abbrev = "oidc-ca"
ipr = "none"
workgroup = "connect"
keyword = ["security", "openid", "w3c verifiable credential", "did", "privacy"]

[seriesInfo]
name = "OpenID-Draft"
value = "fapi-2_0-baseline-00"
status = "standard"

[[author]]
initials="N."
surname="Sakimura"
fullname="Nat Sakimura"
organization="NAT.Consulting"
    [author.address]
    email = "nat@nat.consulting"

[[author]]
initials="J."
surname="Edmund"
fullname="Jay Edmund"
organization="Illumila"
    [author.address]
    email = "ejay@nillumi.la"

%%%

.# Abstract 

OpenID Providers within OpenID Connect assume many roles, one of these is providing End-User claims to relying parties at the consent of the End-User such as their name or date of birth. OpenID Connect defines multiple models under which claims are provided and relied upon by a relying parties, including simple, aggregated and distributed claims. This document focuses on elaborating upon the aggregated model outlined in section 5.6.2 of OpenID Connect core by defining the full life-cycle of aggregated claims and the new roles of the entities involved in an aggregated claims model.

.# Warning

This document is not an OIDF International Standard. It is distributed for review and comment. It is subject to change without notice and may not be referred to as an International Standard.

Recipients of this draft are invited to submit, with their comments, notification of any relevant patent rights of which they are aware and to provide supporting documentation.

.# Copyright notice & license

The OpenID Foundation (OIDF) grants to any Contributor, developer, implementer, or other interested party a non-exclusive, royalty free, worldwide copyright license to reproduce, prepare derivative works from, distribute, perform and display, this Implementers Draft or Final Specification solely for the purposes of (i) developing specifications, and (ii) implementing Implementers Drafts and Final Specifications based on such documents, provided that attribution be made to the OIDF as the source of the material, but that such attribution does not indicate an endorsement by the OIDF.

The technology described in this specification was made available from contributions from various sources, including members of the OpenID Foundation and others. Although the OpenID Foundation has taken steps to help ensure that the technology is available for distribution, it takes no position regarding the validity or scope of any intellectual property or other rights that might be claimed to pertain to the implementation or use of the technology described in this specification or the extent to which any license under such rights might or might not be available; neither does it represent that it has made any independent effort to identify any such rights. The OpenID Foundation and the contributors to this specification make no (and hereby expressly disclaim any) warranties (express, implied, or otherwise), including implied warranties of merchantability, non-infringement, fitness for a particular purpose, or title, related to this specification, and the entire risk as to implementing this specification is assumed by the implementer. The OpenID Intellectual Property Rights policy requires contributors to offer a patent promise not to assert certain patent claims against other contributors and against implementers. The OpenID Foundation invites any interested party to bring to its attention any copyrights, patents, patent applications, or other proprietary rights that may cover technology that may be required to practice this specification.

.# Foreword

The OpenID Foundation (OIDF) promotes, protects and nurtures the OpenID community and technologies. As a non-profit international standardizing body, it is comprised by over 160 participating entities (workgroup participants). The work of preparing implementer drafts and final international standards is carried out through OIDF workgroups in accordance with the OpenID Process. Participants interested in a subject for which a workgroup has been established has the right to be represented in that workgroup. International organizations, governmental and non-governmental, in liaison with OIDF, also take part in the work. OIDF collaborates closely with other standardizing bodies in the related fields.


.# Introduction

OpenID Connect is a selective claims disclosure mechanism. When a set of claims included in its response is about 
an entity authentication event, it works as an entity authentication federation mechanism, but it can deliver 
other claims selected by the subject as well. 

In the OpenID Connect specification, it is assumed that there are many sources of claims. 
Each claim is associated with its authoritative source so there naturally will be many authoritative sources. 
Claim sources can be corroborative, i.e., not authoritative, as well. 
In total, there will be many Claim Set sources in OpenID Connect Framework. 
These Claim sources are called Issuing Authorities in OpenID Connect. 
Issuing Authority (IA) is just an Identity Wallet (IW) but it does not provide the claims about the current authentication event 
and its associated subject identifier authoritatively. Note that Issuing Authority can act as an Identity Wallet in other transactions. 
Whether it is called IW or IA is depending on their role in a particular transaction. 

There are four main actors in OpenID Connect using an aggregation model. 

1. Subject (User)
1. Identity Wallet (IW) that provides claims about the subject authentication event and provides signed claim sets obtained from other Issuing Authorities
1. Issuing Authorities (IA) that provides other claims
1. Claims Consumer (CC) that verifies and consumes the provided claim sets. 

An IW can provide an CC the claims by value or by reference. 

By value is the case where an IW collects claims and their values 
from IAs and aggregate them in one package to provide to the CC. 
This model is called Aggregated Claims Model. 

By value is the case where the IW does not collect and provide the value 
but just provide the reference and its access information to the CC. 
This model is called Distributed Claims Model. 

In either case, there has to be strong binding between the subject 
in the claim sets provided by IAs and the subject in the ID Token provided by the IW. 
Conceptually, it can be done through Subject value correlation or 
through the correlation of signing key materials. 
Regardless of the methods, there has to be this binding. 
Otherwise, the provided claims cannot be trusted to be linked to the authenticated subject. 

This document defines how to do this binding even in the case of ephemeral subject identifier 
in which case the `sub` value of the ID Token will change every time the subject visits the CC. 
This allows anonymous attribute based authentication where an CC cannot link two visits 
by the subject without using other facilities. 

By supporting the case of epehemeral subject identifier, pairwise pseudonymous identifier 
and omni-directional identifier cases are also covered. 

Another feature that this document provides is the way to avoid multipe consent screen 
per CC authorization request. If OpenID Connect Core spec is used to build Aggregated Claims Model 
naively, it may results in many consent screens per CC request. 
For example, if four IAs and one IW is involved in the request, then, there may be five consent screens. 
This is too onerous. This document defines a mechanism to consolidate it into one consent screen. 
This is done through one "IW User Setup Phase" per IA that the IW obtains the consent 
from the subject to obtain claims from the IA for the purpose of creating aggregated and distributed 
claims response for future CC requests in which IW will collect a new consent from the subject. 

The mechanism used for this is to obtain an access token and a refresh token that corresponds 
to a suitably wide scope for the purpose. While the claims at the time of an CC request can be 
obtained from the UserInfo endpoint, this document defines a new endpoint called claims endpoint. 
It is almost the same as the UserInfo endpoint, but there are a few important differences: 

1. It allows collection minimization by supporting claims parameter. 
1. It allows an identifier to correlate the claims it is returning and the ID Token the IW provides. 
1. It include the `iss` claim. (Userinfo Endpoint does not)
1. It returns signed response. 
1. It allows multiple schema types for its response. (e.g, JWT and W3C Verifable Credentials formats)

Note that while Userinfo Endpoint was conceived to support multiple response types, 
e.g., support for SCIM schema, 
the exact method was not specified at the time of the publication. 

This new Claims Endpoint allows the specification of the response schema and media type, 
e.g., OIDC JWT, OIDC4IDA JWT, W3C Verifiable Claims in JWT and JSON-LD, SCIM 2.0 in JWT, etc. 
It is done so in an extensible manner (using registry tbd). 

This implies that there will be an impact to the authentication and claims request that an CC makes. 
It may optionally want to specify its prefered format for the Claim Sets to be received. 
Therefore, this document also defines a new parameter to express its preference. 

There are four phases defined in this document. 

1. IA Discovery Phase: IW discovers IA metadata. 
1. IW Registration Phase: IW registers to IA as an CC. 
1. Setup Phase: IW obtains the access and refresh tokens from IA by the permission of the subject. 
1. CC Phase: 
    1. CC makes autentication and claims request, 
	1. IW fetches relevant claim sets from IAs, 
	1. IW respond to the CC
	1. the CC verifies the response. 

Note that distribued claims model is out of scope of this document. 

Intended reader of this document is the developer and systems architect who builds attributes and claims base systems. 



.# Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" in this document are to be interpreted as described in BCP
14 [RFC2119] [RFC8174] when, and only when, they appear in all
capitals, as shown here.

{mainmatter}

## Scope

This document specifies the methods for

* an IW acting as a client of Issuing Authority (IA) to perform discovery for a Issuing Authority Metadata;
* the IW to perform client registration to the Issuing Authority;
* the IW to obtain claims from the Issuing Authority; 
* an CC to ask for verified claims to the IW;  
* the IW to return obtained claims from IA to the CC; and 
* the CC to verify the claims.

## Normative references
The following referenced documents are indispensable for the application of this document. For dated references, only the edition cited applied. For undated references, the latest edition of the referenced document (including any amendments) applies.

[BCP14] - Key words for use in RFCs to Indicate Requirement Levels
[BCP14]: https://tools.ietf.org/html/bcp14

[RFC6749] - The OAuth 2.0 Authorization Framework
[RFC6749]: https://tools.ietf.org/html/rfc6749

[RFC6750] - The OAuth 2.0 Authorization Framework: Bearer Token Usage
[RFC6750]: https://tools.ietf.org/html/rfc6750

[RFC7636] - # Proof Key for Code Exchange by OAuth Public Clients
[RFC7636]: https://tools.ietf.org/html/rfc76360

[BCP212] - OAuth 2.0 for Native Apps
[BCP212]: https://tools.ietf.org/html/bcp212

[RFC6819] - OAuth 2.0 Threat Model and Security Considerations
[RFC6819]: https://tools.ietf.org/html/rfc6819

[BCP195] - Recommendations for Secure Use of Transport Layer Security (TLS) and Datagram Transport Layer Security (DTLS)
[BCP195]: https://tools.ietf.org/html/bcp195

[OIDC] - OpenID Connect Core 1.0 incorporating errata set 1
[OIDC]: https://openid.net/specs/openid-connect-core-1_0.html

[OpenID.Discovery] - OpenID Connect Discovery 1.0
[OpenID.Discovery]: https://openid.net/specs/openid-connect-discovery-1_0.html

[OpenID.Registration] - OpenID Connect Registration 1.0
[OpenID.Registration]: http://openid.net/specs/openid-connect-registration-1_0.html

[OpenID.IDA] - OpenID Connect for Identity Assurance 1.0
[OpenID.IDA]:https://openid.net/specs/openid-connect-4-identity-assurance-1_0-ID1.html

[MTLS] - OAuth 2.0 Mutual TLS Client Authentication and Certificate Bound Access Tokens
[MTLS]: https://tools.ietf.org/html/draft-ietf-oauth-mtls

[JWT] - JSON Web Token
[JWT]: http://tools.ietf.org/html/draft-ietf-oauth-json-web-token

[JWS] - JSON Web Signature
[JWS]: http://tools.ietf.org/html/draft-ietf-jose-json-web-signature

[JWE] - JSON Web Encryption
[JWE]: http://tools.ietf.org/html/draft-ietf-jose-json-web-encryption

[JWA] - JSON Web Algorithms
[JWA]: http://tools.ietf.org/html/draft-ietf-jose-json-web-algorithms


## Terms and definitions
For the purpose of this document, the terms defined in [RFC6749], [RFC6750], [RFC7636], [OpenID Connect Core][OIDC] apply.

## Symbols and abbreviated terms

**CC** – Claims Consumer

**IW** – Identity Wallet

**IA** – Issuing Authority

**HTTP** - Hyper Text Transfer Protocol

**TLS** - Transport Layer Security

**W3c** - World Wide Web Consortium

**VC** - W3C Verifiable Credential

**VP** - W3C Verifiable Presentation

**DID** - Decentralized Identifier

## Actors

In this document, there are four main actors. 

1. Subject (User)
1. IA
1. IW 
1. CC that verifies and consumes the provided claim sets. 

They are topologically connected as in the following diagram.

!---
~~~ ascii-art
               +---------+
    +----------| Subject |--------+
    | grants   +---------+        |
    v               |             |
+------+            | instructs   | allows
|  IA  |----+       |             |
+------+    |       v             v
   .        |    +------+     +------+
   .        |----|  IW  |-----|  CC  | 
   .        |    +------+     +------+
+------+    |
|  IA  |----+
+------+  

~~~
Figure: Relationships among actors


### Subject (User)

Subject is the entity that grants access to the claims at IAs and the IW. 
In this system, the Subject grants IA to provide IW the Claims for 
the purpose of providing those claims with other claims to potentially 
unspecified CCs under the Subject's direction. 

This request from the IW to the IA is sent by the Subject's instruction. 
The Subject also allows IW to potentially store the obtained claims. 

The Subject also allows CC to make a claims request to the IW, 
typically for the Subject to receive some services from the CC. 

### CC

CC is an actor that typically provides some service to the Subject. 
To perform the service, the CC obtains some claims about the Subject from IW. 
The basis for the processing of the Subject's claims by the CC can be 
performance of contract, consent, and other lawful basis. 

### IA

IA, Issuing Authority, is a role assumed by an Identity Wallet 
that supports signed claims according to this document.  
Specifically, it supports an extension to bind the 
authentication response that CCs received from the IW 
to the claim sets that it provides. 

The provision for the Issuing Authority are as follows: 

1. It MUST implement Claims Endpoint. 
1. It MUST support the issuance of Access Tokens and Refresh Tokens for the Claims Endpoint. 
1. It MUST support the Discovery Metadata extension defined by this document. 
1. It MUST support the registration of the IWs with extensions defined in this document. 
1. It SHOULD support the registration of the IWs through Dynamic Registration. 

#### Claims Endpoint
The Claims Endpoint is an OAuth 2.0 Protected Resource that returns Claims about the authenticated Subject. 
To obtain the requested Claims about the Subject, 
the IW acting as a Client makes a request to the Calims Endpont of the IA using an Access Token obtained through OpenID Connect Authentication. 
These Claims can be represented in variety of format as requested. 

This document defines the following request parameters for the Claims Endpoint request:

- *uid*  String value which identifies the end-user at the Client. The value is described in 5.3.2 of this specification. If this parameter is not supplied, the *uid* claims value MUST be supplied in the *claims* parameter.
- *claims*  This parameter is used to request that specific Claims be returned. This is a JSON object with only the *c_token* top-level member defined in 5.3.2 of this specification. The *c_token* member requests that the listed individual Claims be returned from the Claims Endpoint. The requested claims MUST only be a subset of the claims bounded to the Access Token as requested in the Authentication Request's *scope*, *claims*, or *request* or *request_uri* parameters. The *c_token* member MUST contain the *uid* claim value if the *uid* request parameter is not supplied.
- *aud*  JSON object containing a string array of client identifiers that will be added as additional *aud*  (audience) claims for the resulting JWT response from this endpoint. (Editor's NOTE: This point needs more discussion.)

** Editor's NOTE ** Is there a way to specify the CCs that are registered to the IW? 

The provision for the Claims Endpoint are as follows: 

1. It MUST implement `uid`, `claims`, and `aud` as defined above. 
1. It MUST implement OIDC4IDA response encoded in JWS signed JWT as its response. 
1. It SHOULD support W3C Verified Credentials in JWT or JSON-LD representation as its response. 
1. It MAY support other response format as advertised in the Discovery response. 
1. It MUST enforce TLS for request and response. See  [Section 16.17](https://openid.net/specs/openid-connect-core-1_0.html#TLSRequirements)  for more information on using TLS.
1. It MUST support the use of the HTTP  GET  and HTTP  POST  methods defined in  [RFC 2616](https://openid.net/specs/openid-connect-core-1_0.html#RFC2616)  [RFC2616].
1. It MUST accept Access Tokens as  [OAuth 2.0 Bearer Token Usage](https://openid.net/specs/openid-connect-core-1_0.html#RFC6750)  [RFC6750].
1. It SHOULD support the use of  [Cross Origin Resource Sharing (CORS)](https://openid.net/specs/openid-connect-core-1_0.html#CORS)  [CORS] and or other methods as appropriate to enable Java Script Clients to access the endpoint.

** EDITOR'S NOTE ** I guess there are other provisions. The above probably needs to be tweaked as well. 


### IW

IW is an entity that acts as an Identity Wallet to the CC. 
Also, IW acts as a Claims Consumer to IAs. 

The provision for the IW is as follows: 

1. It MUST support OpenID Connect Aggregated Claims as an Identity Wallet. 
1. It MUST act as an OpenID Connect Claims Consumer to IAs to fetch claims from IAs according to instructions given by the Subject. 
1. As an Identity Wallet, IW MUST implement mandatory to implement extensions that this document defines. 
1. It MAY store the signed claims obtained from IAs with appropriate safeguarding controls. 
1. To the authenticated Subject, it MUST provide a user interface to show what claims about the subject it stores. 
1. It MUST NOT provide claims to CCs without the Subject's permission. 
1. It MUST implement `c_token` authentication request parameter as a mechanism to request claims to IAs. 

** EDITOR'S NOTE ** I guess there are other provisions. 

#### c_token 

`c_token` Authoriaztion Request parameter lists individual Claims 
that the IW asks the IA to be returned from the Claims Endpoint. 
This top-level member is a JSON object with the names of the individual Claims being requested 
as the member names and the values are defined as in 5.5.1 of OpenID Connect 1.0 [OIDC].

## Discovery Phase

Before registering it self as an OAuth Client to a IA, the IW needs to obtain 
configuration information from the IA, 
including its Authorization Endpoint and Token Endpoint locations. 

This information is obtained via Discovery, as described in OpenID Connect Discovery 1.0 [OpenID.Discovery], or may be obtained via other mechanisms.

This document adds the following Identity Wallet Metadata to the OpenID Connect Discovery 1.0 [OpenID.Discovery] response: 

* `claims_endpoint` **Required**. Claims Endpoint. URL at the Issuing Authority that provides signed claims.
* `claims_signing_alg_values_supported` **Optional**. JSON array containing a list of the  JWS [JWS] signing algorithms (alg values) JWA [JWA] supported by the Claims Endpoint to encode the Claims in a  JWT [JWT]. The value *none* MUST NOT be included.
* `claims_encryption_alg_values_supported` **Optional**. JSON array containing a list of the  JWE [JWE] encryption algorithms (alg values) JWA [JWA] supported by the Claims Endpoint to encode the Claims in a JWT [JWT]. 
* claims_encryption_enc_values_supported` **Optional**. JSON array containing a list of the  JWE [JWE] encryption algorithms (enc values) JWA [JWA] supported by the Claims Endpoint to encode the Claims in a JWT [JWT]. 

Additionally, the following optional OpenID Connect Discovery 1.0 [OpenID.Discovery] parameters are now required in the Issuing Authority Metadata:

- `claim_types_supported`. The JSON array MUST contain the values *normal*, and *distributed* (client only).
- `claims_supported`. A JSON array containing a list of the Claim Names of the Claims that the Identity Wallet MAY be able to supply values for.
- `claims_parameter_supported`. The value MUST be *true* to support the *claims* request parameter.
- `request_parameter_supported`. The value MUST be *true* to support the *request* request parameter.
- `request_uri_parameter_supported`. The value MUST be *true* to support the *request_uri* request parameter.

If the IA supports OpenID Connect for Identity Assurance 1.0 [OpenID.IDA], 
the supported OpenID Connect for Identity Assurance 1.0 [OpenID.IDA] features MUST be published 
as specified in section 7 of OpenID Connect for Identity Assurance 1.0 [OpenID.IDA].

If the IA suppports W3c Verifaiable Credeintial, the IA MUST advertise it with the following metadata: 

** Editors Note: Tobias, could you fill in here? **

If the IA supports mDL format, the IA MUST advertise it with the following metadata: 

** Editors Note: Tony or Kristina, could you fill in here? **

If the IA supports SCIM fromat, the IA MUST advertise it with the following metadata: 

** Editors Note: SCIM experts, could you fill in here? **

## Registration Phase

Before starting to make requests to a IA, the IW MUST register itself to the IA. 
The registration SHOULD be performed 
via Dynamic Registration, as described in OpenID Connect Dynamic Client Registration 1.0.  

This documents adds the following Client Metadata to the OpenID Connect Dynamic Client Registration :

`claims_signed_response_alg` **Required**. JWS `alg` algorithm JWA [JWA] REQUIRED for signing Claims Responses. The value *none* MUST NOT be used. If this is specified, the response will be JWT [JWT] serialized, and signed using JWS. The default, if omitted, is `RS256`.

`claims_encrypted_response_alg` **Optional**. JWE `alg` algorithm JWA [JWA] REQUIRED for encrypting Claims responses to the client. If both signing and encryption are requested, the response will be signed then encrypted, with the result being a Nested JWT, as defined in JWT [JWT]. The default, if omitted, is that no encryption is performed.

`claims_encrypted_response_enc` **Optional**. JWE `enc` algorithm JWA [JWA] REQUIRED for encrypting Claims responses. If `claims_encrypted_response_enc` is specified, the default for this value is `A128CBC-HS256`. When `claims_encrypted_response_enc` is included, `claims_encrypted_response_alg` MUST also be provided.

Authentication requests to the Issuing Authority's Authorization Endpoint should be signed or signed and encrypted. In order to support a more diverse set of claims, requests for claims should be made using  Request Objects which are signed or signed and encrypted by registering the appropriate values for the following Client Metadata registration parameters:

- `request_object_signing_alg`
- `request_object_encryption_alg`
- `request_object_encryption_enc` 


## Setup Phase

** Editor's NOTE: Not sure if c_token is really needed. ** 

In this phase, the IW obtains an access token (and optionally refresh token) 
that is bound to the current user so that the IW can obtain the claims about the current user 
from the IA subsequently without taking the user to the IA and show them the consent dialogue for every CC requests.

1. This has to be done at least once for each IA that a user of an IW who wishes to use the facility this document explains.
1. To obtain the grant, the IW MUST use OpenID Connect Authentication Request. 
1. The Claims to be granted MUST be specified with `c_token` parameter. 

The IA MUST show a dialogue to the Subject explaining that the IW will be 
getting signed claims set from this IA as appropriate to provide claims to CCs as directed 
by the Subject. 

The dialogue MUST provide the link to the `policy_url` provided by the IW during its registration. 

The actual act of granting MUST involve active user interaction. 

The grant that is to be obtained in this phase SHOULD be sufficiently large so that it will reduce the 
number of times that IW needs to take the Subject to the IA to obtain additional grants. 

## Delivery Phase (CC Phase)

In Delivery Phase, the claims are delivered to CC. 
To do so, it typically goes through the following steps: 

1. (Claims Request) An CC makes an OpenID Connect Authentication Request with extension parameters defined in this document to the IW. 
1. (Request Verification) The IW verifies if the request is valid. 
1. (Subject Granting) The IW shows dialogue to the Authenticated Subject if it grants the access to the claims and obtains grant from the Subject. 
1. (Claims Collection) The IW accesses relevant Claims Endpoints with Access Tokens to collect signed claims. 
1. (Claims Delivery) The IW delivers the collected claims through ID Token, UserInfo endpoint, and/or Claims Endpoint if it supports. 
1. (Claims Verification) The CC verifies the recieved response. 

Claims Collection MAY be done out of sync. That is, the signed claim sets can be obtained before the CC requests. 
This is typically the case when claims are provided through the W3C Verifiable Credentials container. 

### Claims Request by CC to IW

For an CC to request claims according to this document, the CC 

1. MUST use the OpenID Connect Authentication Request with extension parameters defined in this document to the IW; and 
1. MAY use Pushed Authorization Request. 

### CC authentication and the request verification

Upon receit of the request, the IW 

1. MUST verify that the request is not tampered and is from a valid registered CC if the request is signed; and 
1. MUST at least verify that the client_id is valid and make sure 
   that the autorization code that it is going to return will be bound to this client_id if the request is not signed. 

NOTE: CC MUST be authenticated at one point or another before completion of the transaction. 

### Subject Granting

After verifying the request, the IW 

1. MUST authenticate the Subject if it has not yet been; 
1. MUST show the Subject what is being requested from the CC; 
1. MUST show the Subject the link to the CC provided policy_url; and 
1. MUST obtain grant from the Subject through explicit action. 

### Claims Collection

The IW collects the required claims from relevant Claims Endpoints. 
This process can be performed before the CC's request. 

#### Claims Endpoint Request

For claims collection, the IW 

1. MUST send OAuth protected resource request to the Claims Endpoint using previously obtained Access Token; 
1. MUST send `claims` parameter to minimize the collected claims to what is necessary; 
1. MUST send `uid` parameter if binding between the claim set and the response to the CC is sought; and 
1. SHOULD send `aud` parameter. 

Addionally, 

1. The OAuth protected resource request SHOULD be protected by MTLS. 
1. It is RECOMMENDED that the request use the HTTP  GET  method and the Access Token be sent using the Authorization  header field.

The following is a non-normative example of a Aggregation Request:

```
      GET /c_token?claims={"aggregation":{"uid":"id8837395937","email":{"essential":true},"email_verified":{"essential":true}}}&aud={["client1234"}      
      HTTP/1.1
      Host: server.example.com
      Authorization: Bearer SlAV32hkKG
```

The process will be repeated to as many Claims Endpoints as necessary. 

#### Claims Endpoint Response

Upon receit of the request, the Claims Endpoint Response 

1. MUST be signed or signed and encrypted;
1. MUST NOT contain other claims than asked; 
1. MAY ommit claims if not appropriate or available in which case the claim name MUST be omitted;
1. MUST provide correct content-type of the HTTP response; and 
1. MUST contain `aud` claim with is value a subset of what was in the request; 

**Editors Note** The above is specific to OIDC JWT and need to be expanded to accomodate VC etc. 

If the response is a JWS signed JWT, the Claims Endpoint Response 

1. MUST contain iss that is set as the IA's Issuer Identifer URL; 
1. MUST contain *op_iss* claim whose value is the IW's issuer identifier URL registered to the IA; 
1. MUST contain *sub* claim that is set to the *uid* claim value if it was in the request; 

NOTE: the combination of *op_iss* and *sub* is used to correlated to the IW response to the CC later. 

The following is a non-normative example of a Aggregation Response:

```
  To be provided. 

```

#### Claims Endpoint Error Response
 When an error condition occurs, the Claims Endpoint returns an Error Response as defined in Section 3 of  [OAuth 2.0 Bearer Token Usage](https://openid.net/specs/openid-connect-core-1_0.html#RFC6750)  [RFC6750]. (HTTP errors unrelated to RFC 6750 are returned to the User Agent using the appropriate HTTP status code.)

The following is a non-normative example of a Aggregation Error Response:

```
    HTTP/1.1 401 Unauthorized
      WWW-Authenticate: error="invalid_token",
        error_description="The Access Token expired"
```

#### Claims Endoint Verification

Upon receit of the response, the IW 

1. MUST verify ... 
 
### Claims Delivery

Once the necessary claim sets were collected, 
the IW creates the Aggregated Claims response to be returned. 

The response can be returned as ID Token or Userinfo Response ( or Claims Endpoint Response). 

The aggreated claims response is constructed as follows: 

1. The overall container format complies to what is described in 5.6.2 of OpenID Connect 1.0 [OIDC].
1. If the claim set was obtained as JWT, then it MUST be stored in the corresponding "JWT" member of the aggregated claims. 
1. If the claim set was obtained as W3c Verifiable Credential, then it MUST be stored in the corresponding "verifiable_presentations" member of the aggregated claims. 
1. If the claim set was obtained in other format, then ...


### Claims Verification

For Claims Verification,  

1. the CC MUST verify the signature of the Aggregate Claim according to  [JWS] using the algorithm specified in the JWT  *alg*  Header Parameter the keys provided by the Issuer of the Aggregate Claim for the signature verification; 
1. the CC MUST extract the signed claims from JWT and other relevant members and verify according to their verification rule; 
1. the CC MUST verify that issuers of the signed claims in the aggregated claims are the ones it trust; 
1. the CC MUST verify that `op_iss` and `uid` values in the signed claims match the `iss` and `sub` value of the response; 
1. the CC MUST verify that the  aud  (audience) Claim contains its  client_id  value registered at the Issuer identified by the  iss  (issuer) Claim as an audience; 
1. The CC MUST verify that the aud claim does not contain claim values not trusted by the CC; and 
1. The CC MUST reject the response if any of the verification above fails. 

# Security Considerations

TBD

# Privacy Considerations

TBD

{backmatter}
