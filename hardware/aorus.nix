{ inputs, pkgs, ... }:
{
  imports = [ inputs.nixos-hardware.nixosModules.gigabyte-b550 ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  users.users.victor.hashedPassword = "$y$j9T$oK9h70V4sKxPScS1BZl9s1$9RzS0Egf/yY6HQwJ5keiKiHimV6d6TV6dIcv9MBchZ5";

  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
  ];

  environment.variables = {
    # Force KWin to use the RX 6800 (usually card1) instead of the iGPU
    "KWIN_DRM_DEVICES" = "/dev/dri/card1:/dev/dri/card0";
  };

  # ============================================================================
  # SECONDARY STORAGE CONFIGURATION
  # ============================================================================
  
  environment.etc."crypttab".text = ''
    # <Mapper Name>  <Device UUID>                         <Keyfile Path>               <Options>
    storage          UUID=adb3f0a5-3a17-449d-b12b-f8875ac82ef9  /data/etc/keys/StorageKey    nofail,tries=0
  '';

  # Mount Point
  fileSystems."/mnt/storage" = {
    device = "/dev/mapper/storage";
    fsType = "ext4";
    options = [ "nofail" "defaults" ];
  };
}
