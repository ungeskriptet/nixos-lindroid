{
  lib,
  config,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/virtualisation/lxc-instance-common.nix"

  ];

  options = { };

  config =

    {
      #boot.isContainer = true;
      boot.kernel.enable = false;
      boot.modprobeConfig.enable = false;
      boot.initrd.enable = false;
      boot.loader.grub.enable = false;
      environment.etc."sysctl.d/55-nixos-aslr-entropy.conf".enable = lib.mkForce false;
      systemd.services.register-nix-paths = {
        description = "Register Nix Store Paths";
        unitConfig = {
          DefaultDependencies = false;
          ConditionPathExists = "/nix-path-registration";
        };
        wantedBy = [ "sysinit.target" ];
        before = [
          "sysinit.target"
          "shutdown.target"
          "nix-daemon.socket"
          "nix-daemon.service"
        ];
        after = [ "local-fs.target" ];
        conflicts = [ "shutdown.target" ];
        restartIfChanged = false;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ${lib.getExe' config.nix.package.out "nix-store"} --load-db < /nix-path-registration
          rm /nix-path-registration

          # nixos-rebuild also requires a "system" profile
          ${lib.getExe' config.nix.package.out "nix-env"} -p /nix/var/nix/profiles/system --set /run/current-system
        '';
      };

      system.nixos.tags = lib.mkOverride 99 [ "lxc" ];
      image.extension = "tar.xz";
      image.filePath = "tarball/${config.image.fileName}";
      system.build.image = lib.mkOverride 99 config.system.build.tarball;

      system.build.tarball = pkgs.callPackage ../../lib/make-system-tarball.nix {
        fileName = config.image.baseName;
        extraArgs = "--owner=0";

        storeContents = [
          {
            object = config.system.build.toplevel;
            symlink = "none";
          }
        ];

        contents = [
          {
            source = config.system.build.toplevel + "/init";
            target = "/sbin/init";
          }
          # Technically this is not required for lxc, but having also make this configuration work with systemd-nspawn.
          # Nixos will setup the same symlink after start.
          {
            source = config.system.build.toplevel + "/etc/os-release";
            target = "/etc/os-release";
          }
        ];

        extraCommands = "mkdir -p proc sys dev";
      };

      system.build.squashfs = pkgs.callPackage ../../lib/make-squashfs.nix {
        fileName = "nixos-lxc-image-${pkgs.stdenv.hostPlatform.system}";

        hydraBuildProduct = true;
        noStrip = true; # keep directory structure
        comp = "zstd -Xcompression-level 6";

        storeContents = [ config.system.build.toplevel ];

        pseudoFiles = [
          "/sbin d 0755 0 0"
          "/sbin/init s 0555 0 0 ${config.system.build.toplevel}/init"
          "/dev d 0755 0 0"
          "/proc d 0555 0 0"
          "/sys d 0555 0 0"
        ];
      };

      system.build.installBootLoader = pkgs.writeScript "install-lxc-sbin-init.sh" ''
        #!${pkgs.runtimeShell}
        ${pkgs.coreutils}/bin/ln -fs "$1/init" /sbin/init
      '';
    };
}
