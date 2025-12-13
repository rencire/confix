# confix
Configure nixpkgs packages without relying on `.config` files or `home-manager`. Specify custom settings for any package in simple `.nix` files local to your flake.
## Quick Start
We'll use an example with [tealdeer](https://github.com/tealdeer-rs/tealdeer), a community-driven man page replacement. Add confix to your flake inputs and create a `config/` directory in your flake root like so:
```
<project>/
  flake.nix
  config/
    tealdeer.nix
```
### 1. Add flake.nix
#### Option A: Vanilla
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    confix = {
      url = "github:rencire/confix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, confix }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = confix.lib.configure {
          inherit pkgs;
          configDir = ./config;
          packages = with pkgs; [ tealdeer ];
        };
      };
    };
}
```
#### Option B: Flakelight
TODO
#### Option C: flake-parts
TODO

### 2. Add configuration file
Each package config file is a simple attribute set passed to the package's wrapper. Configuration files receive standard NixOS module arguments (`pkgs`, `lib`) that you can destructure. Example `config/tealdeer.nix`, translated from [original
toml example](https://tealdeer-rs.github.io/tealdeer/config.html) :
```nix
{ pkgs, lib }:
{
  settings = {
    display = {
      compact = false;
      use_pager = true;
      show_title = false;
    };
    style = {
      command_name = {
        foreground = "red";
      };
      example_text = {
        foreground = "green";
      };
      example_code = {
        foreground = "blue";
      };
      example_variable = {
        foreground = "blue";
        underline = true;
      };
    };
    updates = {
      auto_update = true;
    };
  };
}
```
Config files are optional—if a package has no config file, it will be used as-is. The exact configuration depend on what [`nix-wrapper-modules`](https://github.com/BirdeeHub/nix-wrapper-modules) supports for each package.
### 3. Build
Build your shell:
```shell
nix develop
```

Now you have all your programs available with their settings organized in `nix` files, and not in home folder!

## API
### `configure`
```nix
confix.lib.configure {
  pkgs,       # nixpkgs
  configDir,  # path to config directory (e.g. ./config)
  packages,   # list of package objects (e.g. with pkgs; [ ov hello ])
  extraArgs,  # extra arguments to pass to config files (optional)
}
```
Returns a list of wrapped packages ready to use in `mkShell`.

All config files automatically receive `pkgs` and `lib` as arguments. Additional arguments can be passed via `extraArgs`.
## How It Works
1. For each package, confix extracts its name (`pname` or `name`)
2. Looks for a config file at `configDir/<name>.nix`
3. If found, imports the file with standard NixOS module arguments (`pkgs`, `lib`) and any `extraConfigArgs`
4. Merges the config with package arguments
5. Passes the merged config to `nix-wrapper-modules` for wrapping

This allows per-package customization without modifying nixpkgs or using overlays.


# TODO
- [] Enable use case for consumers using flakelight and flake-parts
- [] Enable use case for nixos/darwin-nix modules
