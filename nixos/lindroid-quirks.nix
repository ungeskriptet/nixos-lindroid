{
  lib,
  pkgs,
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
    KWIN_DRM_NO_AMS = "1";
    KWIN_DRM_USE_MODIFIERS = "0";
    __EGL_VENDOR_LIBRARY_FILENAMES = "${selfPkgs.libhybris}/share/glvnd/egl_vendor.d/10_libhybris.json";
    __GLX_VENDOR_LIBRARY_NAME = "libhybris";
  };
in
{
  console.enable = true;

  networking = {
    firewall.enable = lib.mkForce false;
    networkmanager.enable = lib.mkForce false;
    useDHCP = lib.mkForce false;
    useHostResolvConf = lib.mkForce false;
    useNetworkd = lib.mkForce true;
  };

  environment = {
    sessionVariables = lindroidEnv;
  };

  services = {
    displayManager.sddm.settings = {
      General = {
        DisplayServer = "wayland";
        GreeterEnvironment = lib.concatStringsSep "," (
          (lib.mapAttrsToList (n: v: "${n}=${v}") lindroidEnv) ++ [ "QT_WAYLAND_SHELL_INTEGRATION=xdg-shell" ]
        );
        InputMethod = "";
      };
      Wayland = {
        CompositorCommand = "${lib.getExe' pkgs.kdePackages.kwin "kwin_wayland"} --no-global-shortcuts --no-kactivities --no-lockscreen --locale1 --inputmethod maliit-keyboard";
      };

    };
    logind.settings.Login = {
      HandlePowerKey = lib.mkForce "ignore";
      HandlePowerKeyLongPress = lib.mkForce "ignore";
    };
    udev.extraRules = ''
      KERNEL=="card*", SUBSYSTEM=="drm", MODE="0660", GROUP="video"
      KERNEL=="renderD*", SUBSYSTEM=="drm", MODE="0660", GROUP="render"
      KERNEL=="event*", SUBSYSTEM=="input", MODE="0660", GROUP="input"
      ACTION=="add|change", KERNEL=="event*", ENV{ID_INPUT_IGNORE}="1", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      ACTION=="add|change", KERNEL=="event*", ATTRS{name}=="Lindroid*", ENV{ID_INPUT_IGNORE}="", ENV{LIBINPUT_IGNORE_DEVICE}=""
      ACTION=="add|change", KERNEL=="event*", ATTRS{name}=="Lindroid-Keyboard-*", TAG+="seat", TAG+="master-of-seat"
    '';
  };

  systemd = {
    packages = [ selfPkgs.create-disp ];
    services = {
      create-disp.wantedBy = [ "graphical.target" ];
      display-manager.environment = lindroidEnv;
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
}
