{ inputs, ... }:
{
  imports = [ inputs.nixos-hardware.nixosModules.gigabyte-b550];

  users.users.victor.hashedPassword = "$y$j9T$oK9h70V4sKxPScS1BZl9s1$9RzS0Egf/yY6HQwJ5keiKiHimV6d6TV6dIcv9MBchZ5";

  services.xserver.videoDrivers = [ "amd" ];

  hardware = {
    graphics.enable = true;
  };

  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
  ];
}
