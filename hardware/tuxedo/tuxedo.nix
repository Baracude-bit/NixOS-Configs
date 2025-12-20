{ inputs, ... }:
{
  imports = with inputs; [
    nixos-hardware.nixosModules.tuxedo-infinitybook-pro14-gen7
  ];

  hardware.tuxedo-rs = {
    enable = true;
    tailor-gui.enable = true;
  };
}
