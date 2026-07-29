#!/bin/sh
# ============================================================================
# Verify the installed state of this dotfiles checkout.
#
#   - Expected symlinks resolve to the expected source
#   - Brewfile has no drift
#   - .guardrails is present for pre-commit scanning
#
# Read-only: never mutates state. Exits non-zero if any check fails.
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
. "${SCRIPT_DIR}/../lib/utils.sh"

FAILED=0

check_symlink() {
  src="$1"
  dst="$2"

  if [ ! -L "$dst" ]; then
    if [ -e "$dst" ]; then
      fail "Not a symlink: $dst (real file)"
    else
      fail "Missing: $dst"
    fi
    FAILED=$((FAILED + 1))
    return
  fi

  actual=$(readlink "$dst")
  if [ "$actual" != "$src" ]; then
    fail "Wrong target: $dst -> $actual (expected $src)"
    FAILED=$((FAILED + 1))
    return
  fi

  success "$dst"
}

padding
info "Checking symlinks"

# Keep in sync with scripts/03-dotfiles.sh, 04-git.sh, 06-mise.sh, 08-guardrails.sh.
check_symlink "${DOTFILES_ROOT}/config/zsh/.zshenv" "${HOME}/.zshenv"
check_symlink "${DOTFILES_ROOT}/config/zsh/.zshrc" "${HOME}/.zshrc"
check_symlink "${DOTFILES_ROOT}/config/zsh/aliases.zsh" "${HOME}/.config/zsh/aliases.zsh"
check_symlink "${DOTFILES_ROOT}/config/zsh/functions.zsh" "${HOME}/.config/zsh/functions.zsh"
check_symlink "${DOTFILES_ROOT}/config/git/.gitignore_global" "${HOME}/.gitignore_global"
check_symlink "${DOTFILES_ROOT}/config/editor/.editorconfig" "${HOME}/.editorconfig"
check_symlink "${DOTFILES_ROOT}/config/misc/.hushlogin" "${HOME}/.hushlogin"
check_symlink "${DOTFILES_ROOT}/config/iex/.iex.exs" "${HOME}/.iex.exs"
check_symlink "${DOTFILES_ROOT}/config/mise/config.toml" "${HOME}/.config/mise/config.toml"
check_symlink "${DOTFILES_ROOT}/config/starship/starship.toml" "${HOME}/.config/starship.toml"
check_symlink "${DOTFILES_ROOT}/config/ghostty/config" "${HOME}/.config/ghostty/config"
check_symlink "${DOTFILES_ROOT}/config/nvim/init.lua" "${HOME}/.config/nvim/init.lua"
check_symlink "${DOTFILES_ROOT}/config/tmux/.tmux.conf" "${HOME}/.tmux.conf"
check_symlink "${DOTFILES_ROOT}/config/lazygit/config.yml" "${HOME}/.config/lazygit/config.yml"
check_symlink "${DOTFILES_ROOT}/config/aerospace/aerospace.toml" "${HOME}/.config/aerospace/aerospace.toml"
check_symlink "${DOTFILES_ROOT}/config/pgcli/config" "${HOME}/.config/pgcli/config"
check_symlink "${DOTFILES_ROOT}/config/bat/config" "${HOME}/.config/bat/config"
check_symlink "${DOTFILES_ROOT}/config/ripgrep/.ripgreprc" "${HOME}/.config/ripgrep/.ripgreprc"
check_symlink "${DOTFILES_ROOT}/config/ssh/config" "${HOME}/.ssh/config"
check_symlink "${DOTFILES_ROOT}/config/direnv/direnv.toml" "${HOME}/.config/direnv/direnv.toml"
check_symlink "${DOTFILES_ROOT}/hooks/pre-commit" "${DOTFILES_ROOT}/.git/hooks/pre-commit"

if [ -f "${DOTFILES_ROOT}/config/git/.gitconfig" ]; then
  check_symlink "${DOTFILES_ROOT}/config/git/.gitconfig" "${HOME}/.gitconfig"
else
  info "Skip .gitconfig (not generated yet — run step 04)"
fi

padding
info "Checking Brewfile drift"

if command_exists brew; then
  if brew bundle check --file="${DOTFILES_ROOT}/Brewfile" >/dev/null 2>&1; then
    success "Brewfile: all dependencies satisfied"
  else
    fail "Brewfile: drift — run 'brew bundle --file ${DOTFILES_ROOT}/Brewfile'"
    FAILED=$((FAILED + 1))
  fi
else
  fail "brew not installed"
  FAILED=$((FAILED + 1))
fi

padding
info "Checking guardrails"

if [ -f "${DOTFILES_ROOT}/.guardrails" ]; then
  success ".guardrails present"
else
  fail ".guardrails missing — cp .guardrails.sample .guardrails"
  FAILED=$((FAILED + 1))
fi

padding
info "Checking macOS hardening"

MACOS_MARK="${HOME}/.cache/dotfiles/macos-hardened"
if [ -f "$MACOS_MARK" ]; then
  success "macOS hardening last run: $(cat "$MACOS_MARK")"
else
  fail "macOS hardening never run — ./install --only macos"
  FAILED=$((FAILED + 1))
fi

padding
info "Checking submodule freshness (claude/skills/*)"

# Adds one `git fetch` per submodule — network cost, but silence-by-design on
# the man-page-purge staleness (session-kit sat behind for days unnoticed)
# means a warn-only fetch here is worth the round trip. Warn-only: does not
# fail verify or touch FAILED, since a stale pin is a nudge, not a broken repo.
#
# Every path emits exactly one line. A silent section reads as "nothing ran",
# and the trailing tally then looks like it belongs to this check — and an
# unconditional trailing OK would report "fresh" for the uninitialized and
# offline cases, which are unknown, not fresh.
check_submodule_freshness() {
  submodule_path="$1"
  submodule_dir="${DOTFILES_ROOT}/${submodule_path}"

  # Submodules use a .git *file* (gitdir pointer), not a .git directory.
  if [ ! -e "${submodule_dir}/.git" ]; then
    warn "${submodule_path}: not initialized — run 'git submodule update --init'"
    return 0
  fi

  default_branch=$(git -C "$submodule_dir" ls-remote --symref origin HEAD 2>/dev/null \
    | awk '/^ref:/ {sub("refs/heads/", "", $2); print $2}')
  if [ -z "$default_branch" ]; then
    warn "${submodule_path}: origin unreachable — freshness unknown"
    return 0
  fi

  if ! git -C "$submodule_dir" fetch -q origin "$default_branch" 2>/dev/null; then
    warn "${submodule_path}: fetch failed — freshness unknown"
    return 0
  fi

  # `|| behind=""` matters: install runs this script under `bash -e`, where a
  # bare assignment from a failing command substitution aborts the script.
  behind=$(git -C "$submodule_dir" rev-list --count HEAD.."FETCH_HEAD" 2>/dev/null) || behind=""
  if [ -z "$behind" ]; then
    warn "${submodule_path}: cannot compare with origin/${default_branch}"
  elif [ "$behind" -gt 0 ]; then
    warn "${submodule_path}: ${behind} commit(s) behind origin/${default_branch}"
  else
    success "${submodule_path}: current with origin/${default_branch}"
  fi
}

# Gated on declaration (.gitmodules), not on presence (directory exists / has
# skills). Declaration is the operator's contract; presence is derived state.
# Gating on presence would silence the check exactly where it should speak — a
# declared submodule whose directory is missing is the broken state worth
# reporting. Declaring none is a valid configuration (no Claude skills, or
# deprecated), so it is `info`, not a warning: dropping the entries is all it
# takes to opt out, with no change to this script or the bootstrap steps.
#
# Collect first, then loop — piping into `while` would run the body in a
# subshell, and the empty case needs to be distinguishable from the fresh one.
SUBMODULE_PATHS=$(git config --file "${DOTFILES_ROOT}/.gitmodules" --get-regexp '\.path$' 2>/dev/null \
  | awk '$2 ~ /^claude\/skills\// {print $2}')

if [ -z "$SUBMODULE_PATHS" ]; then
  info "No claude/skills/* submodules declared — skipping"
else
  for submodule in $SUBMODULE_PATHS; do
    check_submodule_freshness "$submodule"
  done
fi

padding
if [ "$FAILED" -gt 0 ]; then
  fail "${FAILED} check(s) failed"
  exit 1
fi
success "All checks passed"
