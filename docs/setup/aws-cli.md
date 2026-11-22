# AWS CLI with single sign-on

You end up with named profiles (`dev`, `qa`, `uat`, `prod`) that share one sign-in, no access keys
on disk, and no default profile.

## You need

- `awscli` (installed by the Brewfile).
- From your organization's AWS access portal, under any account's "Access keys" link: the **SSO
  start URL** and the **SSO Region**.
- For each environment: the account ID and the name of the role you are allowed to use.

## Steps

1. Create `~/.aws/config`. One `sso-session` block, then one profile per environment:

   ```ini
   [sso-session work]
   sso_start_url = https://<your-portal>.awsapps.com/start   # stop at /start; drop any #/… the browser adds
   sso_region = <sso-region>
   sso_registration_scopes = sso:account:access

   [profile qa]
   sso_session = work
   sso_account_id = <12-digit-account-id>
   sso_role_name = <role-name>
   region = <workload-region>
   output = json
   ```

   Repeat the profile block for `dev`, `uat` and `prod`.

2. Sign in once for all profiles:

   ```sh
   aws sso login --sso-session work
   ```

3. For `aws ecs execute-command` or `aws ssm start-session`, install the Session Manager plugin
   (`session-manager-plugin` in the Brewfile; the installer asks for your password).

## Check it worked

```sh
aws sts get-caller-identity --profile qa
```

The account in the output should be the one you configured for `qa`.

## Choices built into this layout

- **No `[default]` profile, and `AWS_PROFILE` is not exported.** A command without `--profile`
  fails instead of running against whichever account was the default.
- **Least privilege per profile.** Give `prod` the most restricted role you have. Where an account
  offers both a read-only and a read-write role, name the read-only one `<env>-ro` and reach for
  it first.
- **No pager.** `.zshenv` sets `AWS_PAGER=""`, because scripts and agent shells hang on a pager.
- **No `~/.aws/credentials`.** If that file exists, something created a long-lived key.

## What goes wrong

- "Token has expired": run the `aws sso login` line again.
- The sign-in session is cached under `~/.aws/sso/cache` as files. They are short-lived, but they
  are on disk; `aws sso logout` removes them.
