# Jira from the command line

You end up with `jira issue view <KEY>` working from any shell, with the API token in the keychain
and nothing exported.

## You need

- `jira-cli` (installed by the Brewfile).
- Your Jira site address, `https://<your-site>.atlassian.net`, and the email you sign in with.

## Steps

1. Create an API token at <https://id.atlassian.com/manage-profile/security/api-tokens>. If your
   organization uses single sign-on, sign in that way first; the token works the same afterwards.
2. **Save the token in your password manager before closing the page.** Atlassian shows it once.
3. Put it in the keychain. The account must be the exact email you will give `jira init`:

   ```sh
   keychain-set jira-cli you@example.com
   ```

   It prints the number of characters stored. An Atlassian API token is 192 characters; a
   different count means the value was cut off or mis-pasted (see [secrets.md](secrets.md)).

4. Configure the tool:

   ```sh
   jira init
   ```

   Installation type `Cloud`, your site address, the same email, then pick your default project
   from the list it fetches. Reaching that list means the token was accepted.

## Check it worked

```sh
jira issue view <KEY> --plain
```

## What goes wrong

- **`401 Unauthorized` during `jira init`.** `jira init` never asks for the token. It looks, in
  order, at `JIRA_API_TOKEN`, then `~/.netrc`, then the keychain item with service `jira-cli` and
  your email as the account. A 401 means it found nothing, or found a wrong or cut-off value.
- **Test the token without the tool** to tell which side is at fault:

  ```sh
  printf 'user = "%s:%s"\n' you@example.com "$(security find-generic-password -s jira-cli -w)" \
    | curl -s -K - -o /dev/null -w '%{http_code}\n' https://<your-site>.atlassian.net/rest/api/3/myself
  ```

  `200` means the token is good and the problem is in the tool's configuration. `401` means the
  token itself is being refused.
- Single sign-on is not the cause of a 401. An administrator policy that blocks API tokens can be.
