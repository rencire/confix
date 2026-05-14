{ inputs, ... }:
let
  inherit (builtins) match;
  inherit (inputs.nixpkgs) lib;
  agentSkillsLib = inputs."agent-skills".lib."agent-skills";

  baseNameOf = path:
    let m = match ".*/([^/]+)" path; in
    if m == null then path else builtins.elemAt m 0;

  rewriteSkillName = { oldName, newName, text }:
    builtins.replaceStrings
      [ "name: ${oldName}" ]
      [ "name: ${newName}" ]
      text;

  mkPrefixedSkills = { source, prefix, skills }:
    builtins.listToAttrs (
      builtins.map
        (path:
          let
            baseName = baseNameOf path;
            prefixedName = "${prefix}-${baseName}";
          in
          {
            name = prefixedName;
            value = {
              from = source;
              inherit path;
              rename = prefixedName;
              transform = { original, ... }:
                builtins.replaceStrings
                  [ "~/.gstack/" ]
                  [ "\${GSTACK_HOME:-\$HOME/.gstack}/" ]
                  (rewriteSkillName {
                    oldName = baseName;
                    newName = prefixedName;
                    text = original;
                  });
            };
          })
        skills
    );

  mkSource = name: cfg:
    {
      subdir = cfg.subdir or ".";
      idPrefix = cfg.idPrefix or name;
    }
    // (if cfg ? input then { path = inputs.${cfg.input}; } else { path = cfg.path; })
    // (if cfg ? filter then { inherit (cfg) filter; } else { });
in
rec {
  configure =
    { pkgs
    , configDir
    , extraArgs ? { }
    ,
    }:
    let
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
      wrapperSet = inputs.nix-wrapper-modules.wrappers;
      hasWrapper = wrapperSet ? "${pkgName}";
      wrapArgs = { inherit pkgs; } // (builtins.removeAttrs customConfig [ "enable" ]);
    in
    if hasWrapper then
      wrapperSet."${pkgName}".wrap wrapArgs
    else if customConfig ? package then
      customConfig.package
    else
      pkgs.${pkgName}
  ;

  agentBundle = { skillSets, formats }:
    let
      sources = builtins.mapAttrs mkSource skillSets;

      explicitSkills = lib.foldlAttrs
        (
          acc: name: cfg:
            acc
            // mkPrefixedSkills {
              source = name;
              prefix = cfg.prefix or name;
              skills = cfg.skills;
            }
        )
        { }
        skillSets;

      catalog = agentSkillsLib.discoverCatalog sources;
      allowlist = agentSkillsLib.allowlistFor {
        inherit catalog sources;
        enable = [ ];
      };

      enabledTargets = builtins.listToAttrs (
        builtins.map
          (
            name:
            {
              inherit name;
              value = agentSkillsLib.defaultLocalTargets.${name} // {
                enable = true;
              };
            }
          )
          formats
      );

      bundle =
        pkgs':
        agentSkillsLib.mkBundle {
          pkgs = pkgs';
          selection = agentSkillsLib.selectSkills {
            inherit catalog sources allowlist;
            skills = explicitSkills;
          };
        };
    in
    {
      inherit bundle;
      targets = enabledTargets;
    };
}
