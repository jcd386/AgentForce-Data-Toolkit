# AgentForce Data Toolkit

[![Deploy to Salesforce](https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png)](https://githubsfdeploy.herokuapp.com/app/githubdeploy/jcd386/AgentForce-Data-Toolkit?ref=main)

A set of invocable Apex actions and Autolaunched Flow wrappers that give AgentForce agents the ability to dynamically query records, inspect object schemas, create/update records, and discover custom objects — all without hardcoded object or field references.

## Features

- **Execute SOQL Query** — Run any SOQL query and get results as JSON. Auto-applies LIMIT, respects sharing rules.
- **Execute SOSL Search** — Fuzzy text search across multiple objects via SOSL. Supports wildcards and partial name matching.
- **Describe Object Schema** — Get full field metadata for any object: API names, types, required flags, picklist values, and relationship details.
- **Create or Update Record** — Create or update any record from a JSON field map with automatic type conversion (String, Integer, Decimal, Boolean, Date, Datetime, Reference, Picklist, Base64).
- **List Custom Objects** — Discover all custom objects in the org with optional keyword filtering and managed package inclusion.
- **Autolaunched Flow wrappers** — Each action has a corresponding ALF flow with detailed variable descriptions optimized for the Atlas reasoning engine.
- **Security-first** — All actions run `with sharing` and respect field-level security.

## Installation

### Option A: One-Click Deploy

Click the "Deploy to Salesforce" button above.

### Option B: SFDX CLI

```bash
# Clone the repo
git clone https://github.com/jcd386/AgentForce-Data-Toolkit.git
cd AgentForce-Data-Toolkit

# Deploy to your org
sf project deploy start --target-org YOUR_ORG_ALIAS
```

## Setup

After deploying, connect the Autolaunched Flows to your AgentForce agent topics as actions:

| Flow | Action Name |
|------|-------------|
| WSM - ALF - Agent: Execute SOQL Query | Execute SOQL Query |
| WSM - ALF - Agent: Execute SOSL Search | Execute SOSL Search |
| WSM - ALF - Agent: Describe Object Schema | Describe Object Schema |
| WSM - ALF - Agent: Create or Update Record | Create or Update Record |
| WSM - ALF - Agent: List Custom Objects | List Custom Objects |

### Recommended Agent Topic Instructions

```
You have access to tools that let you navigate Salesforce data dynamically.

When asked about data you have not seen before:
1. Call List Custom Objects to discover available custom objects
2. Call Describe Object Schema to learn the fields — always set includePicklistValues
   to true when you will be creating or updating records
3. Call Execute SOQL Query to retrieve the data, or Execute SOSL Search for
   fuzzy name matching across multiple objects
4. Call Create or Update Record to make changes

Always check the success output of every action before using its results.
When creating records, pass recordId as an empty string. When updating, pass the record's ID.
```

## Actions

### Execute SOQL Query

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| query | String | Yes | SOQL query string |
| maxRecords | Number | No | Max records to return (default: 200, max: 2000) |

**Outputs**: `resultsJson` (JSON array), `recordCount`, `success`, `errorMessage`

### Execute SOSL Search

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| searchQuery | String | Yes | SOSL query (e.g., `FIND {John} IN NAME FIELDS RETURNING Contact(Id, Name) LIMIT 10`) |

**Outputs**: `resultsJson` (JSON object keyed by object name), `totalRecordCount`, `success`, `errorMessage`

### Describe Object Schema

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| objectApiName | String | Yes | API name of the object |
| includePicklistValues | Boolean | No | Include active picklist values (default: false) |
| includeRelationships | Boolean | No | Include relationship details (default: false) |

**Outputs**: `schemaJson` (JSON object), `fieldCount`, `success`, `errorMessage`

### Create or Update Record

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| objectApiName | String | Yes | API name of the object |
| fieldValuesJson | String | Yes | JSON object of field-value pairs |
| recordId | String | No | Record ID for updates; leave blank to create |

**Outputs**: `recordId`, `success`, `errorMessage`

### List Custom Objects

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| includeManagedPackageObjects | Boolean | No | Include managed package objects (default: false) |
| filterKeyword | String | No | Filter by keyword in API name or label |

**Outputs**: `objectsJson` (JSON array), `objectCount`, `success`, `errorMessage`

## Files

| File | Description |
|------|-------------|
| `AgentSOQLQuery.cls` | Execute dynamic SOQL queries |
| `AgentSOQLQueryTest.cls` | Test class (11 methods) |
| `AgentSOSLSearch.cls` | Execute fuzzy SOSL searches |
| `AgentSOSLSearchTest.cls` | Test class (5 methods) |
| `AgentObjectDescribe.cls` | Object schema describe |
| `AgentObjectDescribeTest.cls` | Test class (9 methods) |
| `AgentRecordCreate.cls` | Create or update records from JSON |
| `AgentRecordCreateTest.cls` | Test class (21 methods) |
| `AgentListCustomObjects.cls` | List custom objects in the org |
| `AgentListCustomObjectsTest.cls` | Test class (7 methods) |
| `WSM_ALF_Agent_Execute_SOQL_Query.flow-meta.xml` | ALF wrapper flow |
| `WSM_ALF_Agent_Execute_SOSL_Search.flow-meta.xml` | ALF wrapper flow |
| `WSM_ALF_Agent_Describe_Object_Schema.flow-meta.xml` | ALF wrapper flow |
| `WSM_ALF_Agent_Create_Or_Update_Record.flow-meta.xml` | ALF wrapper flow |
| `WSM_ALF_Agent_List_Custom_Objects.flow-meta.xml` | ALF wrapper flow |

## License

MIT
