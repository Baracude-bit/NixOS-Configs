{
  networking = {
    firewall.allowedUDPPorts = [ 9 ];
    interfaces.enp12s0.wakeOnLan.enable = true;
  };

  fileSystems."/home/emi/Games" = {
    fsType = "ntfs3";
    options = [ "nofail" ];
    device = "/dev/disk/by-label/Games";
  };
}
