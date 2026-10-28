# Salesforce Azure DevOps Pipelines

## Structure

```
azure-pipelines/
├── templates/
│   ├── sf-auth.yml           ← reusable JWT auth
│   ├── sf-validate.yml       ← reusable checkonly deploy + 85% coverage check
│   ├── sf-deploy.yml         ← reusable deploy + 85% coverage check
│   └── code-analyzer.yml     ← reusable SF Code Analyzer scan
├── validation/
│   ├── QA_Validation_Pipeline.yml
│   ├── SIT_Validation_Pipeline.yml
│   ├── UAT_Validation_Pipeline.yml
│   ├── Preprod_Validation_Pipeline.yml
│   └── PROD_Validation_Pipeline.yml
├── deployment/
│   ├── QA_Deployment_Pipeline.yml
│   ├── SIT_Deployment_Pipeline.yml
│   ├── UAT_Deployment_Pipeline.yml
│   ├── Preprod_Deployment_Pipeline.yml
│   └── PROD_Deployment_Pipeline.yml
└── Code_Analyzer_Pipeline.yml
```

## Templates

| Template | Purpose |
|---|---|
| `sf-auth.yml` | JWT auth to a Salesforce org via `sf org login jwt` |
| `sf-validate.yml` | Checkonly deploy (`--dry-run`) + 85% per-class coverage check |
| `sf-deploy.yml` | Full deploy + 85% per-class coverage check |
| `code-analyzer.yml` | Installs SF Code Analyzer, runs scan, enforces severity thresholds, publishes HTML artifact |

> Pipelines in `validation/` and `deployment/` reference templates using `../templates/`.

## Validation Pipelines

- Triggered automatically on **pull request** to the target branch
- Checkout: feature branch (PR source branch via `checkout: self`)
- `FEATURE_BRANCHNAME` is derived at runtime: `$[ replace(variables['System.PullRequest.SourceBranch'], 'refs/heads/', '') ]`
- Stage order: `Setup → CodeAnalyzer → Validate`

| Pipeline | PR Target Branch |
|---|---|
| QA_Validation_Pipeline | QA |
| SIT_Validation_Pipeline | SIT |
| UAT_Validation_Pipeline | UAT |
| Preprod_Validation_Pipeline | Preprod |
| PROD_Validation_Pipeline | master |

## Deployment Pipelines

- Triggered **manually** (`trigger: none`)
- Checkout: always hardcoded to target branch (`ref: refs/heads/<ENV>`) regardless of pipeline version selected
- `FEATURE_BRANCHNAME` is a required manual input parameter
- Stage order: `Setup → CodeAnalyzer → Validate → Deploy`

| Pipeline | Target Branch | Environment |
|---|---|---|
| QA_Deployment_Pipeline | QA | QA |
| SIT_Deployment_Pipeline | SIT | SIT |
| UAT_Deployment_Pipeline | UAT | UAT |
| Preprod_Deployment_Pipeline | Preprod | PREPROD |
| PROD_Deployment_Pipeline | master | PROD |

## Standalone Pipeline

| Pipeline | Purpose |
|---|---|
| `Code_Analyzer_Pipeline.yml` | Runs SF Code Analyzer scan independently. Triggers on `feature/*`, `hotfix/*`, `main`, `develop` branches and PRs. Optional `FEATURE_BRANCHNAME` parameter to scope scan target. |

## Parameters

| Parameter | Validation Pipelines | Deployment Pipelines |
|---|---|---|
| `FEATURE_BRANCHNAME` | Auto-derived from PR source branch | Manual input |
| `TEST_LEVEL` | `RunLocalTests` (default), `RunAllTestsInOrg`, `RunSpecifiedTests` | Same |

## Quality Gates

### Code Analyzer (`code-analyzer.yml`)
- Installs `@salesforce/cli` and SF Code Analyzer plugin
- Scans `force-app/` directory
- Severity thresholds: Sev1=0, Sev2≤5, Sev3≤10 — pipeline fails if exceeded
- Publishes HTML scan report as pipeline artifact

### 85% Apex Coverage (`sf-validate.yml` / `sf-deploy.yml`)
- Runs after every validate and deploy step
- Reads `manifest/<branch>_MainClass.txt` for the list of non-test Apex classes in the delta
- Calls `scripts/check_coverage.py --mode local` against JSON written by `--coverage-formatters json`
- Skipped automatically when `TEST_LEVEL=NoTestRun` or `_MainClass.txt` is absent/empty

## Variable Groups

Each environment requires a variable group in Pipelines → Library:

| Group Name | Environment |
|---|---|
| `SF-QA-Credentials` | QA |
| `SF-SIT-Credentials` | SIT |
| `SF-UAT-Credentials` | UAT |
| `SF-Preprod-Credentials` | Preprod |
| `SF-PROD-Credentials` | PROD |

Each group must contain:

| Variable | Description |
|---|---|
| `SF_USERNAME` | Salesforce org username |
| `SF_CONSUMER_KEY` | Connected App consumer key |
| `SF_INSTANCE_URL` | `https://test.salesforce.com` or `https://login.salesforce.com` |
| `SF_JWT_KEY` | Full PEM content of JWT private key — **mark as secret** |

## Environments

Create in Pipelines → Environments: `QA`, `SIT`, `UAT`, `PREPROD`, `PROD`

For `PROD` (and optionally `PREPROD`): Environments → PROD → Approvals and checks → Add → Approvals → add approvers.
