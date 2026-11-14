{ self, ... }: {

  flake.nixosContainerConfigurations.devbox = { pkgs, ... }: {
    imports = [ self.nixosModules.dev ];

    nixpkgs.hostPlatform = "x86_64-linux";

    i18n.defaultLocale = "en_US.UTF-8";

    users.users.build = {
      isNormalUser = true;
      uid = 30000;
      shell = pkgs.fish;
    };

    security.sudo.extraRules = [{
      users = [ "build" ];
      commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
    }];

    container.user = "build";

    system.stateVersion = "26.05";
  };

}
