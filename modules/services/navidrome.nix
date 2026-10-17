{

  flake.nixosModules.navidrome = { ... }: {
    services.tailscale.proxy.svc = [
      { name = "music"; localPort = 4533; }
    ];

    services.navidrome = {
      enable = true;
      group = "media";
      openFirewall = false;
      settings = {
        Address = "0.0.0.0";
        Port = 4533;
        MusicFolder = "/mnt/music";
      };
    };
  };
}
