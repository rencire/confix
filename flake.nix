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
        configure =
          {
            pkgs,
            configDir,
            packages,
            extraArgs ? { },
          }:
          let
            lib = nixpkgs.lib;
            moduleArgs = {
              inherit pkgs lib;
            }
            // extraArgs;
          in
          map (
            pkg:
            let
              pkgName = pkg.pname or pkg.name;
              configPath = configDir + "/${pkgName}.nix";
              customConfig = if builtins.pathExists configPath then import configPath moduleArgs else { };
              wrapArgs = {
                inherit pkgs;
              }
              // customConfig;
            in
            nix-wrapper-modules.wrappedModules."${pkgName}".wrap wrapArgs
          ) packages;
      };
    };
}
