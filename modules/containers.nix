{ self, inputs, lib, config, flake-parts-lib, ... }: {
  # Declares `flake.nixosContainerConfigurations`, the container counterpart of
  # `flake.nixosConfigurations`, and builds an image package for each entry.
  options.flake = flake-parts-lib.mkSubmoduleOptions {
    nixosContainerConfigurations = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = { };
      description = ''
        NixOS configurations built into OCI/docker images, defined as NixOS
        modules. Each one is also exposed as the flake package `<name>-image`.
      '';
      # Containers are built from nixpkgs-unstable, the nixpkgs that szpkgs
      # follows, so an image does not carry a stable and an unstable copy of
      # every shared library.
      apply = lib.mapAttrs (name: module:
        inputs.nixpkgs-unstable.lib.nixosSystem {
          modules = [
            self.nixosModules.container
            module
            { networking.hostName = lib.mkDefault name; }
          ];
        }
      );
    };
  };

  config.perSystem = { system, ... }: {
    packages = lib.mapAttrs' (name: nixos:
      lib.nameValuePair "${name}-image" nixos.config.system.build.ociImage
    ) (lib.filterAttrs (_: nixos:
      nixos.pkgs.stdenv.hostPlatform.system == system
    ) config.flake.nixosContainerConfigurations);
  };
}
