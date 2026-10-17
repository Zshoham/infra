{
  flake.nixosModules.postgres = { ... }: {
    services.postgresql = {
      enable = true;
      dataDir = "/mnt/postgresql";
    };
  };
}
