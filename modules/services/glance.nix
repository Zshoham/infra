{
  flake.nixosModules.glance = { ... }: {
    services.tailscale.proxy.svc = [
      { name = "home"; localPort = 8181; }
    ];
    
    services.glance = {
      enable = true;
      openFirewall = false;
      settings = {
        server.host = "0.0.0.0";
        server.port = 8181;
      };
    };
  };
}
