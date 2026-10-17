{ moduleWithSystem, ... }: {

  flake.nixosModules.immich = moduleWithSystem ({ inputs', ... }: {
    users.users.immich.extraGroups = [ "video" "render" ];

    services.tailscale.proxy.svc = [
      { name = "images"; localPort = 2283; }
    ];
 
    services.immich = {
      package = inputs'.nixpkgs-unstable.legacyPackages.immich;
      enable = true;
      host = "0.0.0.0";
      port = 2283;
      openFirewall = false;
      group = "media";
      mediaLocation = "/mnt/photos";
      settings = {
        backup.database.enabled = false;
        machineLearning.enabled = false;
        map.enabled = false;
        metadata.faces.import = false;
        newVersionCheck.enabled = false;
      };
    };
  });
}
