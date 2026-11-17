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
        in
        {
          options.terminaDots.kdePlasma = {
            enable = lib.mkEnableOption "termina KDE Plasma-focused dotfiles";

            kitty.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Install Kitty config."; };
            ghostty.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Install Ghostty config."; };
            btop.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Install btop config and theme."; };
            starship.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Install Starship prompt config."; };
            fastfetch.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Install Fastfetch config."; };
            mangohud.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Install MangoHud config."; };
            gtk.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Install GTK 3/4 settings."; };
            plasmaColorSchemes.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Install Plasma color schemes."; };
            wallpapers.enable = lib.mkOption { type = lib.types.bool; default = false; description = "Install wallpapers to ~/Pictures/Wallpapers."; };
            vesktop.enable = lib.mkOption { type = lib.types.bool; default = false; description = "Install Vesktop settings/quick CSS (may overwrite existing settings)."; };
            vesktop.desktopEntry.enable = lib.mkOption { type = lib.types.bool; default = false; description = "Install Vesktop desktop entry with Papirus icon fix."; };
            sable.enable = lib.mkOption { type = lib.types.bool; default = false; description = "Install Sable theme (termina-tokyo-night)."; };
          };

          config = lib.mkIf cfg.enable {
            xdg.configFile = lib.mkMerge [
              (lib.mkIf cfg.kitty.enable { "kitty/kitty.conf".source = src + "/config/kitty/kitty.conf"; })
              (lib.mkIf cfg.ghostty.enable { "ghostty/config".source = src + "/config/ghostty/config"; })
              (lib.mkIf cfg.btop.enable {
                "btop/btop.conf".source = src + "/config/btop/btop.conf";
                "btop/themes/tokyo-night.theme".source = src + "/config/btop/tokyo-night.theme";
              })
              (lib.mkIf cfg.starship.enable { "starship.toml".source = src + "/config/starship/starship.toml"; })
              (lib.mkIf cfg.fastfetch.enable {
                "fastfetch/config.jsonc".source = src + "/config/fastfetch/config.jsonc";
                "fastfetch/fastfetch-logo.jpg".source = src + "/wallpapers/fastfetch-logo.jpg";
              })
              (lib.mkIf cfg.mangohud.enable { "MangoHud/MangoHud.conf".source = src + "/config/MangoHud/MangoHud.conf"; })
              (lib.mkIf cfg.gtk.enable {
                "gtk-3.0/settings.ini".source = src + "/config/gtk-3.0/settings.ini";
                "gtk-4.0/settings.ini".source = src + "/config/gtk-4.0/settings.ini";
              })
              (lib.mkIf cfg.vesktop.enable {
                "vesktop/settings.json".source = src + "/config/vesktop/settings.json";
                "vesktop/settings/quickCss.css".source = src + "/config/vesktop/settings/quickCss.css";
                "vesktop/settings/settings.json".source = src + "/config/vesktop/settings/settings.json";
              })
            ];

            xdg.dataFile = lib.mkMerge [
              (lib.mkIf cfg.plasmaColorSchemes.enable {
                "color-schemes/TokyoNight.colors".source = src + "/plasma/color-schemes/TokyoNight.colors";
                "color-schemes/TokyoNightStorm.colors".source = src + "/plasma/color-schemes/TokyoNightStorm.colors";
              })
            ];

            home.file = lib.mkMerge [
              (lib.mkIf cfg.wallpapers.enable {
                "Pictures/Wallpapers/715139.jpg".source = src + "/wallpapers/715139.jpg";
                "Pictures/Wallpapers/ergo-proxy-kw9yj7-1920x1080.png".source = src + "/wallpapers/ergo-proxy-kw9yj7-1920x1080.png";
                "Pictures/Wallpapers/ergo-proxy-ne782l-2500x1406.jpg".source = src + "/wallpapers/ergo-proxy-ne782l-2500x1406.jpg";
                "Pictures/Wallpapers/lain-suburban-cool-blue-wallhaven-xelyx3.jpg".source = src + "/wallpapers/lain-suburban-cool-blue-wallhaven-xelyx3.jpg";
                "Pictures/Wallpapers/overcast-suburban-powerlines-wallhaven-d889yo.jpg".source = src + "/wallpapers/overcast-suburban-powerlines-wallhaven-d889yo.jpg";
                "Pictures/Wallpapers/fastfetch-logo.jpg".source = src + "/wallpapers/fastfetch-logo.jpg";
              })

              (lib.mkIf cfg.sable.enable {
                "sable-themes/termina-tokyo-night.sable.css".source = src + "/assets/sable/termina-tokyo-night.sable.css";
              })
            ];

            xdg.desktopEntries = lib.mkIf cfg.vesktop.desktopEntry.enable {
              vesktop = {
                name = "Vesktop";
                genericName = "Internet Messenger";
                comment = "Alternative Discord client with Vencord built-in";
                exec = "vesktop %U";
                icon = "${pkgs.papirus-icon-theme}/share/icons/Papirus/64x64/apps/vesktop.svg";
                terminal = false;
                type = "Application";
                categories = [ "Network" "InstantMessaging" "Chat" ];
                mimeType = [ "x-scheme-handler/discord" ];
                settings = {
                  Keywords = "discord;vencord;electron;chat";
                  StartupWMClass = "Vesktop";
                  Version = "1.5";
                };
              };
            };
          };
        };

      homeModules.default = self.homeModules.kde-plasma-dots;
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
