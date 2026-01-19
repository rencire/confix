# confix

Configure nixpkgs packages without relying on `$HOME/.config` files or
`home-manager`. Specify custom settings for any package in simple `.nix` files
local to your flake.

## Quick Start

We'll use an example with [tealdeer](https://github.com/tealdeer-rs/tealdeer), a
community-driven man page replacement. Add confix to your flake inputs and
create a `config/` directory in your flake root like so:

```
<project>/
  flake.nix
  config/
    tealdeer.nix
```

### 1. Add flake.nix

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
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      configured = confix.lib.configure {
        inherit pkgs;
        configDir = ./config;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          configured.tealdeer
          pkgs.hello
        ];
      };
    };
}
```

### 2. Add configuration file

`confix` automatically maps files in your `configDir` to packages in `pkgs`
based on their filename. To configure `pkgs.tealdeer`, create a file named
`tealdeer.nix` in your configuration directory.

Each package config file is a simple attribute set passed to the package's
wrapper. Configuration files receive standard NixOS module arguments (`pkgs`,
`lib`) that you can destructure. Example `config/tealdeer.nix`:

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

The exact configuration depend on what
[`nix-wrapper-modules`](https://github.com/BirdeeHub/nix-wrapper-modules)
supports for each package.

### 3. Build

Build your shell:

```shell
nix develop
```

Now you have all your programs available with their settings organized in `nix`
files, and not in home folder!

## API

Full documentation is available in
[API.md](file:///Users/ren/projects/oss/confix/API.md).

# TODO

- [] Enable use case for consumers using flakelight and flake-parts
- [] Enable use case for nixos/darwin-nix modules
