#!/bin/sh
# ============================================================================
# Step 09: Link Claude Code config and skills
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
. "${SCRIPT_DIR}/../lib/utils.sh"

link_claude_config() {
  info "Linking Claude Code config from dotfiles"

  CLAUDE_DIR="${HOME}/.claude"
  CLAUDE_SRC="${DOTFILES_ROOT}/claude"

  [ ! -d "$CLAUDE_DIR" ] && mkdir -p "$CLAUDE_DIR"

  if [ -f "${CLAUDE_SRC}/settings.json" ]; then
    symlink "${CLAUDE_SRC}/settings.json" "${CLAUDE_DIR}/settings.json"
  else
    info "No Claude settings.json found, skipping"
  fi

  if [ -f "${CLAUDE_SRC}/CLAUDE.md" ]; then
    symlink "${CLAUDE_SRC}/CLAUDE.md" "${CLAUDE_DIR}/CLAUDE.md"
  else
    info "No Claude CLAUDE.md found, skipping"
  fi
}

link_claude_skills() {
  info "Linking Claude Code skills from dotfiles"

  SKILLS_LINK_SCRIPT="${DOTFILES_ROOT}/claude/skills/link-skills.sh"

  if [ -x "$SKILLS_LINK_SCRIPT" ]; then
    "$SKILLS_LINK_SCRIPT" --clean
    success "Linked Claude Code skills"
  else
    info "No Claude skills link script found, skipping"
  fi
}

# Provisions only — never reconciles. `submodule update` on an already-present
# submodule checks out the pinned SHA in detached HEAD, moving the operator off
# whatever branch they were working on; the enumerated list this replaced is why
# one submodule sits detached and another doesn't. Advancing a pin is a
# deliberate, commit-producing act (`git submodule update --remote <path>`, then
# commit the gitlink), not a side effect of provisioning a machine. verify.sh
# reports when a pin is behind.
#
# Derived from .gitmodules so declaration is the single source of truth: adding
# a submodule there is all it takes for install to provision it.
init_submodules() {
  info "Initializing submodules"

  git config --file "${DOTFILES_ROOT}/.gitmodules" --get-regexp '\.path$' 2>/dev/null \
    | while read -r _ path; do
      if [ -e "${DOTFILES_ROOT}/${path}/.git" ]; then
        info "Already present: ${path}"
      else
        git -C "$DOTFILES_ROOT" submodule update --init -- "$path"
        success "Initialized: ${path}"
      fi
    done
}

link_vendor_skills() {
  info "Linking vendor skills"

  CLAUDE_SKILLS="${HOME}/.claude/skills"
  VENDOR_DIR="${DOTFILES_ROOT}/claude/vendor"

  # Anthropic skills — cherry-pick specific skills from the mono-repo
  ANTHROPIC_SKILLS="${VENDOR_DIR}/anthropics-skills/skills"
  VENDOR_SKILLS="skill-creator"

  for skill in $VENDOR_SKILLS; do
    src="${ANTHROPIC_SKILLS}/${skill}"
    dest="${CLAUDE_SKILLS}/${skill}"

    if [ ! -d "$src" ]; then
      info "Vendor skill not found: $skill (run git submodule update)"
      continue
    fi

    if [ -L "$dest" ]; then
      existing="$(readlink "$dest")"
      if [ "$existing" = "$src" ]; then
        continue
      fi
      rm "$dest"
    elif [ -e "$dest" ]; then
      info "Skipping vendor skill $skill — $dest exists and is not a symlink"
      continue
    fi

    ln -sf "$src" "$dest"
    info "Linked vendor skill: $skill"
  done
}

# session-kit's skills shell out to `sk`. link-skills.sh links the skills but not
# the binary, so without this they are present and broken.
link_sk() {
  SK_SRC="${DOTFILES_ROOT}/claude/skills/session-kit/bin/sk"

  if [ ! -x "$SK_SRC" ]; then
    info "session-kit not present, skipping sk"
    return
  fi

  mkdir -p "${HOME}/.local/bin"
  symlink "$SK_SRC" "${HOME}/.local/bin/sk"
}

# settings.json's apiKeyHelper is the contract: when it is declared and returns
# nothing, Claude Code has no credential. The key cannot come from the repo, so
# ask for it once on the terminal (stdin is the pipe under `curl … | bash`) and
# never fail the step over it — verify.sh reports a helper that returns nothing.
#
# KEYCHAIN_SERVICE must match the `-s` name in that helper command.
KEYCHAIN_SERVICE="anthropic-api-key"

provision_api_key() {
  helper=$(jq -r '.apiKeyHelper // empty' "${DOTFILES_ROOT}/claude/settings.json" 2>/dev/null) || helper=""

  if [ -z "$helper" ]; then
    info "No apiKeyHelper declared, skipping API key"
    return
  fi

  if sh -c "$helper" >/dev/null 2>&1; then
    info "API key already in keychain"
    return
  fi

  if ! (: </dev/tty) 2>/dev/null; then
    warn "No terminal to ask for the API key. Add it with:"
    warn "security add-generic-password -a \"\$USER\" -s ${KEYCHAIN_SERVICE} -w"
    return
  fi

  user "Anthropic API key for Claude Code (input hidden):"
  if security add-generic-password -a "$USER" -s "$KEYCHAIN_SERVICE" -w </dev/tty; then
    success "Stored API key in keychain"
  else
    warn "API key not stored — rerun ./install --only claude-skills"
  fi
}

init_submodules
link_claude_config
link_claude_skills
link_vendor_skills
link_sk
provision_api_key
