#!/usr/bin/env bash
# Generic PreToolUse nudge engine — symlink this into a repo's
# .claude/hooks/<name>.sh and drop two sibling config files next to the
# symlink, matched by basename: <name>.pattern (a regex checked against
# staged file paths) and <name>.reminder.txt (text injected into context
# on match). Missing either config file -> exit 0 silently, so the
# symlink alone is a safe no-op until a repo configures it.
#
# This is a soft nudge, not enforcement — pair with a repo's own
# regex-blocking pre-commit hook (e.g. the portable-references template
# at ~/.dotfiles/git/template/hooks/pre-commit, or a repo-local
# .guardrails-driven check) for the hard-block half. The nudge exists
# for what a hard regex can't catch: paraphrased violations that satisfy
# no literal pattern but still break the underlying rule.
#
# Wire into a repo's .claude/settings.json (project-scoped) as:
#   PreToolUse -> matcher "Bash" -> "if": "Bash(git commit *)"
#   command: "bash .claude/hooks/<name>.sh"
set -euo pipefail

self="${BASH_SOURCE[0]}"
self_dir="$(cd "$(dirname "$self")" && pwd)"
name="$(basename "$self" .sh)"
pattern_file="$self_dir/$name.pattern"
reminder_file="$self_dir/$name.reminder.txt"

[ -f "$pattern_file" ] && [ -f "$reminder_file" ] || exit 0

repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
cd "$repo_root"

pattern="$(cat "$pattern_file")"

if git diff --cached --name-only | grep -qE "$pattern"; then
  jq -Rs '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":.}}' \
    <"$reminder_file"
fi

exit 0
