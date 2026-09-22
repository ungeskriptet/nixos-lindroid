{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  selfPkgs = inputs.self.packages.${pkgs.stdenv.hostPlatform.system};
  lindroidEnv = {
    EGL_PLATFORM = "lindroid-drm";
    GBM_BACKEND = "hybris";
    KWIN_COMPOSE = "O2ES";
    KWIN_DRM_DEVICES = "/dev/dri/by-path/platform-evdi-lindroid.0-card";
    __EGL_VENDOR_LIBRARY_FILENAMES = "${selfPkgs.libhybris}/share/glvnd/egl_vendor.d/10_libhybris.json";
    __GLX_VENDOR_LIBRARY_NAME = "libhybris";
    QT_WAYLAND_SHELL_INTEGRATION = "xdg-shell";
  };
  concatLindroidEnv =
    sep: lib.concatStringsSep sep (lib.mapAttrsToList (n: v: "${n}=${v}") lindroidEnv);
in
{
  console.enable = lib.mkForce false;

  networking = {
    firewall.enable = lib.mkForce false;
    networkmanager.enable = lib.mkForce false;
    useDHCP = lib.mkForce false;
    useHostResolvConf = lib.mkForce false;
    useNetworkd = lib.mkForce true;
  };

  environment = {
    sessionVariables = lindroidEnv;
    plasma6.excludePackages = with pkgs.kdePackages; [
      aurorae
      plasma-browser-integration
      plasma-workspace-wallpapers
      konsole
      kwin-x11
      (lib.getBin qttools) # Expose qdbus in PATH
      ark
      elisa
      gwenview
      okular
      kate
      ktexteditor # provides elevated actions for kate
      khelpcenter
      dolphin
      baloo-widgets # baloo information in Dolphin
      dolphin-plugins
      spectacle
      ffmpegthumbs
      krdp
      kconfig # required for xdg-terminal from xdg-utils
      qtbase # for qtpaths which is required for xdg-mime from xdg-utils
      # touch keyboard
      plasma-keyboard
      qtvirtualkeyboard # used by plasma-keyboard KCM

      # experimental(?) Union theme
      union
    ];
  };

  services = {
    logind.settings.Login = {
      HandlePowerKey = lib.mkForce "ignore";
      HandlePowerKeyLongPress = lib.mkForce "ignore";
    };
    udev.extraRules = ''
      KERNEL=="card*", SUBSYSTEM=="drm", MODE="0666", GROUP="video"
      KERNEL=="renderD*", SUBSYSTEM=="drm", MODE="0666", GROUP="render"
      KERNEL=="event*", SUBSYSTEM=="input", MODE="0666", GROUP="input"
      ACTION=="add|change", KERNEL=="event*", ENV{ID_INPUT_IGNORE}="1", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      ACTION=="add|change", KERNEL=="event*", ATTRS{name}=="Lindroid*", ENV{ID_INPUT_IGNORE}="", ENV{LIBINPUT_IGNORE_DEVICE}=""
      ACTION=="add|change", KERNEL=="event*", ATTRS{name}=="Lindroid-Keyboard-*", TAG+="seat", TAG+="master-of-seat"
    '';
  };

  systemd = {
    packages = [ selfPkgs.create-disp ];
    services = {
      create-disp = {
        wantedBy = [ "graphical.target" ];
        serviceConfig.SupplementaryGroups = [ "video" ];
      };
      sddm.environment = lindroidEnv;
    };
    sockets.systemd-rfkill.enable = false;
    services.systemd-rfkill.enable = false;
  };

  # UIDs above 9999 are unable to access the internet
  ids.uids.nixbld = lib.mkForce 9000;

  hardware.graphics = {
    package = selfPkgs.libhybris;
    extraPackages = [ selfPkgs.libgbm-hybris ];
  };

  nixpkgs.overlays = [
    (self: super: {
      kdePackages = (
        super.kdePackages.overrideScope (
          final: prev: {
            kwin = prev.kwin.overrideAttrs (prevPkg: {
              patches = prevPkg.patches ++ [
                (pkgs.fetchpatch {
                  url = "https://github.com/KDE/kwin/commit/21f875def7ee210b4920fceb90b379160eb38593.patch";
                  hash = "sha256-dqC2IzMU94poVFRNBgQDHSV9ni1B1SoitTOpBC1oJfw=";
                })
              ];
            });
          }
        )
      );
      qt6Packages = (
        super.qt6Packages.overrideScope (
          final: prev: {
            sddm-unwrapped = prev.sddm-unwrapped.overrideAttrs (prevPkg: {
              cmakeFlags = (lib.filter (flag: flag != "-DSDDM_INITIAL_VT=1") prevPkg.cmakeFlags) ++ [
                "-DSDDM_INITIAL_VT=-1"
              ];
            });
          }
        )
      );
    })
  ];
}
