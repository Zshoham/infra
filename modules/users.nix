{ self, ... }: {
  flake.nixosModules.users = { config, ...  }: {
    imports = [ self.nixosModules.sops ];
    sops.secrets.sgame-password-hash.neededForUsers = true;
    users.mutableUsers = false;

    users.groups.media = {
      name = "media";
    };

    users.groups.code = {
      name = "code";
    };

    users.users.sgame = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets.sgame-password-hash.path;
      extraGroups = [ "wheel" "media" "code" ];
    };

    nix.settings.trusted-users = [ "root" "@wheel" ];
  };
}
