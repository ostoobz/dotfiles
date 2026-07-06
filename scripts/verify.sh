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
check_submodule_freshness() {
  submodule_path="$1"
  submodule_dir="${DOTFILES_ROOT}/${submodule_path}"

  # Submodules use a .git *file* (gitdir pointer), not a .git directory.
  [ -e "${submodule_dir}/.git" ] || return 0

  default_branch=$(git -C "$submodule_dir" ls-remote --symref origin HEAD 2>/dev/null \
    | awk '/^ref:/ {sub("refs/heads/", "", $2); print $2}')
  [ -n "$default_branch" ] || return 0

  git -C "$submodule_dir" fetch -q origin "$default_branch" 2>/dev/null || return 0

  behind=$(git -C "$submodule_dir" rev-list --count HEAD.."FETCH_HEAD" 2>/dev/null)
  if [ -n "$behind" ] && [ "$behind" -gt 0 ]; then
    warn "${submodule_path}: ${behind} commit(s) behind origin/${default_branch}"
  fi
}

git config --file "${DOTFILES_ROOT}/.gitmodules" --get-regexp '\.path$' 2>/dev/null \
  | while read -r _ path; do
    case "$path" in
      claude/skills/*) check_submodule_freshness "$path" ;;
    esac
  done

padding
if [ "$FAILED" -gt 0 ]; then
  fail "${FAILED} check(s) failed"
  exit 1
fi
success "All checks passed"
