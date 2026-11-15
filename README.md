# termina dotfiles (KDE Plasma only)

Portable, shareable dotfiles/configs extracted from my **termina** setup, focused on a KDE Plasma desktop workflow.

This is **not** a full NixOS/Home Manager system reproduction (my main system is declarative NixOS + Home Manager). Instead, this repo/packages a practical subset of configs that can be used on other Linux distros (Arch, Fedora, Debian, etc.) and can also be consumed from Nix via a flake.

## What’s included

- `config/btop/` — btop theme (`tokyo-night`)
- `config/kitty/` — Kitty config
- `config/ghostty/` — Ghostty config
- `config/MangoHud/` — MangoHud config
- `config/vesktop/` — Vesktop settings / quick CSS (shareable subset)
- `install.sh` — safe installer for non-Nix systems (backs up existing files)
- `flake.nix` — Nix flake for Home Manager integration (KDE Plasma-focused dotfiles module)

## What’s intentionally not included

- Secrets/tokens/credentials (SSH keys, browser logins/cookies/sessions, API tokens, etc.)
- Machine-specific hardware config
- Full KDE Plasma state (panels/widgets/kwin rules/monitor layouts can be very device-specific)
- NixOS system modules from `termina` (this is a dotfiles subset)

## Install on Arch / Fedora / Debian (and others)

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

The installer **backs up** existing targets as `*.bak.<timestamp>` before replacing them.

### Package notes
- Common packages: `kitty`, `ghostty` (availability varies by distro), `btop`, `mangohud`
- **Vesktop** install method varies (package/Flatpak/AppImage); configs can still be applied to `~/.config/vesktop/`

## Nix / Home Manager (flake)

This repo includes a flake exposing a Home Manager module with KDE Plasma-focused dotfiles options. Example usage in your flake:

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
            mangohud.enable = true;
            vesktop.enable = true;
          };
        }
      ];
    };
  };
}
```

> Adjust username/home directory/options to your setup. The module installs shareable config files; it does not attempt to reproduce a full KDE Plasma desktop state.

## Scope

KDE Plasma-focused, portable dotfiles subset — meant to be easy to adopt without breaking an existing setup.
