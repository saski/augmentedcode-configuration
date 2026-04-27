---
name: eventbrite-aws-cli
description: Use when working under ~/eventbrite and using the AWS CLI after saml2aws or SSO login, when STS fails with invalid XML or empty responses, when choosing AWS profiles or regions for Terraform/Spacelift, or when validating RDS engine versions with describe-orderable-db-instance-options in the application account.
---

# Eventbrite AWS CLI (local auth)

## Goal

Use the **correct AWS account, profile, and region** when running CLI commands against Eventbrite application infrastructure (for example Terraform in `~/eventbrite/*`, Spacelift stacks, RDS). Avoid common foot-guns that produce misleading errors (`invalid XML`, empty body, wrong account).

## Use This Skill When

- Workspace path is under **`~/eventbrite/*`** and the task involves **AWS CLI**, **saml2aws**, **IAM roles**, or **regional APIs** (RDS, EC2, STS).
- **`aws sts get-caller-identity`** fails with **Unable to parse response** / **invalid XML** / **`b''`**.
- After **`saml2aws login`**, commands still hit the wrong identity or fail.
- You need the **same region** as **`region_primary`** for a stack (for example orderable RDS engine versions).

## Path Trigger

Treat this guidance as **default for `~/eventbrite/*`**. It complements **[github-host-alias](../github-host-alias/SKILL.md)** (SSH for GitHub); it does not replace org-specific runbooks or Okta changes.

## After `saml2aws login`

1. **Credentials land on the named profile** (for example the `-a` / `--idp-account` alias). The tool output usually says to pass **`--profile <name>`**.
2. **Always pass that profile** unless you intentionally use another:
   ```bash
   aws sts get-caller-identity --profile <profile-from-login-output>
   ```
3. **`aws` without `--profile`** uses **`default`** or whatever **`AWS_PROFILE`** is. If nothing is configured or keys are stale, you get confusing errors—not necessarily “access denied”.
4. If you use **`export AWS_PROFILE=...`**, ensure no **environment credentials** override the profile chain:
   ```bash
   unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
   ```

## “Invalid XML” / Empty Response (`b''`)

Typical causes (check in order):

1. **Wrong credential source** — Run STS **with explicit `--profile`** after login.
2. **`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_SESSION_TOKEN`** set in the shell — **unset** them when using a profile.
3. **Multiple `aws` binaries** — `which -a aws` may show Homebrew and another install. If behavior is odd, call the intended binary explicitly, for example:
   ```bash
   /opt/homebrew/bin/aws sts get-caller-identity --profile <profile>
   ```
4. **Proxies / custom endpoints** — Inspect **`HTTPS_PROXY`**, **`HTTP_PROXY`**, **`AWS_ENDPOINT_URL`**, **`AWS_USE_FIPS_ENDPOINT`**, **`AWS_CA_BUNDLE`** if responses look non-AWS.
5. **Shell job stopped with Ctrl+Z** — A line like **`suspended  aws ...`** means the process was **SIGTSTP**’d, not an AWS error. Run **`jobs`**, **`fg`**, or **`kill %<n>`** and retry.

To see what the shell resolves:

```bash
type aws
which -a aws
```

Prefer **`command aws`** or the **full path** to bypass any wrapper when debugging.

## Region and Terraform / Spacelift

- **`providers.tf`** / stack inputs use **`var.region_primary`** for the AWS provider. CLI calls for **RDS**, **Secrets Manager**, etc. must use **that same region**.
- To see **orderable Aurora versions** for Serverless v2 (`db.serverless`), use the **account + region** of the target stack:
  ```bash
  aws rds describe-orderable-db-instance-options \
    --profile <profile> \
    --engine aurora-mysql \
    --db-instance-class db.serverless \
    --region <region_primary> \
    --query 'OrderableDBInstanceOptions[].EngineVersion' \
    --output text | tr '\t' '\n' | sort -u
  ```
- **Do not assume** an `engine_version` string from docs or another region is valid—**list orderable options** in the target region when Terraform fails with **Cannot find version … for aurora-mysql**.

## Optional: Role Pinning with `saml2aws`

If your flow uses a fixed role ARN for a given IdP account alias, you can pin it for non-interactive login (example pattern only—use your org’s role ARN):

```bash
SAML2AWS_ROLE='arn:aws:iam::<account-id>:role/<role-name>' \
  saml2aws login -a <idp-account-alias> --force --skip-prompt
```

## What Not To Do

- Do not document or commit **live access keys** or **session tokens**.
- Do not assume **`us-east-1`** or a specific account ID for every repo—**read stack / Terraform variables** for the workspace you are in.

## Related

- **GitHub SSH for `~/eventbrite`**: [github-host-alias](../github-host-alias/SKILL.md)
