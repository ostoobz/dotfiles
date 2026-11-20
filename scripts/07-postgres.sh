#!/bin/sh
# ============================================================================
# Step 07: PostgreSQL setup
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
. "${SCRIPT_DIR}/../lib/utils.sh"

configure_postgres() {
  # The Brewfile pins the version. A bare `postgresql` resolves to Homebrew's
  # current default, which is not the one installed.
  PG_FORMULA=$(sed -n 's/^brew "\(postgresql@[0-9]*\)".*/\1/p' "${DOTFILES_ROOT}/Brewfile" | head -n1)

  if [ -z "$PG_FORMULA" ]; then
    info "No postgresql formula in Brewfile, skipping"
    return
  fi

  # Versioned formulae are keg-only, so their binaries are not on PATH.
  PG_BIN="$(brew --prefix "$PG_FORMULA")/bin"

  info "Starting ${PG_FORMULA} and creating default postgres user"
  brew services start "$PG_FORMULA"

  # Bounded: an unbounded wait hangs the install when the service fails to start.
  tries=0
  until "${PG_BIN}/pg_isready" -q; do
    tries=$((tries + 1))
    if [ "$tries" -ge 30 ]; then
      fail "${PG_FORMULA} did not accept connections within 30s"
      return 1
    fi
    sleep 1
  done

  "${PG_BIN}/createuser" -s postgres 2>/dev/null || info "postgres user already exists"
  success "PostgreSQL configured"
}

configure_postgres
