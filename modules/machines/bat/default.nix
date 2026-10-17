{ self, inputs, ... }: {

  flake.nixosConfigurations.bat = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.nixosModules.bat ];
  };

}
