{ pkgs, ... }:
{
  services.flatpak.enable = true;

  programs = {
    nix-index-database.comma.enable = true;
    gamescope.enable = true;
    gamemode.enable = true;
    nix-ld.enable = true;

    steam = {
      enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    nh = {
      enable = true;
      flake = "/etc/nixos";
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 3";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.full
    neovim
    sbctl
  ];

  fonts.packages = with pkgs; [
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
    liberation_ttf
    vista-fonts
    noto-fonts
    corefonts
  ];
}
