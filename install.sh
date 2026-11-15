#!/usr/bin/env bash
set -euo pipefail

# termina-dots installer (KDE Plasma focused, portable)
# Safe by default: backs up existing targets before replacing, supports --dry-run.
# Usage: ./install.sh [--dry-run] [--no-packages] [--copy] [--all]

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
INSTALL_PACKAGES=1
MODE="link" # link|copy
INSTALL_ALL=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --no-packages) INSTALL_PACKAGES=0 ;;
    --copy) MODE="copy" ;;
    --link) MODE="link" ;;
    --all) INSTALL_ALL=1 ;;
    -h|--help)
      cat <<'EOF'
Usage: ./install.sh [options]
  --dry-run       Show actions without changing anything
  --no-packages   Skip package manager install hints/steps
  --link          Symlink configs into $HOME (default)
  --copy          Copy configs into $HOME
  --all           Install all available components without prompting
EOF
      exit 0
      ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

say() { printf '%s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }

have() { command -v "$1" >/dev/null 2>&1; }

detect_pm() {
  if have pacman; then echo pacman
  elif have dnf; then echo dnf
  elif have apt-get; then echo apt
  elif have zypper; then echo zypper
  else echo unknown
  fi
}

backup_if_needed() {
  local target="$1"
  if [ -e "$target" ] || [ -L "$target" ]; then
    local ts backup
    ts="$(date +%Y%m%d-%H%M%S)"
    backup="${target}.bak.${ts}"
    run mv -- "$target" "$backup"
    say "  backed up: $target -> $backup"
  fi
}

install_path() {
  local src="$1" dst="$2"
  run mkdir -p -- "$(dirname -- "$dst")"
  backup_if_needed "$dst"
  if [ "$MODE" = "link" ]; then
    run ln -s -- "$src" "$dst"
  else
    if [ -d "$src" ]; then
      run cp -a -- "$src" "$dst"
    else
      run cp -a -- "$src" "$dst"
    fi
  fi
  say "  installed: $dst"
}

confirm() {
  local prompt="$1"
  if [ "$INSTALL_ALL" -eq 1 ]; then return 0; fi
  local ans
  read -r -p "$prompt [y/N] " ans || true
  [[ "$ans" =~ ^[Yy]$ ]]
}

PM="$(detect_pm)"
say "== termina-dots installer =="
say "source: $SCRIPT_DIR"
say "mode:   $MODE"
say "pm:     $PM"
say

if [ "$INSTALL_PACKAGES" -eq 1 ]; then
  say "== Package hints =="
  say "Install packages with your distro package manager (review before running):"
  case "$PM" in
    pacman)
      say "  sudo pacman -S --needed git kitty ghostty btop mangohud"
      ;;
    apt)
      say "  sudo apt update && sudo apt install -y git kitty btop mangohud"
      say "  (ghostty may require an external repo/package depending on your distro release)"
      ;;
    dnf)
      say "  sudo dnf install -y git kitty btop mangohud"
      say "  (ghostty may require COPR/external package depending on Fedora version)"
      ;;
    zypper)
      say "  sudo zypper install -y git kitty btop mangohud"
      ;;
    *)
      warn "Unknown package manager; install equivalents manually: git, kitty, ghostty, btop, mangohud"
      ;;
  esac
  say "Vesktop is app-specific (Flatpak/AppImage/package varies by distro). Configs can still be installed."
  say
fi

say "== Components =="
say "This will install shareable user configs (KDE Plasma-focused dotfiles subset)."
say "Existing files are backed up as *.bak.<timestamp> before replacement."
say

if confirm "Install btop config?"; then
  install_path "$SCRIPT_DIR/config/btop/tokyo-night.theme" "$HOME/.config/btop/themes/tokyo-night.theme"
  # also provide default path users can select manually in btop if desired
fi

if confirm "Install Kitty config?"; then
  install_path "$SCRIPT_DIR/config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
fi

if confirm "Install Ghostty config?"; then
  install_path "$SCRIPT_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"
fi

if confirm "Install MangoHud config?"; then
  install_path "$SCRIPT_DIR/config/MangoHud/MangoHud.conf" "$HOME/.config/MangoHud/MangoHud.conf"
fi

if confirm "Install Vesktop settings (may overwrite your Vesktop settings)?"; then
  run mkdir -p -- "$HOME/.config/vesktop/settings"
  install_path "$SCRIPT_DIR/config/vesktop/settings.json" "$HOME/.config/vesktop/settings.json"
  install_path "$SCRIPT_DIR/config/vesktop/settings/quickCss.css" "$HOME/.config/vesktop/settings/quickCss.css"
  # some Vesktop setups read from settings/settings.json too; keep a copy for convenience
  install_path "$SCRIPT_DIR/config/vesktop/settings/settings.json" "$HOME/.config/vesktop/settings/settings.json" 2>/dev/null || true
fi

say
say "Done."
say "Notes:"
say "- Review backups (*.bak.*) if you want to restore previous configs."
say "- KDE Plasma desktop-specific settings (panels/widgets/kwin rules) are highly machine-specific and not fully portable; this repo focuses on shareable app/theme dotfiles."
say "- Secrets (browser logins, tokens, SSH keys, etc.) are intentionally not included."
