{ self, ... }: {
  flake.nixosModules.base = { pkgs, ... }: {
    imports = [
      self.nixosModules.nix
      self.nixosModules.users
      self.nixosModules.dev
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.networkmanager.enable = true;

    environment.systemPackages = [ pkgs.sops ];
  };
}
