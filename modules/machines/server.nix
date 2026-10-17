{ self, ... }: {
  flake.nixosModules.server = { pkgs, ... }: {
    imports = [
      self.nixosModules.nix
      self.nixosModules.users
      self.nixosModules.sops
      self.nixosModules.tailscale
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 25;
    };

    networking.networkmanager.enable = true;
    networking.nftables.enable = true;
    networking.firewall.enable = true;
    services.openssh.enable = true;
  
    services.journald.extraConfig = ''
      SystemMaxUse=1G
      MaxRetentionSec=2week
    '';

    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    environment.enableAllTerminfo = true;
    environment.systemPackages = with pkgs; [
      curl
      git
      sops
    ];
  };
}
