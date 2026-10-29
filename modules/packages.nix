{ inputs, ... }: {
  # Exposes package sets for the host system as module arguments to every module
  # in the NixOS configuration:
  #   pkgs-stable   - alias of the host's `pkgs`, for being explicit
  #   szpkgs        - packages from the custom szpkgs flake
  #   pkgs-unstable - nixpkgs-unstable
  flake.nixosModules.packages = { pkgs, ... }:
  let
    system = pkgs.stdenv.hostPlatform.system;
  in {
    # Same key everywhere this module is imported => the module system dedupes it.
    key = "packages";

    _module.args = {
      pkgs-stable = pkgs;
      szpkgs = inputs.szpkgs.packages.${system};
      pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
    };
  };
}
