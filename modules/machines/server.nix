{ self, ... }: {
  flake.nixosModules.server = { pkgs, szpkgs, ... }: {
    imports = [ 
      self.nixosModules.base
      self.nixosModules.tailscale
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 25;
    };

    networking.nftables.enable = true;
    networking.firewall.enable = true;
    services.openssh.enable = true;
  
    services.journald.extraConfig = ''
      SystemMaxUse=1G
      MaxRetentionSec=2week
    '';
  };
}
