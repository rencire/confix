{ pkgs, outputs, ... }:
let
  inherit (pkgs) lib;
  inp = pkgs.inputs;
  system = pkgs.stdenv.hostPlatform.system;

  agentSkillsLib = inp."agent-skills".lib."agent-skills";
  agentSkillsConfig = import ./config/agent-skills-config.nix;
  agentBundle = outputs.lib.agentBundle {
    inherit (agentSkillsConfig) skillSets formats;
  };

  pkgs' = (pkgs.extend inp."llm-agents".overlays.shared-nixpkgs).extend (
    _: prev: {
      entire = inp."entire-cli-flake".packages.${system}.default;
    }
  );

  configured = outputs.lib.configure {
    pkgs = pkgs';
    configDir = ./confix;
  };
in
{
  packages = [
    pkgs'.bun
    pkgs'.git
    pkgs'.entire
    configured.opencode
    pkgs.act
    pkgs.actionlint
    pkgs.docker
    pkgs.gh
    pkgs.lefthook
  ];
  env.GSTACK_HOME = ".gstack";
  shellHook = agentSkillsLib.mkShellHook {
    pkgs = pkgs';
    bundle = agentBundle.bundle pkgs';
    targets = agentBundle.targets;
  };
}
