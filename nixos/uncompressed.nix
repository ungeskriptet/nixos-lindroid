{
  lib,
  config,
  pkgs,
  modulesPath,
  ...
}:

{
  config = {
    system.build.uncompressed = pkgs.callPackage "${modulesPath}/../lib/make-system-tarball.nix" {
      fileName = config.image.baseName;
      extraArgs = "--owner=0";
      compressCommand = "cat";
      compressionExtension = "";

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
        {
          source = config.system.build.toplevel + "/etc/os-release";
          target = "/etc/os-release";
        }
      ];

      extraCommands = "mkdir -p proc sys dev/pts lindroid";
    };
  };
}
