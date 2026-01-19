# API Reference

## `lib.configure`

The `lib.configure` function identifies and wraps packages based on the
configuration files present in a specified directory.

### Type

```nix
lib.configure :: { pkgs, configDir, extraArgs ? {} } -> Attrs
```

### Arguments

- `pkgs` (Attribute set): The `nixpkgs` package set to use for wrapping and
  package discovery.
- `configDir` (Path): Path to the directory containing package configuration
  files (e.g., `./config`).
- `extraArgs` (Attribute set; optional): Extra arguments to pass to each
  configuration file.

### How It Works

1. **Discovery**: `confix` scans the `configDir` for all `.nix` files.
2. **Mapping**: Each filename (e.g., `tealdeer.nix`) is mapped to a package in
   `pkgs` (e.g., `pkgs.tealdeer`).
3. **Configuration**: The configuration file is imported and passed `pkgs`,
   `lib`, and any `extraArgs`.
4. **Filtering**: If the configuration returns `enable = false;`, the package is
   excluded from the results.
5. **Wrapping**: Returns an attribute set where the keys are package names and
   values are the wrapped derivations.

---

### Examples

#### Basic Usage

In this example, if `./config` contains `tealdeer.nix`, `lib.configure` will
automatically include and configure `pkgs.tealdeer`.

**flake.nix**

```nix
{
  inputs.confix.url = "github:rencire/confix";
  outputs = { self, nixpkgs, confix }: {
    devShells.aarch64-darwin.default = let
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      configured = confix.lib.configure {
        inherit pkgs;
        configDir = ./config;
      };
    in pkgs.mkShell {
      packages = [
        configured.tealdeer
        configured.git
        pkgs.hello
      ];
    };
  };
}
```

---

## `lib.configureAsList`

A variant of `lib.configure` that returns a list of derivations instead of an
attribute set. This is functionally equivalent to
`builtins.attrValues (lib.configure args)`.

### Type

```nix
lib.configureAsList :: { pkgs, configDir, extraArgs ? {} } -> [Derivation]
```

### Arguments

- `pkgs` (Attribute set): The `nixpkgs` package set.
- `configDir` (Path): Path to the configuration directory.
- `extraArgs` (Attribute set; optional): Extra arguments for configuration
  files.

### Example

**flake.nix**

```nix
{
  inputs.confix.url = "github:rencire/confix";
  outputs = { self, nixpkgs, confix }: {
    devShells.aarch64-darwin.default = let
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      configured = confix.lib.configureAsList {
        inherit pkgs;
        configDir = ./config;
      };
    in pkgs.mkShell {
      packages = configured ++ [ pkgs.hello ];
    };
  };
}
```

---

## `lib.configureInline`

The `lib.configureInline` function allows you to configure a set of packages
within a single attribute set, bypassing the need for separate files in a
directory.

### Type

```nix
lib.configureInline :: { pkgs, packages } -> Attrs
```

### Arguments

- `pkgs` (Attribute set): The `nixpkgs` package set to use for wrapping.
- `packages` (Attribute set): A set of package configurations where the keys are
  the package names (from `pkgs`) and values are the configuration sets.

### Example

**flake.nix**

```nix
{
  inputs.confix.url = "github:rencire/confix";
  outputs = { self, nixpkgs, confix }: {
    devShells.aarch64-darwin.default = let
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      configured = confix.lib.configureInline {
        inherit pkgs;
        packages = {
          tealdeer = {
            settings = {
              updates.auto_update = true;
              display.use_pager = true;
            };
          };
          git = {
            extraArgs = {
              gitEmail = "user@example.com";
            };
          };
        };
      };
    in pkgs.mkShell {
      packages = [
        configured.tealdeer
        configured.git
      ];
    };
  };
}
```

---

## Package Control

### The `enable` flag

To temporarily disable a package without deleting its configuration, you can add
an `enable` flag at the top level of the configuration attribute set.

**Example: `config/tealdeer.nix`**

```nix
{ pkgs, lib }: {
  enable = false; # This package will be skipped by confix
  settings = { ... };
}
```

---
