{
  description = "ZaneyOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # nixpkgs-camera-working.url = "github:nixos/nixpkgs?rev=5633bcff0c6162b9e4b5f1264264611e950c8ec7";

    agenix.url = "github:ryantm/agenix";

    stylix.url = "github:danth/stylix";
    fine-cmdline = {
      url = "github:VonHeikemen/fine-cmdline.nvim";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, agenix, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      host = "loz_dell_nixos";
      username = "lbesnard";
    in
    {
      nixosConfigurations = {
        "${host}" = nixpkgs.lib.nixosSystem {
          specialArgs = {
	    inherit system;
            inherit inputs;
            inherit username;
            inherit host;
          };
          modules = [
            # agenix.nixosModules.default
            # {
            #   age.secrets.aws_cred = { 
            #     file = secrets/aws_cred.age;
            #     path = /home/${username}/.aws/credentials;
            #   };
            # }
            ./hosts/${host}/config.nix
            agenix.nixosModules.default
            {
              environment.systemPackages = [ agenix.packages.${system}.default ];
            }
            inputs.stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {
                inherit username;
                inherit inputs;
                inherit host;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} = import ./hosts/${host}/home.nix;
              environment.systemPackages = [ agenix.packages.${system}.default ];
            }
          ];
        };
      };
    };
}
