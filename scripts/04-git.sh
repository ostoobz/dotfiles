#!/bin/sh
# ============================================================================
# Step 04: Generate .gitconfig from template
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
. "${SCRIPT_DIR}/../lib/utils.sh"

generate_gitconfig() {
  info "Generating .gitconfig from template"

  TEMPLATE="${DOTFILES_ROOT}/config/git/.gitconfig.template"
  OUTPUT="${DOTFILES_ROOT}/config/git/.gitconfig"

  if [ ! -f "$TEMPLATE" ]; then
    fail ".gitconfig.template not found"
    return 1
  fi

  if [ -f "$OUTPUT" ]; then
    info ".gitconfig already exists, skipping generation"
    symlink "$OUTPUT" "${HOME}/.gitconfig"
    return
  fi

  # Read from the terminal, not stdin: under `curl … | bash` stdin is the pipe,
  # `read` hits EOF, and `bash -e` aborts the whole install at this step.
  user "Enter your Git user name:"
  read -r git_name </dev/tty
  user "Enter your Git email:"
  read -r git_email </dev/tty

  sed -e "s|__GIT_USER_NAME__|${git_name}|g" \
    -e "s|__GIT_USER_EMAIL__|${git_email}|g" \
    -e "s|__HOME_DIR__|${HOME}|g" \
    "$TEMPLATE" >"$OUTPUT"

  symlink "$OUTPUT" "${HOME}/.gitconfig"
  success "Generated .gitconfig for ${git_name} <${git_email}>"
}

setup_gh_aliases() {
  if ! command -v gh >/dev/null 2>&1; then
    info "gh not installed, skipping aliases"
    return
  fi

  info "Setting up gh aliases"
  gh alias set --clobber co 'pr checkout' >/dev/null
  success "Configured gh aliases"
}

generate_gitconfig
setup_gh_aliases
