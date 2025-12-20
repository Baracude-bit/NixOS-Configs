{ pkgs, inputs, ... }:
{
  imports = with inputs; [ flatpak.homeModules.default ];

  programs = {
    gh.enable = true;
    git.enable = true;
  };

  services = {
    syncthing.enable = true;

    flatpak = {
      remotes."flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";

      packages =
        let
          mkApp = pkg: "flathub:app/${pkg}/x86_64/stable";
        in
        builtins.map mkApp [
          "io.github.celluloid_player.Celluloid"
          "io.gitlab.librewolf-community"
          "org.qbittorrent.qBittorrent"
          "org.libreoffice.LibreOffice"
          "org.keepassxc.KeePassXC"
          "com.discordapp.Discord"
          "com.usebottles.bottles"
          "com.system76.Popsicle"
          "md.obsidian.Obsidian"
          "com.stremio.Stremio"
          "org.signal.Signal"
          "org.videolan.VLC"
          "org.kde.kdenlive"
          "cc.arduino.IDE2"
          "org.gimp.GIMP"
        ];

      overrides = {
        "com.stremio.Stremio".Environment.QSG_RENDER_LOOP = "threaded";
        "com.discordapp.Discord".Context.filesystems = [ "home" ];
      };
    };
  };

  home.packages = with pkgs; [
    # General
    blender

    # C/C++
    gcc
    gdb

    # Rust
    rustc

    # Python
    python315
  ];
}
