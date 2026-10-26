# Salesforce Azure DevOps Pipelines

Converted from Jenkins `RURAL_PREPROD_SFDX_Deployment_Pipeline` and `RURAL_PREPROD_SFDX_Validation_Pipeline`.

## Structure

```
azure-pipelines/
├── templates/
│   ├── sf-auth.yml                   ← reusable JWT auth
│   ├── sf-validate.yml               ← reusable checkonly deploy (2 test modes)
│   └── sf-deploy.yml                 ← reusable deploy
│
├── SIT_Validation_Pipeline.yml
├── SIT_Deployment_Pipeline.yml
│
├── QA_Validation_Pipeline.yml
├── QA_Deployment_Pipeline.yml
│
├── UAT_Validation_Pipeline.yml
├── UAT_Deployment_Pipeline.yml
│
├── Preprod_Validation_Pipeline.yml
├── Preprod_Deployment_Pipeline.yml
│
├── PROD_Validation_Pipeline.yml
└── PROD_Deployment_Pipeline.yml
```

## Pipeline Parameters (all pipelines)

| Parameter | Description |
|---|---|
| `FEATURE_BRANCHNAME` | Branch/ticket name — locates `manifest/feature/<name>_package.xml` and `manifest/feature/<name>_TestClass.txt` |
| `TEST_LEVEL` | `NoTestRun` / `RunLocalTests` / `RunAllTestsInOrg` / `RunSpecifiedTests` |

> PROD pipelines default to `RunSpecifiedTests`. All others default to `RunLocalTests`.

## Flow

**Validation Pipeline** (checkonly — no changes deployed):
```
Setup (auth + check package.xml exists)
  ↓
Validate (sf project deploy --dry-run)
```

**Deployment Pipeline** (validate first, then deploy):
```
Setup (auth + check package.xml exists)
  ↓
Validate (sf project deploy --dry-run)
  ↓
Deploy (sf project deploy)
  ↑
  PROD only: pauses for manual approval gate
```

## Test Mode Logic

| TEST_LEVEL | Behaviour |
|---|---|
| `RunSpecifiedTests` | Reads `<FEATURE_BRANCHNAME>_TestClass.txt`, passes comma-separated class list to `--tests` |
| Any other level | Passes `--test-level` directly — TestClass.txt not used |

## Azure DevOps Setup

### 1. Variable Groups (Pipelines → Library)

Create one group per environment — each must have these 4 variables:

| Variable | Description |
|---|---|
| `SF_USERNAME` | Salesforce org username |
| `SF_CONSUMER_KEY` | Connected App consumer key |
| `SF_INSTANCE_URL` | `https://test.salesforce.com` (sandbox) or `https://login.salesforce.com` (prod) |
| `SF_JWT_KEY` | Full PEM content of JWT private key — **mark as secret** |

| Group Name | Environment |
|---|---|
| `SF-SIT-Credentials` | SIT |
| `SF-QA-Credentials` | QA |
| `SF-UAT-Credentials` | UAT |
| `SF-Preprod-Credentials` | Preprod |
| `SF-PROD-Credentials` | PROD |

### 2. Environments (Pipelines → Environments)

Create: `SIT`, `QA`, `UAT`, `PREPROD`, `PROD`

For `PROD` (and optionally `PREPROD`):
**Environments → PROD → Approvals and checks → + Add → Approvals** → add approvers.

### 3. Register Pipelines

For each YAML: **Pipelines → New Pipeline → Azure Repos Git → select file → Save**.
