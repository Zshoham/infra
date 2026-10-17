{ inputs, ... }: {

  flake.nixosModules.sops = {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops = {
      defaultSopsFile = ../secrets.yaml;
      age.keyFile = "/etc/sops/keys/age.txt";

      secrets = {
        sgame-password-hash = {};
        tailscale-auth-key = {};
      };
    };
  };
}
