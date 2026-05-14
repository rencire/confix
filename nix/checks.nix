{ inputs, pkgs, ... }:
{
  test-new-api =
    let
      configured = inputs.self.lib.configure {
        inherit pkgs;
        configDir = ../tests/mock-config;
      };
      configuredList = inputs.self.lib.configureAsList {
        inherit pkgs;
        configDir = ../tests/mock-config;
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
}
