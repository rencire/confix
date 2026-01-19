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
        lib = rec {
          configure =
            { pkgs
            , configDir
            , extraArgs ? { }
            ,
            }:
            let
              lib = inputs.nixpkgs.lib;
              moduleArgs = { inherit pkgs lib; } // extraArgs;
              configFiles = builtins.readDir configDir;
              nixFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name) configFiles;

              results = lib.mapAttrs'
                (
                  filename: _:
                    let
                      pkgName = lib.removeSuffix ".nix" filename;
                      customConfig = import (configDir + "/${filename}") moduleArgs;
                    in
                    lib.nameValuePair pkgName {
                      inherit
                        pkgName
                        customConfig;
                    }
                )
                nixFiles;

              enabledResults = lib.filterAttrs (name: value: (value.customConfig.enable or true)) results;
            in
            lib.mapAttrs
              (
                name: value:
                wrapPackage {
                  inherit pkgs;
                  inherit (value)
                    pkgName
                    customConfig;
                }
              )
              enabledResults
          ;

          configureAsList = args: builtins.attrValues (configure args);

          configureInline =
            { pkgs
            , packages
            ,
            }:
            let
              lib = inputs.nixpkgs.lib;
            in
            lib.mapAttrs
              (
                pkgName: customConfig:
                wrapPackage {
                  inherit
                    pkgs
                    pkgName
                    customConfig;
                }
              )
              packages
          ;

          wrapPackage =
            { pkgs
            , pkgName
            , customConfig
            ,
            }:
            let
              hasWrapper = inputs.nix-wrapper-modules.wrappedModules ? "${pkgName}";
              wrapArgs = { inherit pkgs; } // (builtins.removeAttrs customConfig [ "enable" ]);
            in
            if hasWrapper then
              inputs.nix-wrapper-modules.wrappedModules."${pkgName}".wrap wrapArgs
            else if customConfig ? package then
              customConfig.package
            else
              pkgs.${pkgName}
          ;
        };
        # Checks
        checks = pkgs: {
          test-new-api =
            let
              configured = inputs.self.lib.configure {
                inherit pkgs;
                configDir = ./tests/mock-config;
              };
              configuredList = inputs.self.lib.configureAsList {
                inherit pkgs;
                configDir = ./tests/mock-config;
              };
              inline = inputs.self.lib.configureInline {
                inherit pkgs;
                packages = {
                  hello = { };
                };
              };
            in
            pkgs.writeText "test-new-api-results" (
              assert builtins.isAttrs configured;
              assert configured ? tealdeer;
              assert !(configured ? "disabled-pkg");
              assert builtins.isList configuredList;
              assert builtins.length configuredList == 1;
              assert inline ? hello;
              "success"
            );

          test-configure-invalid-package =
            let
              evalResult = builtins.tryEval (
                let
                  # Testing that we can configure a package that doesn't have a wrapper
                  packages = inputs.self.lib.configureInline {
                    inherit pkgs;
                    packages = {
                      hello = { };
                    };
                  };
                in
                builtins.seq packages.hello true
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
