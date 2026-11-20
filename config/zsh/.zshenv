# Environment contracts — sourced by EVERY zsh invocation (interactive shells,
# scripts, `zsh -c`, ssh remote commands). Exports only: fast, silent, no PATH
# edits (macOS path_helper runs later in /etc/zprofile and would reorder them).

# XDG Base Directories
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_STATE_HOME="${HOME}/.local/state"

# Locale — read by any locale-aware program a zsh invocation spawns, scripts
# included; no interactivity dependence.
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# AWS CLI — never open a pager. Scripts and agent shells have no terminal to
# page into, and hang waiting on one.
export AWS_PAGER=""
