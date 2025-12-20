{ pkgs, ... }:
{
  environment.variables.NIXOS_OZONE_WL = 1;
  programs.partition-manager.enable = true;
  networking.networkmanager.enable = true;

  services = {
    desktopManager.plasma6.enable = true;
    displayManager = {
      autoLogin.user = "victor";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    kwin-x11
    aurorae
    elisa
    krdp
  ];
}
