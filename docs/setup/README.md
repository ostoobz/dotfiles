# Setup guides

How to connect the command-line tools these dotfiles install to the accounts they need. The
installer puts the tools on the machine; these guides cover the part it cannot do for you — signing
in and storing credentials.

| Guide | Sets up | Status |
| --- | --- | --- |
| [secrets.md](secrets.md) | Where credentials live, `keychain-set`, Claude Code's API key, 1Password CLI | Keychain and API key steps run and confirmed. 1Password CLI section not yet run. |
| [aws-cli.md](aws-cli.md) | AWS CLI with single sign-on profiles | Run end to end and confirmed: one sign-in, every profile resolving to its account and role. |
| [jira-cli.md](jira-cli.md) | `jira-cli` with a keychain-held token | Run end to end and confirmed. |
| [hex.md](hex.md) | Private Hex packages for Elixir projects | Run and confirmed on Hex 2.7. Keyless build-server sign-in not yet run. |
| [dotnet.md](dotnet.md) | Several .NET SDKs side by side through mise | Run and confirmed with SDK 8 and 9. Workloads not covered. |

Not written yet, to be added after a first real run: Auth0 CLI, Datadog CLI.

## Rules every guide follows

1. **No secret in a file or an exported variable.** A tool fetches its credential when it runs:
   from the keychain, a single sign-on session, or its own OAuth login.
2. **The password manager holds the record copy.** The keychain is only the copy this machine
   reads. A wiped machine should cost you a re-entry, not the credential.
3. **Store with `keychain-set`.** The `security add-generic-password -w` prompt cuts input off at
   128 characters without saying so.
4. **One set of environment names:** `dev`, `qa`, `uat`, `prod` — for cloud profiles, wrapper
   flags, and file names alike.
5. **Nothing organization-specific here.** Account numbers, site names and tenant names belong in
   a private companion document that links back to these guides.
6. **A guide contains only steps that have been run.** Anything else is marked in the table above.

## Adding a guide

One tool per file. Order: what you end up with, what you need first, the steps, how to check it
worked, what goes wrong. Update the table.
