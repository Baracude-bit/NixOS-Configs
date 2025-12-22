{ inputs, ... }:
{
  imports = [ inputs.nixos-hardware.nixosModules.tuxedo-infinitybook-pro14-gen7 ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    tuxedo-rs = {
      enable = true;
      tailor-gui.enable = true;
    };

    hardware = {
      graphics.enable = true;
      nvidia = {
        nvidiaSettings = false;
        powerManagement.enable = true;
      };
    };
  };

  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
  ];
}
