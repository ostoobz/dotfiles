# Secrets

## Where each kind of credential lives

| Kind | Record copy | How the tool gets it |
| --- | --- | --- |
| API key for one tool (Claude Code, Jira) | Password manager | macOS keychain item, read by the tool at run time |
| Cloud access | None — nothing long-lived exists | Single sign-on session, short-lived tokens |
| Per-environment application secrets | Password manager or the cloud's secret store | Injected into one command, e.g. `op run`, never written to `.env` |

## Store a secret in the keychain

```sh
keychain-set <service> [account]     # account defaults to your username
```

It asks for the value with hidden input, stores it, reads it back to confirm, and prints how many
characters it stored. Compare that count with the length you expect.

Read it back yourself:

```sh
security find-generic-password -s <service> -w
```

Remove it:

```sh
security delete-generic-password -s <service>
```

### Why not the built-in prompt

`security add-generic-password -a … -s … -w` with nothing after `-w` prompts for the value, and
that prompt keeps only the first 128 characters. The command succeeds and the tool later fails to
authenticate. Passing the value after `-w` avoids the cut-off but puts the secret in your shell
history and the process list. `keychain-set` avoids both.

## Claude Code API key

`claude/settings.json` declares:

```json
"apiKeyHelper": "security find-generic-password -s anthropic-api-key -w"
```

1. `keychain-set anthropic-api-key` and paste the key. `./install --only claude-skills` runs this
   for you when the helper returns nothing.
2. Open a new terminal, start `claude`, run `/status`. "API key" should read `apiKeyHelper`.

What goes wrong:

- `ANTHROPIC_API_KEY` exported anywhere overrides the helper. Do not export it.
- `./install --verify` fails with "apiKeyHelper returns nothing" when the item is missing.

## 1Password CLI

Not yet run on a machine provisioned from these dotfiles; steps are the vendor's.

1. Install the desktop app and the CLI (`1password`, `1password-cli`).
2. In the app: Settings → Developer → Integrate with 1Password CLI.
3. `op vault list` should prompt for Touch ID and list your vaults.

Use references rather than values: `op read "op://vault/item/field"`, or
`op run --env-file <file-of-references> -- <command>` to inject secrets into a single command.

One approval covers the terminal session it was given in, for every vault your account can see,
for a limited time. Anything else running in that terminal can use it too.
