# Rocq project template

A Nix dev shell for a Rocq development, wired for both interactive proof work in
VS Code and for coding agents (Claude Code, Codex) through MCP.

## Getting started

```sh
direnv allow      # or: nix develop
just build
```

`just --list` shows every recipe. `just build` regenerates `CoqMakeFile` from
`_CoqProject` and compiles, so a newly added file is picked up without a manual
step.

## Important

The development shell uses the `coq-lsp` VS Code extension and language server.
It reads `_CoqProject` for the project load path and checks documents
incrementally.

The current version of the tooling does not load `_RocqProject`, so the project
manifest keeps the old Coq names (`_CoqProject`, `CoqMakeFile`).

The Nix shell regenerates `.vscode/settings.json` on every entry. Make
persistent editor configuration changes in `settingsJson` in `flake.nix`, not in
the generated file.

## What is included

- A VS Code installation with `coq-lsp` configured for lazy incremental
  checking. Move the cursor to a proof sentence to display its goal state.
- A `justfile` with `generate`, `build`, `clean`, and `rebuild`.
- A `rocq-mcp` wrapper on `PATH` that runs the
  [rocq-mcp](https://github.com/LLM4Rocq/rocq-mcp) server against the same
  `coqc`, `coq-lsp`, `pet`, and libraries as the rest of the shell.
- MCP configuration for both agents, so no per-user setup is needed:
  `.mcp.json` for Claude Code (with `.claude/settings.json` enabling the servers
  and raising the MCP timeouts) and `.codex/config.toml` for Codex. Both declare
  the `rocq` server and a `local-rag` server that indexes `docs/`.
- `AGENTS.md` with the working rules agents should follow in this repository.
- A small example showing how a simple multi file setup with dependencies can be
  made.

The shell deliberately does **not** install Claude Code or Codex; bring your own
installation. It also ships a minimal library set (Rocq stdlib and `coq-lsp`).
Add MathComp, Equations, Hierarchy Builder, and friends to `rocqEnv` in
`flake.nix` — the list of the usual suspects is in a comment right above it —
then re-enter the dev shell.
