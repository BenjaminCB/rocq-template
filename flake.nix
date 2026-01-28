{
  description = "Flake utils demo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        vscode = pkgs.vscode-with-extensions.override {
          vscode = pkgs.vscode;
          vscodeExtensions = with pkgs.vscode-extensions; [
            rocq-prover.vsrocq
            vscodevim.vim
          ];
        };
        settingsJson = builtins.toJSON {
          "vsrocq.path" = "${pkgs.rocqPackages.vsrocq-language-server}/bin/vsrocqtop";
          "vsrocq.completion.enable" = true;
          "vsrocq.diagnostics.full" = true;
        };
      in {
        packages = {
          default = pkgs.hello;
        };
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            vscode
            rocqPackages.vsrocq-language-server
            rocq-core
            rocqPackages.stdlib
            jq
          ];

          shellHook = ''
            export VSROCQTOP_PATH="$(which vsrocqtop)"

            mkdir -p .vscode
            cat > .vscode/settings.json <<'JSON'
            ${settingsJson}
            JSON
            echo "Wrote .vscode/settings.json"

            echo Welcome to rocq dev shell
          '';
        };
      }
    );
}
