{
  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flatpak.url = "github:in-a-dil-emma/declarative-flatpak";
    facter.url = "github:nix-community/nixos-facter-modules";
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      # url = "github:nix-community/home-manager/release-25.11";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      lib = inputs.nixpkgs.lib;
      system = "x86_64-linux";
      stateVersion = "25.11";
      mkHosts =
        hosts:
        lib.genAttrs hosts (
          hostname:
          lib.nixosSystem {
            specialArgs = { inherit inputs; };
            inherit system;
            modules = [
              ./hardware/${hostname}.nix
              ./modules/nixos.nix
              {
                facter.reportPath = ./hardware/${hostname}.json;
                system.stateVersion = stateVersion;
                networking.hostName = hostname;
              }
            ];
          }
        );
    in
    {
      nixosConfigurations = mkHosts [ "tuxedo" ];
    };
}
