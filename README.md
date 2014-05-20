stormkeeper
===========

Manages auth tokens provided by the BiS component

*List of stormkeeper APIs*
========================

<table>
<tr>
<th>Method</th><th>URI</th><th>Description</th>
</tr>
<tr>
<td>POST</td><td>/rules</td><td>Create a rule entry and respond with rule UUID</td>
</tr>
<tr>
<td>GET</td><td>/rules</td><td>Get details of all rules defined for each role</td>
</tr>
<tr>
<td>GET</td><td>/rules/:id</td><td>Get details of a specific rule</td>
</tr> 
<tr>
<td>DELETE</td><td>/rules/:id</td><td>Delete a specific rule</td>
</tr>
<tr>
<td>POST</td><td>/tokens</td><td>Create a token entry and respond with token UUID</td>
</tr> 
<tr>
<td>GET</td><td>/tokens/:id</td><td>Get details of a specific token</td>
</tr>
<tr>
<td>DELETE</td><td>/tokens/:id</td><td>Delete a specific token</td>
</tr>
<tr>
</table>

**POST Rules API**

Verb      URI                       Description
POST      /rules                    Creates the Rules configuration.

On success it returns JSON data with the UUID with the rules configuration.

**Example Request and Response**

### Request JSON

{
	"name":"admin1",
	"rules":["POST /domains/:id/policies”,"PUT /domains/:id/policies/:id”,"GET /domains/:id/policies”,"POST /domains/:id/metapolicy/:id/groups”], 
	"role":"admin"
}

### Response JSON

{
	"id": "83997da9-63d7-46e6-aea0-7a44e8ce951b",
	"data": {
		"name": "admin1",
		"rules": [
			"POST /domains/:id/policies",
			"PUT /domains/:id/policies/:id",
			"GET /domains/:id/policies",
			"POST /domains/:id/metapolicy/:id/groups"
		],
		"role": "admin"
	},
	"saved": true
}

**GET List API**

Verb       URI                      Description
GET        /rules                   List summary of rules configured.

**Example Request and Response**
### Request Headers
GET http://stormkeeper:8333/rules

### Response JSON

[
{
	"id": "05686306-0db7-4bd2-98fb-19a0e0440f19",
	"data": {
		"name": "specific",
		"rules": [
			"POST /domains/:id/policies",
			"PUT /domains/:id/policies/:id",
			"GET /domains/:id/policies",
			"POST /domains/:id/metapolicy/:id/groups"
		],
		"role": "admin",
	},
	"saved": true
},
{
	"id": "3daeffb0-d83d-43a6-ab9c-e56600be677b",
	"data": {
		"name": "specific",
		"rules": [
			"GET /agents/serialkey/:key",
			"GET /agents/:id/bolt",
			"POST /agents/:id/csr"
		],
		"role": "agent",
	},
	"saved": true
},
{
	"id": "063c8c14-dec2-4859-9a96-a413b06f1e0d",
	"data": {
		"name": "super",
		"rules": [
			"*"
		],
		"role": "super-admin"
	},
	"saved": true
},
{
	"id": "83997da9-63d7-46e6-aea0-7a44e8ce951b",
	"data": {
		"name": "admin1",
		"rules": [
			"POST /domains/:id/policies",
			"PUT /domains/:id/policies/:id",
			"GET /domains/:id/policies",
			"POST /domains/:id/metapolicy/:id/groups"
		],
		"role": "admin"
	},
	"saved": true
}
]

**GET List API**

Verb       URI                      Description
GET        /rules/:id             	List summary of a specific rule.

**Example Request and Response**

### Request Headers
GET http://stormkeeper:8333/rules/:id

### Response JSON

{
	"id": "83997da9-63d7-46e6-aea0-7a44e8ce951b",
		"data": {
			"name": "admin1",
			"rules": [
				"POST /domains/:id/policies",
				"PUT /domains/:id/policies/:id",
				"GET /domains/:id/policies",
				"POST /domains/:id/metapolicy/:id/groups"
			],
			"role": "admin"
		},
		"saved": true
}


**DELETE Rules API**

Verb      URI                           Description
DELETE   /rules/:id                     Delete existing rules configuration by ID.

**Example Request and Response**

### Request Headers
DELETE http://stormkeeper:8333/rules/:id

### Response Header

Status Code : 204 No Content



**POST Tokens API**

Verb      URI                       Description
POST      /tokens                   Creates the Tokens configuration.

On success it returns JSON data with the UUID with the tokens configuration.

**Example Request and Response**

### Request JSON

{
"name":"token1",
"domainId":"abcdc127-bf53-44a6-9bc4-46e0d293efgh", 
"identityId":"ijklc127-bf53-44a6-9bc4-46e0d293mnop",
"ruleId":"05686306-0db7-4bd2-98fb-19a0e0440f19",
"validity":300,
"lastModified":"timestamp",
"userData":[{"accountId":"qrstc127-bf53-44a6-9bc4-46e0d293zkmn","userEmail":"sbusa@clearpathnet.com"}]
}

### Response JSON

{
	"id": "8d41e531-519b-40cc-88cd-9abe95498ef1",
	"data": {
		"name": "token1",
		"domainId": "abcdc127-bf53-44a6-9bc4-46e0d293efgh",
		"identityId": "ijklc127-bf53-44a6-9bc4-46e0d293mnop",
		"ruleId": "05686306-0db7-4bd2-98fb-19a0e0440f19",
		"validity": 300,
		"lastModified": "timestamp",
		"userData": [
		{
			"accountId": "qrstc127-bf53-44a6-9bc4-46e0d293zkmn",
			"userEmail": "sbusa@clearpathnet.com"
		}
		]
	},
	"validity": 300,
	"saved": true
}


**GET List API**

Verb       URI                      Description
GET        /tokens/:id             	List summary of a specific token.

**Example Request and Response**

### Request Headers
GET http://stormkeeper:8333/tokens/:id

### Response JSON

{
	"id": "8d41e531-519b-40cc-88cd-9abe95498ef1",
	"data": {
		"name": "token1",
		"domainId": "abcdc127-bf53-44a6-9bc4-46e0d293efgh",
		"identityId": "ijklc127-bf53-44a6-9bc4-46e0d293mnop",
		"ruleId": "05686306-0db7-4bd2-98fb-19a0e0440f19",
		"validity": 300,
		"lastModified": "timestamp",
		"userData": [
		{
			"accountId": "qrstc127-bf53-44a6-9bc4-46e0d293zkmn",
			"userEmail": "sbusa@clearpathnet.com"
		}
		]
	},
	"validity": 275,
	"saved": true,
	"rule": {
		"id": "05686306-0db7-4bd2-98fb-19a0e0440f19",
		"data": {
			"name": "specific",
			"rules": [
				"POST /domains/:id/policies",
				"PUT /domains/:id/policies/:id",
				"GET /domains/:id/policies",
				"POST /domains/:id/metapolicy/:id/groups"
			],
				"role": "admin",
				"id": "05686306-0db7-4bd2-98fb-19a0e0440f19"
		},
		"saved": true
	}
}


**DELETE Tokens API**

Verb      URI                           Description
DELETE   /tokens/:id                    Delete existing tokens configuration by ID.

**Example Request and Response**

### Request Headers
DELETE http://stormkeeper:8333/tokens/:id

### Response Header

Status Code : 204 No Content
