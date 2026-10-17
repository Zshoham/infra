{ self, ... }: {

  flake.nixosModules.bat = { pkgs, ... }: {
    imports = [ 
      self.nixosModules.batHardware
      self.nixosModules.server
      self.nixosModules.smart
      self.nixosModules.postgres
      self.nixosModules.rrr
      self.nixosModules.immich
    ];

    networking.hostName = "bat";
    time.timeZone = "Asia/Jerusalem";

    services.fwupd.enable = true;
    hardware.graphics.enable = true;

    # Encoding belongs to the host: bat has a Radeon 680M, without AV1 encoding.
    services.jellyfin = {
      forceEncodingConfig = true;
      hardwareAcceleration = {
        enable = true;
        type = "vaapi";
        device = "/dev/dri/renderD128";
      };
      transcoding = {
        enableHardwareEncoding = true;
        hardwareEncodingCodecs.hevc = true;
        hardwareDecodingCodecs = {
          h264 = true;
          hevc = true;
          vp9 = true;
          av1 = true;
        };
        enableToneMapping = true;
        throttleTranscoding = true;
      };
    };

    services.immich = {
      accelerationDevices = [ "/dev/dri/renderD128" ];
      machine-learning.enable = false;
    };
  
    environment.systemPackages = with pkgs; [
      devenv
      zellij
      neovim
    ];

    system.stateVersion = "25.11";
  };
}
