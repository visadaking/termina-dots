{
  description = "termina dotfiles (KDE Plasma only) - portable configs + Home Manager module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      homeModules.kde-plasma-dots = { config, lib, pkgs, ... }:
        let
          cfg = config.terminaDots.kdePlasma;
          src = ./.;
          mkEnable = desc: lib.mkEnableOption desc;
        in
        {
          options.terminaDots.kdePlasma = {
            enable = mkEnable "termina KDE Plasma-focused dotfiles";

            kitty.enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Install Kitty config.";
            };
            ghostty.enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Install Ghostty config.";
            };
            btop.enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Install btop theme/config.";
            };
            mangohud.enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Install MangoHud config.";
            };
            vesktop.enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Install Vesktop settings/quick CSS (may overwrite existing Vesktop settings).";
            };
          };

          config = lib.mkIf cfg.enable {
            xdg.configFile = lib.mkMerge [
              (lib.mkIf cfg.kitty.enable {
                "kitty/kitty.conf".source = src + "/config/kitty/kitty.conf";
              })
              (lib.mkIf cfg.ghostty.enable {
                "ghostty/config".source = src + "/config/ghostty/config";
              })
              (lib.mkIf cfg.btop.enable {
                "btop/themes/tokyo-night.theme".source = src + "/config/btop/tokyo-night.theme";
              })
              (lib.mkIf cfg.mangohud.enable {
                "MangoHud/MangoHud.conf".source = src + "/config/MangoHud/MangoHud.conf";
              })
              (lib.mkIf cfg.vesktop.enable {
                "vesktop/settings.json".source = src + "/config/vesktop/settings.json";
                "vesktop/settings/quickCss.css".source = src + "/config/vesktop/settings/quickCss.css";
                "vesktop/settings/settings.json".source = src + "/config/vesktop/settings/settings.json";
              })
            ];
          };
        };

      # convenience alias
      homeModules.default = self.homeModules.kde-plasma-dots;

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
