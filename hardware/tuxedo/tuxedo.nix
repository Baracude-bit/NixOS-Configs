{ inputs, ... }:
{
  imports = with inputs; [
    nixos-hardware.nixosModules.tuxedo-infinitybook-pro14-gen7
  ];
}
