{ lib, pkgs, ... }:
{
  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
  };

  environment = {
    plasma6.excludePackages = (
      with pkgs.kdePackages;
      [
        baloo
        baloo-widgets
        elisa
        khelpcenter
      ]
    );
    systemPackages = with pkgs; [ kdePackages.yakuake ];
    etc."xdg/baloofilerc".source = (pkgs.formats.ini { }).generate "baloorc" {
      "Basic Settings" = {
        "Indexing-Enabled" = false;
      };
    };
  };

  nixpkgs.overlays = [
    (self: super: {
      kdePackages = (
        super.kdePackages.overrideScope (
          final: prev: {
            sddm-unwrapped = prev.callPackage ../pkgs/sddm-unwrapped { };
          }
        )
      );
    })
  ];
}
