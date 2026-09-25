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
    vim = {
      enable = true;
      defaultEditor = true;
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
    users = {
      lindroid = {
        isNormalUser = true;
        hashedPassword = "";
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+HHP+nC6vrDwqEbTgiNhFnaqD3WEBgZMq7FUPWV0Ls david-w.eu"
        ];
      };
      root = {
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+HHP+nC6vrDwqEbTgiNhFnaqD3WEBgZMq7FUPWV0Ls david-w.eu"
        ];
      };
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
