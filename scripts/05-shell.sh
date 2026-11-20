#!/bin/sh
# ============================================================================
# Step 05: Zsh setup (no Oh My Zsh)
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/../lib/utils.sh"

configure_shell() {
  info "Configuring Zsh as default shell"

  ZSH_PATH="$(which zsh)"

  # Add Homebrew zsh to /etc/shells if missing
  if ! grep -qx "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    info "Added $ZSH_PATH to /etc/shells"
  fi

  # The directory record, not $SHELL: $SHELL is fixed at login, so on a rerun
  # in the same terminal it still names the old shell.
  CURRENT_SHELL="$(dscl . -read "/Users/${USER}" UserShell | awk '{print $2}')"

  # Through sudo so it rides on the credential the installer already holds.
  # Plain chsh authenticates on its own and prompts a second time.
  if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
    sudo chsh -s "$ZSH_PATH" "$USER"
    success "Set default shell to $ZSH_PATH"
  else
    info "Zsh is already the default shell"
  fi

  success "Shell configured"
}

configure_shell
