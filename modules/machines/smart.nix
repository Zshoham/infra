{
  flake.nixosModules.smart = {
    services.smartd = {
      enable = true;
      notifications = {
        mail.enable = false;
        wall.enable = false;
        x11.enable = false;
        systembus-notify.enable = false;
      };
    
      extraOptions = [ "--attributelog=/var/log/smartd/" ];
    };
    
    systemd.services.smartd.serviceConfig.LogsDirectory = "smartd";
    
    services.logrotate.settings.smartd = {
      files = [ "/var/log/smartd/*.csv" ];
      frequency = "monthly";
      rotate = 6;
      compress = true;
      missingok = true;
      notifempty = true;
    };
  };
}
