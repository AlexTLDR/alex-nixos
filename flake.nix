{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Zed editor - latest version from GitHub
    zed-editor = {
      url = "github:zed-industries/zed";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, zed-editor, ... }: {
    nixosConfigurations = {
      # use your own hostname instead of mine, nixos
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # TODO replace alex with your own username
            home-manager.users.alex = import ./home.nix;

            # Pass Zed package to home-manager
            home-manager.extraSpecialArgs = {
              zed-package = zed-editor.packages.x86_64-linux.default;
            };

          }
        ];
      };
    };
  };
}
