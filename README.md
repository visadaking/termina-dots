# termina dotfiles (kde only)

termina dotfiles



## in here

- **terminal / shell / CLI**
  - `config/kitty/kitty.conf`
  - `config/ghostty/config`
  - `config/starship/starship.toml`
  - `config/fastfetch/config.jsonc` (sanitized)
  - `config/btop/btop.conf` + `config/btop/tokyo-night.theme`
- **desktop/app theming bits**
  - `config/gtk-3.0/settings.ini`, `config/gtk-4.0/settings.ini`
  - `plasma/color-schemes/` (tokyo Night / tokyo Night Storm)
  - `wallpapers/`
  - `assets/feishin/termina-plasma.json` (feishin)
  - `assets/telegram/` (telegram theme files)
- **apps/games**
  - `config/MangoHud/MangoHud.conf`
  - `config/vesktop/` (settings + quick CSS; optional, may overwrite existing settings)
- **Installers**
  - `install.sh` for Arch/Fedora/Debian/etc. (safe, backs up existing files)
  - `flake.nix` home manager module for Nix users

## install

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

- **color scheme:** tokyo night / tokyo night storm (included in `plasma/color-schemes/`)
- **icons:** papirus dark (and apply teal folders for a closer match)
  - install `papirus-icon-theme` (and `papirus-folders` if available)
  - example: `papirus-folders -C teal --theme Papirus-Dark -o` and `papirus-folders -C teal --theme Papirus -o`
- **cursor:** simp1e tokyo night storm (package name may vary by repo/AUR)
- **gtk theme:** tokyo night GTK theme (variant/package may vary)
- **wallpapers:** included in `wallpapers/` (installer can copy to `~/Pictures/Wallpapers`)
- **fonts:**  Maple Mono NF / JetBrainsMono Nerd Font / Symbols Nerd Font

## nix / hm and flakes

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
