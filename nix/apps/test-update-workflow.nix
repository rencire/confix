{ pkgs, ... }:
let
  runner = pkgs.writeShellApplication {
    name = "test-update-workflow";
    runtimeInputs = [
      pkgs.act
      pkgs.docker
    ];
    text = ''
      set -euo pipefail

      if ! docker ps >/dev/null 2>&1; then
        echo "docker cannot reach a daemon; if you use Colima, start it with: colima start" >&2
        exit 1
      fi

      exec act workflow_dispatch \
        -P ubuntu-latest=catthehacker/ubuntu:act-latest \
        -W .github/workflows/update-flake-inputs.yml \
        "$@"
    '';
  };
in
{
  type = "app";
  program = "${runner}/bin/test-update-workflow";
}
