{
  description = "My Modular Dendritic NixOS Flake Setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    noctalia.url = "github:noctalia-dev/noctalia";
  };

  outputs = { self, nixpkgs, spicetify-nix, ... }@inputs: {
    nixosConfigurations.myMachine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/myMachine/default.nix
      ];
    };
  };
}
