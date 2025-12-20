{ pkgs, inputs, ... }:
{
  imports = with inputs; [ flatpak.homeModules.default ];

  # Git & Github configuration
  programs = {
    gh.enable = true;
    git.enable = true;
  };

  services = {
    syncthing.enable = true;

    # --- FLATPAK CONFIGURATION ---
    flatpak = {
      remotes."flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";

      # Helper function to generate full Flathub reference
      packages = let
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
          "md.obsidian.Obsidian"
          "com.system76.Popsicle"

          # Creative
          "org.kde.kdenlive"
          "org.gimp.GIMP"
          "cc.arduino.IDE2"

          # Gaming
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
    # General
    blender

    # C/C++ Development
    gcc
    gdb

    # Rust Development
    rustc

    # Python Development
    python315
  ];
}
