{
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:
{
  imports = [
    ../modules/lxc-container.nix
    ../modules/filesystems.nix
    #../modules/getty.nix
    ../modules/pam.nix
    ./lindroid-quirks.nix
    #./plasma-desktop.nix
    ./uncompressed.nix
    ./xfce.nix
    #./phosh.nix
  ];

  programs = {
    htop.enable = true;
    git.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };

  environment.systemPackages = with pkgs; [
    gdbHostCpuOnly
    kdePackages.kwin
    kmscube
    libdrm
    ripgrep
    strace
  ];

  users = {
    mutableUsers = false;
    users.lindroid = {
      isNormalUser = true;
      hashedPassword = "";
      extraGroups = [ "wheel" ];
    };
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "@wheel" ];
    };
  };

  system.stateVersion = "26.05";
}
