---
name: corporate-aws-cli
description: Use when using the AWS CLI against a corporate AWS account after SAML/OIDC federation (e.g. saml2aws, aws sso login), when STS fails with invalid XML or empty responses, when selecting profiles or regions for Terraform or CI/CD stacks, or when validating RDS engine versions with describe-orderable-db-instance-options in the target account and region.
---

# Corporate AWS CLI (federated login)

## Goal

Use the **correct AWS account, named profile, and region** when the organization authenticates through **IdP federation** (SAML via tools like `saml2aws`, or IAM Identity Center / `aws sso login`). Avoid misleading CLI errors (`invalid XML`, empty body, wrong account) and align local commands with **infrastructure-as-code** (Terraform, Pulumi, Spacelift, etc.).

## Use This Skill When

- Logging in with **`saml2aws`**, **`aws sso login`**, or similar **corporate** flows before running **`aws`**.
- **`aws sts get-caller-identity`** fails with **Unable to parse response** / **invalid XML** / **`b''`**.
- After a successful login, commands still use the **wrong identity** or **wrong region**.
- You need **orderable RDS engine versions** or other **regional APIs** in the **same account and region** as the deployment stack.

This skill is **vendor-neutral**; follow your organization’s SSO and least-privilege runbooks in addition to these notes.

## After federated login (`saml2aws`, `aws sso`, etc.)

1. **Credentials are usually stored under a named profile.** The login output typically tells you to use **`--profile <name>`**.
2. **Pass that profile explicitly** unless you intentionally use another:
   ```bash
   aws sts get-caller-identity --profile <profile-from-login-output>
   ```
3. **`aws` without `--profile`** uses **`default`** or **`AWS_PROFILE`**. Stale or empty `default` often produces confusing errors—not a clear “access denied”.
4. If you **`export AWS_PROFILE=...`**, ensure **environment variables do not override** the profile chain:
   ```bash
   unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
   ```

## “Invalid XML” / Empty Response (`b''`)

Typical causes (check in order):

1. **Wrong credential source** — Run STS **with the profile** you just refreshed.
2. **`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_SESSION_TOKEN`** set in the shell — **unset** them when using a profile.
3. **Multiple `aws` binaries** — `which -a aws` may list more than one install. If behavior is odd, call the intended binary explicitly (example on Apple Silicon Homebrew):
   ```bash
   /opt/homebrew/bin/aws sts get-caller-identity --profile <profile>
   ```
4. **Proxies / custom endpoints** — Inspect **`HTTPS_PROXY`**, **`HTTP_PROXY`**, **`AWS_ENDPOINT_URL`**, **`AWS_USE_FIPS_ENDPOINT`**, **`AWS_CA_BUNDLE`** if responses look non-AWS.
5. **Shell job stopped with Ctrl+Z** — A line like **`suspended  aws ...`** means **SIGTSTP**, not an AWS API error. Run **`jobs`**, **`fg`**, or **`kill %<n>`** and retry.

To see what the shell resolves:

```bash
type aws
which -a aws
```

Prefer **`command aws`** or the **full path** to bypass wrappers while debugging.

## Region and infrastructure code

- The **AWS provider region** in your stack (for example **`var.region_primary`** in Terraform) must match **`--region`** on CLI calls for **regional** services (RDS, EC2, many others).
- To list **orderable Aurora MySQL** versions for **Serverless v2** (`db.serverless`) in the **target account and region**:
  ```bash
  aws rds describe-orderable-db-instance-options \
    --profile <profile> \
    --engine aurora-mysql \
    --db-instance-class db.serverless \
    --region <stack-primary-region> \
    --query 'OrderableDBInstanceOptions[].EngineVersion' \
    --output text | tr '\t' '\n' | sort -u
  ```
- **Do not assume** an `engine_version` string from documentation or another region is valid where you deploy—**query orderable options** in the target region when creation fails with **Cannot find version …**.

## Optional: pinning a role with `saml2aws`

If your IdP exposes several roles and you need a fixed one for scripts (example pattern only—substitute your org’s ARNs and aliases):

```bash
SAML2AWS_ROLE='arn:aws:iam::<account-id>:role/<role-name>' \
  saml2aws login -a <idp-account-alias> --force --skip-prompt
```

## What not to do

- Do not document or commit **live access keys** or **session tokens**.
- Do not assume a **default region** or **account id** for every repository—read **stack variables**, **workspace config**, or internal docs for the environment you are targeting.
