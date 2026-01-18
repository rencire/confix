{
  description = "Configure configuration for packages";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    flakelight.url = "github:nix-community/flakelight";
  };

  outputs =
    { flakelight, ... }@inputs:
    flakelight ./. (
      { lib, ... }:
      {
        inherit inputs;
        systems = lib.mkForce [
          "x86_64-linux"
          "aarch64-darwin"
        ];
        # Your library functions
        lib = {
          configure =
            {
              pkgs,
              configDir,
              packages,
              extraArgs ? { },
            }:
            let
              lib = inputs.nixpkgs.lib;
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

                # Check if wrapper exists
                hasWrapper = inputs.nix-wrapper-modules.wrappedModules ? "${pkgName}";

                wrapArgs = {
                  inherit pkgs;
                }
                // customConfig;
              in
              if hasWrapper then inputs.nix-wrapper-modules.wrappedModules."${pkgName}".wrap wrapArgs else pkg
            ) packages;
        };
        # Checks
        checks = pkgs: {
          test-configure-invalid-package =
            let
              fakePackage = pkgs.runCommand "fake" { } "touch $out" // {
                pname = "nonexistent-wrapper-package";
              };

              evalResult = builtins.tryEval (
                let
                  packages = inputs.self.lib.configure {
                    inherit pkgs;
                    configDir = pkgs.emptyDirectory;
                    packages = [ fakePackage ];
                  };
                in
                # Force evaluation of the fakePackage in order to validate that we
                # are calling inputs.nix-wrapper-modules correctly
                # If not, then this test will error before reaching our assertion
                builtins.seq (builtins.elemAt packages 0) true
              );
            in
            pkgs.writeText "test-configure-invalid-package" (
              assert evalResult.success;
              "success"
            );
        };
      }
    );
}
