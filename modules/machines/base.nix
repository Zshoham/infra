{ self, ... }: {
  flake.nixosModules.base = { pkgs, szpkgs, ... }: {
    imports = [
      self.nixosModules.nix
      self.nixosModules.users
      self.nixosModules.packages
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.networkmanager.enable = true;
  
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    environment.systemPackages = [
      pkgs.curl
      pkgs.sops
      szpkgs.git
    ];
  };
}
