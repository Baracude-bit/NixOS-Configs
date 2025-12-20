{
  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flatpak.url = "github:in-a-dil-emma/declarative-flatpak";
    facter.url = "github:nix-community/nixos-facter-modules";
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    import-tree.url = "github:vic/import-tree";

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
      lib = import ./lib.nix { inherit inputs; };
    in
    {
      nixosConfigurations = lib.mkHosts [ "tuxedo" ];
    };
}
