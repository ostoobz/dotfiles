# Private Hex packages

You end up with `mix deps.get` fetching packages from a private Hex organization, with no key for
you to store or rotate.

Run and confirmed on Hex 2.7.

## You need

- Elixir with Hex (installed by the `mise` step).
- A hex.pm account that is a member of the organization.

## Steps

```sh
mix hex.user auth        # opens the browser sign-in
mix hex.user whoami      # your hex.pm username
mix deps.get             # in a project that depends on the organization's packages
```

That is all. Signing in as a user authorizes every organization the account belongs to.

## What it stores

`~/.hex/hex.config` (readable only by you) holds a short-lived access token and a refresh token.
There is no long-lived key in it, so there is nothing to put in the keychain or a password manager.
`mix hex.user deauth` removes it.

## Organization keys are for build servers, not for you

`mix hex.organization auth <org> --key <key>` used to be a set-and-forget command. On current Hex
it exchanges the key for a token that lasts about 25 minutes and is not refreshed. It is meant to
run in a build, immediately before fetching dependencies. Used on a development machine it works
once and then stops.

For build servers:

- Give the key only the organization's repository permission. That is read-only access to its
  packages and is what `mix hex.organization key <org> generate` grants by default.
- Give it an expiry.
- On GitHub Actions a job with `id-token: write` can fetch without any key once a workload identity
  is configured for the organization on hex.pm. Not yet run from these dotfiles.

## Publishing

Use a separate key, created when needed, with publish permission on the one package being released
and the shortest expiry offered. Revoke it afterwards.

## What goes wrong

- `mix deps.get` fails on a private package with an authentication error: run
  `mix hex.user whoami`. No user means the sign-in expired or was never done.
- It worked and then stopped about half an hour later: the machine was authorized with an
  organization key rather than a user sign-in.
