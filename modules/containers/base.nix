{
  # Base for NixOS configurations that are shipped as OCI/docker images instead
  # of being booted. It adds `system.build.ociImage`. Applied automatically to
  # everything in `flake.nixosContainerConfigurations`.
  #
  # The image does not run systemd: the system is activated at build time, so
  # /etc, users, home directories and setuid wrappers are already in place when
  # a command is started in the container.
  flake.nixosModules.container = { config, lib, pkgs, utils, modulesPath, ... }:
  let
    cfg = config.container;

    # Gives every command the environment a NixOS login session would have.
    entrypoint = pkgs.writeShellScript "entrypoint" ''
      export USER="''${USER:-$(${pkgs.coreutils}/bin/id -un)}"
      . ${config.system.build.setEnvironment}
      exec "$@"
    '';
  in {
    # No docs, default packages or desktop integration.
    imports = [ "${modulesPath}/profiles/minimal.nix" ];

    options.container = {
      name = lib.mkOption {
        type = lib.types.str;
        default = config.networking.hostName;
        defaultText = lib.literalExpression "config.networking.hostName";
        description = "Name of the image.";
      };

      tag = lib.mkOption {
        type = lib.types.str;
        default = "latest";
        description = "Tag of the image.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "root";
        description = "User that commands in the container run as.";
      };

      command = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ (utils.toShellPath config.users.users.${cfg.user}.shell) "-l" ];
        defaultText = lib.literalExpression "login shell of `container.user`";
        description = "Command run when the container is started without one.";
      };
    };

    config = {
      boot.isContainer = true;
      networking.firewall.enable = false;

      # Users only exist declaratively, there is nothing to log in to.
      users.mutableUsers = false;
      users.allowNoPasswordLogin = true;

      # Mounting is up to the container runtime.
      system.activationScripts.specialfs = lib.mkForce "";

      # The image is rebuilt rather than managed from the inside: no nix (there
      # is no daemon to serve it), installer tools or switch-to-configuration.
      nix.enable = lib.mkDefault false;
      system.disableInstallerTools = true;
      system.switch.enable = false;

      system.build.ociImage = pkgs.dockerTools.buildLayeredImage {
        inherit (cfg) name tag;

        enableFakechroot = true;
        fakeRootCommands = ''
          mkdir -p /etc /run/wrappers /var/tmp
          mkdir -m 1777 /tmp
          chmod 1777 /var/tmp

          ${config.system.build.toplevel}/activate

          # Normally done by suid-sgid-wrappers.service at boot.
          ${config.systemd.services.suid-sgid-wrappers.script}
        '';

        config = {
          Entrypoint = [ entrypoint ];
          Cmd = cfg.command;
          User = cfg.user;
          WorkingDir = config.users.users.${cfg.user}.home;
          Env = [
            # For processes that bypass the entrypoint (`docker exec`).
            "PATH=/run/wrappers/bin:/run/current-system/sw/bin"
            # Nothing logs the user in, so nothing else sets it; terminal
            # multiplexers and editors use it to pick the shell they spawn.
            "SHELL=${utils.toShellPath config.users.users.${cfg.user}.shell}"
          ];
        };
      };
    };
  };
}
