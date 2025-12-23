{ inputs, ... }:
{
  imports = [ inputs.nixos-hardware.nixosModules.tuxedo-infinitybook-pro14-gen7 ];

  users.users.victor.hashedPassword = "$y$j9T$oP0a3qfVM87Y4WqpNSCnF/$Wvod.OTB.jFbUnERpsI54hA1vVIGayZ8zt02KzyG/SD";

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    tuxedo-rs = {
      enable = true;
      tailor-gui.enable = true;
    };

    nvidia = {
      open = false;
      nvidiaSettings = false;
      powerManagement.enable = true;
    };
  };

  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
  ];
}
