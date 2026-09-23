{
  lib,
  pkgs,
  config,
  ...
}:
let
  autologin = pkgs.autologin.overrideAttrs {
    src = pkgs.fetchFromSourcehut {
      owner = "~kennylevinsen";
      repo = "autologin";
      rev = "f4d3a9b57e2e4644d3fbf83c8dd9d24e570e1358";
      hash = "sha256-KC68HRdI2YBXc5YsOObWu+djNcGoeSfWQ9px3f2yCs4=";
    };
    #mesonFlags = [ (lib.mesonBool "utmpx-enabled" false) ];
    preConfigure = ''
      cp ${pkgs.writeText "meson_options.txt" ''
        option('utmpx-enabled', type: 'boolean', value: false)
      ''} meson_options.txt
    '';
  };
in
{
  services = {
    xserver.desktopManager.xfce = {
      enable = true;
      enableWaylandSession = true;
    };
  };

  systemd = {
    services.autologin = {
      wantedBy = [ "graphical.target" ];
      description = "Autologin";
      after = [
        "systemd-user-sessions.service"
        "plymouth-quit-wait.service"
        "getty@tty1.service"
      ];
      conflicts = [ "getty@tty1.service" ];
      aliases = [ "display-manager.service" ];
      path = with pkgs; [ xfce4-session ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe autologin} lindroid startxfce4 --wayland ${config.services.xserver.desktopManager.xfce.waylandSessionCompositor}";
        IgnoreSIGPIPE = false;
        SendSIGHUP = true;
        TimeoutStopSec = 30;
        KeyringMode = "shared";
        Restart = "always";
        RestartSec = 1;
        StartLimitBurst = 5;
        StartLimitInterval = 30;
      };
    };
    defaultUnit = "graphical.target";
  };

  security.pam.services.autologin = {
    enable = true;
    startSession = true;
  };
}
