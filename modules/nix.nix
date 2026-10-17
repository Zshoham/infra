{
  flake.nixosModules.nix = {
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
      persistent = true;
      randomizedDelaySec = "3600";
    };

    nix.optimise = {
      automatic = true;
      dates = "weekly";
      persistent = true;
      randomizedDelaySec = "3600";
    };
  };
}
