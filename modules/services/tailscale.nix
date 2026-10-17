{ self, lib, moduleWithSystem, ... }: {

  flake.nixosModules.tailscale-proxy = { config, pkgs, ... }:
  let
    cfg = config.services.tailscale.proxy;
    tailscale = lib.getExe config.services.tailscale.package;

    # set-config can't express "HTTPS in, plain HTTP backend": the target scheme sets both.
    # It's only used to drop every service handler and advertisement; the CLI re-adds them.
    noServices = pkgs.writeText "tailscale-no-services.json" (builtins.toJSON {
      version = "0.0.1";
      services = {};
    });
  in {
    options.services.tailscale.proxy = {
      enable = lib.mkEnableOption "Tailscale serve reverse proxy";
      svc = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
	  options = {
	    name = lib.mkOption { type = lib.types.str; };
	    localPort = lib.mkOption { type = lib.types.port; };
	  };
	});
	default = [];
	description = "List of services to proxy";
      };
    };

    config = lib.mkIf cfg.enable {
      systemd.services.tailscale-serve-proxy = {
        requires = [ "tailscaled-autoconnect.service" ];
        after = [ "tailscaled-autoconnect.service" "tailscaled-set.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          # Stay active so `nixos-rebuild switch` restarts the unit when the service list changes.
          RemainAfterExit = true;
        };
        script = ''
          ${tailscale} serve set-config --all ${noServices}
          ${lib.concatMapStrings (p: ''
            ${tailscale} serve --service=svc:${p.name} --https=443 http://localhost:${toString p.localPort}
          '') cfg.svc}
        '';
      };
    };
  
  };

  flake.nixosModules.tailscale = moduleWithSystem (perSystem@{ inputs', ... }: nixos@{ config, ... }: {
    imports = [ self.nixosModules.tailscale-proxy ];

    networking.firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };

    services.tailscale = {
      package = inputs'.nixpkgs-unstable.legacyPackages.tailscale;
      enable = true;
      proxy.enable = true;
      useRoutingFeatures = "server";
      authKeyFile = config.sops.secrets.tailscale-auth-key.path;
      extraUpFlags = [ "--advertise-exit-node" ];
      extraSetFlags = [ "--advertise-exit-node" ];
    };

    systemd.services.tailscaled.environment.TS_DEBUG_FIREWALL_MODE = "nftables";
  });
}
