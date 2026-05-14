{
  description = "Configure configuration for packages";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flakelight = {
      url = "github:nix-community/flakelight";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    entire-cli-flake = {
      url = "github:rencire/entire-cli-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flakelight.follows = "flakelight";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rencire-skills = {
      url = "github:rencire/agent-skills";
      flake = false;
    };
    gstack = {
      url = "github:garrytan/gstack";
      flake = false;
    };
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

      }
    );
}
