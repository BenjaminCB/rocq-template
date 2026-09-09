{
  description = "Rocq project template";

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

        /*
        Use one coherent Coq/Rocq package set for the whole project.

        This is important: rocq (the compiler driver), coq-lsp, pet, and your
        Coq/Rocq libraries should all come from the same package set.
        */
        coqPackages = pkgs.coqPackages;

        /*
        rocqEnv is the actual Coq/Rocq environment used by your project.

        It contains:
        - rocq (rocq compile, rocq makefile, rocq top)
        - coq-lsp
        - pet
        - your Coq/Rocq libraries

        This template stays minimal: the Rocq standard library and the language
        server. Add what your development needs to the list below, then re-enter
        the dev shell so the new libraries appear. For example:

          mathcomp
          mathcomp-ssreflect
          mathcomp-algebra
          mathcomp-order
          mathcomp-classical
          mathcomp-reals
          mathcomp-finmap
          mathcomp-analysis

          # Reflexive ring/field/lra/nra tactics for MathComp structures.
          # Provides mathcomp.algebra_tactics.ring and
          # mathcomp.algebra_tactics.lra; mathcomp-zify is its dependency
          # and is listed so the same package set supplies it.
          mathcomp-algebra-tactics
          mathcomp-zify

          coquelicot
          flocq
          interval
          equations
          hierarchy-builder
        */
        rocqEnv = coqPackages.rocq-core.withPackages (ps:
          with ps; [
            stdlib
            coq-lsp
          ]);

        coqLspExtension = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
          mktplcRef = {
            name = "coq-lsp";
            publisher = "ejgallego";
            version = "0.2.4";
            hash = "sha256-s2f2i3sNZ3EdCHDgkYPPiXDp25cViAZy+DpnDxfWaSo=";
          };
        };

        wasmWasiCoreExtension =
          pkgs.vscode-utils.buildVscodeMarketplaceExtension
          {
            mktplcRef = {
              name = "wasm-wasi-core";
              publisher = "ms-vscode";
              version = "1.0.2";
              hash = "sha256-hrzPNPaG8LPNMJq/0uyOS8jfER1Q0CyFlwR42KmTz8g=";
            };
          };

        vscode = pkgs.vscode-with-extensions.override {
          vscode = pkgs.vscode;
          vscodeExtensions = [
            wasmWasiCoreExtension
            coqLspExtension
            pkgs.vscode-extensions.vscodevim.vim
          ];
        };

        settingsJson = builtins.toJSON {
          "coq-lsp.path" = "${rocqEnv}/bin/coq-lsp";
          "coq-lsp.args" = [];
          "coq-lsp.check_only_on_request" = true;
          "coq-lsp.check_on_scroll" = true;
          "coq-lsp.completion.unicode.enabled" = "off";
          "coq-lsp.eager_diagnostics" = true;
          "coq-lsp.goal_after_tactic" = false;
          "coq-lsp.show_coq_info_messages" = false;
          "coq-lsp.show_goals_on" = 3;
          "coq-lsp.trace.server" = "off";
          "files.exclude" = {
            "**/*.vo" = true;
            "**/*.vok" = true;
            "**/*.vos" = true;
            "**/*.glob" = true;
            "**/*.aux" = true;
          };
        };

        /*
        MCP server wrapper.

        This makes sure rocq-mcp sees the same rocq, coq-lsp, pet,
        and Coq libraries as the rest of the dev shell. .mcp.json and
        .codex/config.toml refer to this command by name, so any agent
        started from the dev shell picks it up without further setup.
        */
        rocqMcp = pkgs.writeShellApplication {
          name = "rocq-mcp";

          runtimeInputs = [
            pkgs.uv
            pkgs.git
            pkgs.dune_3
            rocqEnv
          ];

          text = ''
            export ROCQ_WORKSPACE="''${ROCQ_WORKSPACE:-$PWD}"

            exec uvx \
              --from git+https://github.com/LLM4Rocq/rocq-mcp \
              rocq-mcp "$@"
          '';
        };
      in {
        packages.default = pkgs.hello;

        devShells.default = pkgs.mkShell {
          packages = [
            vscode

            rocqEnv
            rocqMcp

            pkgs.just
            pkgs.uv
            pkgs.git
            pkgs.dune_3
            pkgs.ripgrep
            pkgs.jq
            pkgs.nodejs_22
          ];

          shellHook = ''
                        mkdir -p .vscode

                        cat > .vscode/settings.json <<'JSON'
            ${settingsJson}
            JSON

                        echo "Wrote .vscode/settings.json"
                        echo "Welcome to rocq dev shell"

                        echo "rocq:      $(command -v rocq || true)"
                        echo "coq-lsp:   $(command -v coq-lsp || true)"
                        echo "pet:       $(command -v pet || true)"
                        echo "rocq-mcp:  $(command -v rocq-mcp || true)"
                        echo "just:      $(command -v just || true)"
          '';
        };
      }
    );
}
