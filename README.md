# termina dotfiles (KDE Plasma only)

Portable, shareable dotfiles/configs extracted from my **termina** setup, focused on recreating the KDE Plasma look/feel and daily workflow on other Linux distros (especially **Arch Linux**), without requiring NixOS.

This is a **dotfiles subset**, not a full NixOS/Home Manager system clone.

## Included

- **Terminal / shell / CLI**
  - `config/kitty/kitty.conf`
  - `config/ghostty/config`
  - `config/starship/starship.toml`
  - `config/fastfetch/config.jsonc` (sanitized)
  - `config/btop/btop.conf` + `config/btop/tokyo-night.theme`
- **Desktop/app theming bits**
  - `config/gtk-3.0/settings.ini`, `config/gtk-4.0/settings.ini`
  - `plasma/color-schemes/` (Tokyo Night / Tokyo Night Storm)
  - `wallpapers/`
  - `assets/feishin/termina-plasma.json` (Feishin theme export)
  - `assets/telegram/` (Telegram theme files)
- **Apps/gaming**
  - `config/MangoHud/MangoHud.conf`
  - `config/vesktop/` (settings + quick CSS; optional, may overwrite existing settings)
- **Installers**
  - `install.sh` for Arch/Fedora/Debian/etc. (safe, backs up existing files)
  - `flake.nix` Home Manager module for Nix users

## Not included (intentionally)

- Secrets/tokens/credentials (SSH keys, browser logins/cookies/sessions, API tokens, etc.)
- Full KDE Plasma state (panels, widgets, KWin rules, monitor layouts, activities) — these are device-specific
- NixOS system config/modules from `termina`
- Full icon/cursor theme packages as binaries (see “Match the full look on Arch” below)

## Install on Arch / Fedora / Debian

```bash
git clone <this-repo-url> termina-dots
cd termina-dots
./install.sh
```

Options:
```bash
./install.sh --dry-run      # preview actions
./install.sh --no-packages  # skip package hints
./install.sh --copy         # copy files instead of symlinking
./install.sh --all          # install all components without prompts
```

The installer backs up existing targets as `*.bak.<timestamp>` before replacing them.

## Match the full look on Arch (KDE Plasma)

After installing these dotfiles, set/configure the matching themes in KDE Plasma settings:

- **Color scheme:** Tokyo Night / Tokyo Night Storm (included in `plasma/color-schemes/`)
- **Icons:** Papirus Dark (and apply teal folders for a closer match)
  - Install `papirus-icon-theme` (and `papirus-folders` if available)
  - Example: `papirus-folders -C teal --theme Papirus-Dark -o` and `papirus-folders -C teal --theme Papirus -o`
- **Cursor:** Simp1e Tokyo Night Storm (package name may vary by repo/AUR)
- **GTK theme:** Tokyo Night GTK theme (variant/package may vary)
- **Wallpapers:** included in `wallpapers/` (installer can copy to `~/Pictures/Wallpapers`)
- **Fonts:** install Nerd Fonts used by terminal/prompt configs (e.g. Maple Mono NF / JetBrainsMono Nerd Font / Symbols Nerd Font) for best results

## Nix / Home Manager (flake)

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    termina-dots.url = "github:<your-user>/termina-dots";
  };

  outputs = { nixpkgs, home-manager, termina-dots, ... }: {
    homeConfigurations."user@host" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        termina-dots.homeModules.kde-plasma-dots
        {
          terminaDots.kdePlasma = {
            enable = true;
            kitty.enable = true;
            ghostty.enable = true;
            btop.enable = true;
            starship.enable = true;
            fastfetch.enable = true;
            mangohud.enable = true;
            gtk.enable = true;
            plasmaColorSchemes.enable = true;
            wallpapers.enable = false;
            vesktop.enable = false;
          };
        }
      ];
    };
  };
}
```

## Notes

- Fastfetch config is sanitized (no hardcoded user/host or local logo path).
- For the closest KDE Plasma experience on Arch, combine these configs with the matching icon/cursor/GTK themes and Nerd Fonts listed above.
