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
  [ -e "$src" ] || { warn "missing source: $src"; return 0; }
  run mkdir -p -- "$(dirname -- "$dst")"
  backup_if_needed "$dst"
  if [ "$MODE" = "link" ]; then
    run ln -s -- "$src" "$dst"
  else
    run cp -a -- "$src" "$dst"
  fi
  say "  installed: $dst"
}

install_dir_contents() {
  local src_dir="$1" dst_dir="$2"
  [ -d "$src_dir" ] || { warn "missing source dir: $src_dir"; return 0; }
  run mkdir -p -- "$dst_dir"
  local f
  for f in "$src_dir"/*; do
    [ -e "$f" ] || continue
    install_path "$f" "$dst_dir/$(basename -- "$f")"
  done
}

confirm() {
  local prompt="$1"
  if [ "$INSTALL_ALL" -eq 1 ]; then return 0; fi
  local ans
  read -r -p "$prompt [y/N] " ans || true
  [[ "$ans" =~ ^[Yy]$ ]]
}

PM="$(detect_pm)"
say "== termina-dots installer (KDE Plasma only) =="
say "source: $SCRIPT_DIR"
say "mode:   $MODE"
say "pm:     $PM"
say

if [ "$INSTALL_PACKAGES" -eq 1 ]; then
  say "== Package hints (review before running) =="
  case "$PM" in
    pacman)
      say "  # core apps"
      say "  sudo pacman -S --needed git kitty ghostty btop fastfetch starship mangohud"
      say "  # KDE/GTK/theme helpers (names may vary; check your repos/AUR)"
      say "  sudo pacman -S --needed papirus-icon-theme papirus-folders kvantum"
      say "  # GTK theme / cursor examples (may be in AUR): tokyonight-gtk-theme, simp1e-tokyo-night-cursors"
      ;;
    apt)
      say "  sudo apt update"
      say "  sudo apt install -y git kitty btop fastfetch mangohud"
      say "  # starship/ghostty/papirus-folders/theme packages may require external repos or manual install"
      ;;
    dnf)
      say "  sudo dnf install -y git kitty btop fastfetch starship mangohud papirus-icon-theme"
      say "  # ghostty/papirus-folders/theme packages may require COPR/external repos"
      ;;
    zypper)
      say "  sudo zypper install -y git kitty btop fastfetch starship mangohud papirus-icon-theme"
      ;;
    *)
      warn "Unknown package manager; install equivalents manually."
      ;;
  esac
  say "Vesktop install varies by distro (package/Flatpak/AppImage)."
  say "For matching icons: use Papirus + 'papirus-folders -C teal --theme Papirus-Dark' (and Papirus) if available."
  say
fi

say "== Components =="
say "Shareable KDE Plasma-focused configs. Existing files are backed up as *.bak.<timestamp>."
say

if confirm "Install btop config + theme?"; then
  install_path "$SCRIPT_DIR/config/btop/btop.conf" "$HOME/.config/btop/btop.conf"
  install_path "$SCRIPT_DIR/config/btop/tokyo-night.theme" "$HOME/.config/btop/themes/tokyo-night.theme"
fi

if confirm "Install Kitty config?"; then
  install_path "$SCRIPT_DIR/config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
fi

if confirm "Install Ghostty config?"; then
  install_path "$SCRIPT_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"
fi

if confirm "Install Starship config?"; then
  install_path "$SCRIPT_DIR/config/starship/starship.toml" "$HOME/.config/starship.toml"
fi

if confirm "Install Fastfetch config + logo?"; then
  install_path "$SCRIPT_DIR/config/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
  install_path "$SCRIPT_DIR/wallpapers/fastfetch-logo.jpg" "$HOME/.config/fastfetch/fastfetch-logo.jpg"
fi

if confirm "Install MangoHud config?"; then
  install_path "$SCRIPT_DIR/config/MangoHud/MangoHud.conf" "$HOME/.config/MangoHud/MangoHud.conf"
fi

if confirm "Install GTK 3/4 settings?"; then
  install_path "$SCRIPT_DIR/config/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
  install_path "$SCRIPT_DIR/config/gtk-4.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"
fi

if confirm "Install KDE Plasma color schemes (Tokyo Night / Storm)?"; then
  install_dir_contents "$SCRIPT_DIR/plasma/color-schemes" "$HOME/.local/share/color-schemes"
fi

if confirm "Install wallpapers to ~/Pictures/Wallpapers?"; then
  install_dir_contents "$SCRIPT_DIR/wallpapers" "$HOME/Pictures/Wallpapers"
fi

if confirm "Install Vesktop settings (may overwrite your Vesktop settings)?"; then
  run mkdir -p -- "$HOME/.config/vesktop/settings"
  install_path "$SCRIPT_DIR/config/vesktop/settings.json" "$HOME/.config/vesktop/settings.json"
  install_path "$SCRIPT_DIR/config/vesktop/settings/quickCss.css" "$HOME/.config/vesktop/settings/quickCss.css"
  install_path "$SCRIPT_DIR/config/vesktop/settings/settings.json" "$HOME/.config/vesktop/settings/settings.json"
fi

if confirm "Install Sable theme (termina-tokyo-night)?"; then
  install_path "$SCRIPT_DIR/assets/sable/termina-tokyo-night.sable.css" "$HOME/.local/share/sable-themes/termina-tokyo-night.sable.css"
fi

say
say "Optional extras (not auto-installed):"
say "- Feishin theme: assets/feishin/termina-plasma.json"
say "- Telegram theme files: assets/telegram/"
say "- Sable theme: assets/sable/termina-tokyo-night.sable.css"
say
say "Done. Review backups (*.bak.*) to restore previous configs if needed."
say "Note: Plasma panels/widgets/kwin layouts are device-specific and not included."
