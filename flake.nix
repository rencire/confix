{
  description = "Configure configuration for packages";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-wrapper-modules,
    }:
    {
      lib = {
        wrapPackages =
          {
            pkgs,
            configDir,
            packages,
          }:
          map (
            pkg:
            let
              pkgName = pkg.pname or pkg.name;
              configPath = configDir + "/${pkgName}.nix";
              customConfig = if builtins.pathExists configPath then import configPath else { };
              wrapArgs = {
                inherit pkgs;
              }
              // customConfig;
            in
            nix-wrapper-modules.wrapperModules."${pkgName}".wrap wrapArgs
          ) packages;
      };
    };
}
