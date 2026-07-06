#!/usr/bin/env bash
# ============================================================================
# macOS lean provisioning — decluttering, telemetry-adjacent resource hogs,
# and the asciiquarium idle-watcher.
#
# Sibling to security.sh on purpose: security.sh owns actual security posture
# (firewall/FileVault/SIP/Gatekeeper) plus its own Siri/ads/diagnostics
# opt-outs; this script owns a different concern — making a fresh macOS
# install *lean*, independent of security posture (bundled apps nobody asked
# for, a background asset-downloader that pulls multi-GB video loops,
# Bonjour's advertising side).
#
# Every write is a triple: defaults line + comment (what it does + factory
# default) + revert command, grouped by concern, idempotent, read-back
# verified. Nothing here requires SIP changes or recovery mode.
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck source=../../lib/utils.sh
. "${SCRIPT_DIR}/../../lib/utils.sh"

DEFAULTS_APPLIED=0
DEFAULTS_FAILED=0

main() {
  step "macOS lean provisioning"

  section_spotlight_suggestions
  section_bonjour
  section_bloatware
  section_idle_assets
  section_asciiquarium_watcher

  echo ""
  success "Lean provisioning: ${DEFAULTS_APPLIED} settings applied, ${DEFAULTS_FAILED} skipped"
  info "Notification Center widget content-fetch (News/Stocks/Weather) has no"
  info "known scriptable toggle — remove widgets manually via Notification"
  info "Center > Edit Widgets. See FRICTION.md."
}

# ==========================================================================
section_spotlight_suggestions() {
  step "Spotlight / Siri Suggestions data sharing"

  # Factory default: -int 1 (share search queries with Apple). -int 2 opts
  # out of *sharing* — does not necessarily stop every Suggestions network
  # query outright (see FRICTION.md).
  # Revert: defaults write com.apple.assistant.support "Search Queries Data Sharing Status" -int 1
  apply_default "Spotlight/Siri suggestions data sharing off" \
    write com.apple.assistant.support "Search Queries Data Sharing Status" -int 2

  local actual
  actual=$(defaults read com.apple.assistant.support "Search Queries Data Sharing Status" 2>/dev/null || echo "unset")
  if [ "$actual" = "2" ]; then
    success "Read-back: Search Queries Data Sharing Status = 2"
  else
    warn "Read-back mismatch: Search Queries Data Sharing Status = ${actual} (expected 2)"
  fi
}

# ==========================================================================
section_bonjour() {
  step "Bonjour advertising (mDNSResponder)"

  # Factory default: key absent (advertises). This stops *advertising* only —
  # discovery/browsing (AirDrop, AirPlay, printer discovery, .local
  # resolution) is untouched. A full mDNSResponder disable is deliberately
  # NOT done here; that breaks discovery outright.
  # Revert: sudo defaults delete /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements && sudo killall -HUP mDNSResponder
  apply_sudo_default "Bonjour: stop advertising (discovery unaffected)" \
    write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true

  if sudo defaults read /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements 2>/dev/null | grep -q 1; then
    success "Read-back: NoMulticastAdvertisements = true"
    sudo killall -HUP mDNSResponder 2>/dev/null || warn "Could not HUP mDNSResponder — restart to take effect"
  else
    warn "Read-back mismatch on NoMulticastAdvertisements"
  fi
}

# ==========================================================================
section_bloatware() {
  step "Bundled consumer apps"

  # /System/Applications (Safari, Mail, Photos, Music, TV, Podcasts, News,
  # Stocks, Home, Freeform, etc.) is sealed into the Signed System Volume —
  # not removable without SIP changes, not attempted. These five, if ever
  # downloaded, land in plain /Applications (root:admin, group-writable) and
  # come out with a normal admin rm -rf — no SIP involved either way.
  #
  # Deletion, confirmed with the operator (not a `defaults write` — there's
  # no one-line revert short of redownloading from the App Store).
  local bloatware=(GarageBand iMovie Pages Numbers Keynote)
  local app

  for app in "${bloatware[@]}"; do
    if [ -d "/Applications/${app}.app" ]; then
      rm -rf "/Applications/${app}.app"
      if [ -d "/Applications/${app}.app" ]; then
        warn "Could not remove ${app}.app"
      else
        success "Removed ${app}.app"
      fi
    else
      info "${app}.app not present — nothing to remove"
    fi
  done
}

# ==========================================================================
section_idle_assets() {
  step "Idle-asset daemon (idleassetsd)"

  # No supported `defaults write` key exists for idleassetsd itself (checked
  # 2026-07). The confirmed lever is disabling the LaunchDaemon outright —
  # the wallpaper/screensaver picker UI still opens, it just shows anything
  # not already cached as unavailable instead of fetching it.
  # Revert: sudo launchctl enable system/com.apple.idleassetsd && sudo launchctl kickstart -k system/com.apple.idleassetsd
  if sudo launchctl disable system/com.apple.idleassetsd 2>/dev/null; then
    success "idleassetsd disabled"
    DEFAULTS_APPLIED=$((DEFAULTS_APPLIED + 1))
  else
    warn "Could not disable idleassetsd"
    DEFAULTS_FAILED=$((DEFAULTS_FAILED + 1))
  fi

  if sudo launchctl print-disabled system 2>/dev/null | grep -q '"com.apple.idleassetsd" => true'; then
    success "Read-back: com.apple.idleassetsd disabled"
  else
    warn "Read-back mismatch: idleassetsd may still be enabled"
  fi

  # Cache purge — root-owned, version-dependent path (confirmed on Sonoma/
  # Sequoia <=15.4; may move on newer OSes, see FRICTION.md). Re-download
  # only resumes if idleassetsd is re-enabled.
  local cache_dir="/Library/Application Support/com.apple.idleassetsd"
  if [ -d "$cache_dir" ]; then
    local reclaimed
    reclaimed=$(sudo du -sh "$cache_dir" 2>/dev/null | cut -f1) || reclaimed=""
    if sudo rm -rf "${cache_dir:?}"/Customer/* 2>/dev/null; then
      success "Purged idleassetsd asset cache (was ${reclaimed:-unknown size})"
    else
      warn "Could not purge idleassetsd cache — remove manually: sudo rm -rf \"${cache_dir}/Customer\"/*"
    fi
  else
    info "No idleassetsd cache directory present — nothing to purge"
  fi
}

# ==========================================================================
section_asciiquarium_watcher() {
  step "Asciiquarium idle-watcher"

  local watcher_src="${DOTFILES_ROOT}/bin/screensaver-watcher"
  local plist_dst="${HOME}/Library/LaunchAgents/com.stoobz.screensaver-watcher.plist"
  local label="com.stoobz.screensaver-watcher"

  if [ ! -x "$watcher_src" ]; then
    warn "Watcher script missing or not executable: $watcher_src"
    return
  fi

  if ! command_exists asciiquarium; then
    warn "asciiquarium not on PATH — run ./install --only homebrew first"
    return
  fi

  mkdir -p "${HOME}/Library/LaunchAgents"
  cat >"$plist_dst" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${label}</string>
  <key>ProgramArguments</key>
  <array>
    <string>${watcher_src}</string>
  </array>
  <key>StartInterval</key>
  <integer>30</integer>
  <key>RunAtLoad</key>
  <false/>
</dict>
</plist>
EOF
  success "Wrote ${plist_dst}"

  launchctl bootout "gui/$(id -u)/${label}" 2>/dev/null || true
  if launchctl bootstrap "gui/$(id -u)" "$plist_dst" 2>/dev/null; then
    success "Loaded ${label}"
  else
    warn "Could not load ${label} — try: launchctl bootstrap gui/\$(id -u) ${plist_dst}"
    return
  fi

  if launchctl print "gui/$(id -u)/${label}" 2>/dev/null | grep -q "state = "; then
    success "Read-back: ${label} loaded"
  else
    warn "Read-back mismatch: ${label} not visible to launchctl print"
  fi
}

main "$@"
