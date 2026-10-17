{

  flake.nixosModules.rrr = { config, ... }: 
  let
    commonConfig = {
      enable = true;
      openFirewall = false;
      group = "media";
      settings.auth.enabled = false;
      settings.auth.method = "External";
    };
  in {
    services.tailscale.proxy.svc = [
      { name = "video"; localPort = 8096; }
      { name = "torrent"; localPort = 8080; }
    ];

    services.flaresolverr.enable = true;

    services.qbittorrent = {
      enable = true;
      openFirewall = false;
      group = "media";
      serverConfig = {
        LegalNotice.Accepted = true;
        BitTorrent.Session.DefaultSavePath = "/mnt/downloads";
        Preferences = {
          WebUI = {
            AuthSubnetWhitelist = "127.0.0.1";
            AuthSubnetWhitelistEnabled = "false";
            LocalHostAuth = "false";
          };
        };
      };
    };

    services.prowlarr = {
      enable = true;                     
      openFirewall = false;
      settings.auth.enabled = false;
      settings.auth.method = "External";
    };

    services.sonarr = commonConfig;
    services.radarr = commonConfig;

    services.jellyfin = {
      enable = true;
      openFirewall = false;
      group = "media";
    };
  };
}
