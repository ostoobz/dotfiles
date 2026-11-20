# ============================================================================
# Brewfile — Declarative Homebrew package manifest
# Usage: brew bundle --file=Brewfile
# ============================================================================

tap "nikitabobko/tap"


# ============================================================================
# Core CLI
# ============================================================================

brew "nano"
brew "wget"
brew "curl"
brew "unzip"
brew "gzip"
brew "unar"
brew "grep"
brew "rsync"
brew "cmake"
brew "lychee"       # link checker (tend's links check wraps it)

# ============================================================================
# Modern CLI Replacements
# ============================================================================

brew "bat"          # cat replacement
brew "dust"         # du replacement
brew "eza"          # ls replacement
brew "fd"           # find replacement
brew "ripgrep"      # grep replacement
brew "sd"           # sed replacement
brew "fzf"          # fuzzy finder
brew "hexyl"        # hex viewer
brew "hyperfine"    # benchmarking
brew "xsv"          # CSV toolkit
brew "viu"          # image viewer (terminal)
brew "ncdu"         # disk usage (interactive)
brew "bottom"       # top/htop replacement
brew "htop"         # process viewer
brew "tealdeer"     # tldr pages
brew "trash"        # rm to trash

# ============================================================================
# Shell & Prompt
# ============================================================================

brew "zsh"
brew "zsh-completions"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "bash"
brew "bash-completion@2"
brew "starship"     # cross-shell prompt
brew "zoxide"       # smarter cd
brew "direnv"       # per-directory env vars

# ============================================================================
# Git Tools
# ============================================================================

brew "git"
brew "git-lfs"
brew "git-delta"    # diff pager
brew "git-filter-repo"
brew "gh"           # GitHub CLI
brew "tig"          # git TUI
brew "lazygit"      # git TUI (interactive)

# ============================================================================
# Development
# ============================================================================

brew "jq"           # JSON processor
brew "yq"           # YAML processor
brew "glow"         # markdown renderer (terminal)
brew "pv"           # pipe viewer
brew "shellcheck"   # shell linter
brew "shfmt"        # shell formatter
brew "watchman"     # file watcher
brew "editorconfig" # editor config support
brew "pstree"       # process tree
brew "tokei"        # code statistics
brew "fdupes"       # duplicate file finder
brew "entr"         # file watcher (run on change)
brew "dos2unix"     # line ending conversion
brew "rename"       # bulk rename
brew "watch"        # repeat commands
brew "vim"
brew "neovim"
brew "tmux"
brew "mise"         # version manager (no shims)
brew "uv"           # Python runner; session-kit's sk CLI runs on it
brew "mas"          # Mac App Store CLI
brew "powershell"   # cross-platform pwsh, paired with windows-provisioning/windows-batch-scripting skills
brew "dotnet"       # powershell's runtime dependency
brew "awscli"       # paired with aws-env-discovery/aws-secrets-to-env skills
brew "xcodes"       # manages the installed Xcode-26.2.0.app

# ============================================================================
# Security & Encryption
# ============================================================================

brew "gnupg"
brew "pinentry-mac"
brew "age"          # modern file encryption
brew "openssh"
brew "ssh-copy-id"
cask "lulu"         # outbound firewall (macOS firewall only blocks inbound)
cask "malwarebytes" # anti-malware
cask "oversight"    # Objective-See: mic/camera access alerts
cask "reikey"       # Objective-See: keylogger detection
cask "kextviewr"    # Objective-See: kernel extension viewer
cask "taskexplorer" # Objective-See: process/task inspector
cask "blockblock"   # Objective-See: real-time persistence-install alerts
cask "knockknock"   # Objective-See: on-demand persistence-location audit
cask "whatsyoursign" # Objective-See: Finder code-signing info
cask "ransomwhere"  # Objective-See: behavioral ransomware detection
cask "netiquette"   # Objective-See: per-process network connection monitor
cask "santa"        # Google/North Pole Security: ESF binary authorization (Gatekeeper supplement) — installed in MONITOR (non-blocking) mode, see FRICTION.md

# ============================================================================
# Databases
# ============================================================================

brew "postgresql@17" # PostgreSQL server
brew "libpq"         # PostgreSQL client library
brew "pgcli"         # PostgreSQL CLI with autocomplete
brew "pgformatter"   # SQL formatter
brew "redis"

# ============================================================================
# Network
# ============================================================================

brew "wireshark"        # tshark CLI (packet capture/analysis)

# ============================================================================
# Build Dependencies (mise Erlang/Elixir)
# ============================================================================

brew "autoconf"
brew "automake"
brew "wxwidgets"
brew "openssl@3"
brew "libyaml"
brew "readline"
brew "libxslt"
brew "libtool"
brew "unixodbc"
brew "sqlite3"
brew "xz"
brew "zlib"

# ============================================================================
# Archiving
# ============================================================================

brew "p7zip"        # 7z support

# ============================================================================
# === Optional: GNU Coreutils ===
# Modern replacements (fd, sd, ripgrep, eza) cover most use cases.
# Uncomment if you need GNU-compatible flags in scripts.
# ============================================================================

# brew "coreutils"
# brew "moreutils"
# brew "findutils"
# brew "diffutils"
# brew "gnu-sed"
# brew "gnu-tar"
# brew "gawk"

# ============================================================================
# Media / Video Pipeline
# Backs the ffmpeg-expert/imagemagick-expert/bash-pipeline-expert skills and
# the video-pipeline-build/curate contexts.
# ============================================================================

brew "ffmpeg"
brew "exiftool"
brew "imagemagick"
brew "yt-dlp"
brew "aria2"        # yt-dlp external downloader backend (parallel segment fetch)
brew "deno"         # yt-dlp's JS runtime for solving YouTube signature/nsig challenges
brew "sdl2-compat"  # satisfies ffmpeg's sdl2 dep via the sdl3-backed compat shim
brew "sdl3"         # sdl2-compat's actual backend

# ============================================================================
# === Optional: Media Tools ===
# Install ad-hoc when needed. Uncomment for a full media workstation.
# ============================================================================

# brew "ffmpegthumbnailer"
# brew "imageoptim-cli"
# brew "figlet"
# brew "asciinema"
# brew "transmission-cli"
# brew "pdfgrep"
# brew "graphviz"
# brew "gnuplot"
# brew "yasm"
# brew "xvid"

# ============================================================================
# Casks: Terminal & Editor
# ============================================================================

cask "ghostty"
cask "vscodium"
cask "cursor"       # AI code editor
cask "cursor-cli"

# ============================================================================
# Casks: Browsers
# ============================================================================

cask "brave-browser"
cask "firefox"

cask "google-chrome"

# ============================================================================
# Casks: Dev Tools
# ============================================================================

brew "docker"       # Docker CLI only
brew "docker-compose"

# ============================================================================
# Casks: Utilities
# ============================================================================

cask "rectangle"    # Window snapping
cask "nikitabobko/tap/aerospace"  # Tiling window manager
cask "karabiner-elements" # Keyboard remapping
cask "appcleaner"   # Clean uninstalls
cask "utm"          # Virtual machines
cask "qlmarkdown"   # Quick Look markdown preview
cask "crystalfetch" # macOS installer downloader
cask "obsidian"         # notes/PKM
cask "slack"
brew "asciiquarium"     # terminal aquarium; lean-provisioning lock/screensaver experience

# === Optional: Proprietary Apps ===
# Uncomment based on personal preference.

# cask "1password"  # FOSS alternative: Bitwarden

# ============================================================================
# Casks: Claude
# ============================================================================

cask "claude-code@latest"  # bleeding-edge channel; "claude-code" is stable
brew "ccusage"             # Claude Code usage/cost tracker

# ============================================================================
# Fonts
# ============================================================================

cask "font-jetbrains-mono-nerd-font"
cask "font-meslo-lg-nerd-font"
