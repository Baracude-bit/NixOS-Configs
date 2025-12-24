{ pkgs, inputs, ... }:
{
  imports = with inputs; [
    nvchad.homeManagerModules.default
    flatpak.homeModules.default
    ./ghostty.nix
  ];

  # Apps configuration
  programs = {
    git.enable = true;
    brave.enable = true;
    fastfetch.enable = true;
    btop.enable = true;

    nvchad = {
      enable = true;
      hm-activation = false;
    };
  };

  services = {
    syncthing.enable = true;

    # --- FLATPAK CONFIGURATION ---
    flatpak = {
      remotes."flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";

      # Helper function to generate full Flathub reference
      packages =
        let
          mkApp = pkg: "flathub:app/${pkg}/x86_64/stable";
          appList = [
            # Social & Media
            "com.discordapp.Discord"
            "org.signal.Signal"
            "io.github.celluloid_player.Celluloid"
            "com.stremio.Stremio"
            "org.videolan.VLC"

            # Tools & Productivity
            "io.gitlab.librewolf-community"
            "org.qbittorrent.qBittorrent"
            "org.libreoffice.LibreOffice"
            "org.keepassxc.KeePassXC"
            "com.system76.Popsicle"
            "xyz.xclicker.xclicker"
            "md.obsidian.Obsidian"

            # Creative
            "org.kde.kdenlive"
            "org.gimp.GIMP"
            "cc.arduino.IDE2"

            # Windows apps & games
            "com.usebottles.bottles"
          ];
        in
        builtins.map mkApp appList;

      # Specific overrides for Flatpak applications
      overrides = {
        "com.stremio.Stremio".Environment.QSG_RENDER_LOOP = "threaded";
        "com.discordapp.Discord".Context.filesystems = [ "home" ];
      };
    };
  };

  home.packages = with pkgs; [
    # Plasma Helper
    kdePackages.kconfig

    # Disk Space usage
    kdePackages.filelight

    # General
    unzip
    gzip

    # Art
    blender

    # C/C++ Development
    clang-tools
    gcc
    gdb

    # Arduino
    arduino-language-server

    # Lua
    lua-language-server

    # Python
    pyright
    black

    # Nix
    nixpkgs-fmt
    nil

    # Rust Development
    rust-analyzer
    rustc

    # Python Development
    (python3.withPackages (
      python-pkgs: with python-pkgs; [
        tkinter
      ]
    ))

    # JS/TS
    nodePackages.nodejs
  ];
}
