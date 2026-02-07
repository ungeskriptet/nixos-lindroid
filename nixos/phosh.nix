{ ... }:
{
  services = {
    xserver.desktopManager.phosh = {
      enable = true;
      user = "lindroid";
      group = "users";
    };
  };

  i18n.inputMethod.enable = false;

  systemd.services.phosh.aliases = [ "display-manager.service" ];
}
