# CLAUDE.md

Agent-specific notes for this repo. `README.md` already covers the architecture, layout, and a
Nix/flakes/Home Manager crash course — read that first. This file only adds what an agent
specifically needs to know and doesn't repeat it.

## Safety: this repo controls a live machine

- `sudo nixos-rebuild switch --flake ~/nixos_config#loz_dell_nixos` (alias `fr`) and
  `nix flake update` (alias `fu`, which also rebuilds) apply changes to the **running system**.
  Confirm with the user before running either, or anything else that switches generations or
  reboots.
- `nixos-rebuild build --flake .#loz_dell_nixos` only builds, changes nothing on disk that
  matters, and is safe to run freely to verify a change compiles.
- `nh clean` / the `ncg` alias deletes old generations — destructive, confirm first.

## Only one host is live

The flake (`flake.nix`) builds exactly one system: `loz_dell_nixos`. Two trees look like config
but are not wired into any build and should not be "fixed" expecting it to affect the running
machine:
- `hosts/default/` — leftover ZaneyOS template.
- `modules/apple-silicon-support/`, `modules/firmware/` — for Asahi Macs, not this Dell.

## Updating pinned packages

Most software here is plain nixpkgs, updated in bulk via `fu`. But the repo also has quite a few
hand-pinned dependencies scattered across it — `fetchurl`/`fetchzip` release pins (`task-tui.nix`,
`joplin.nix`, `switch-frame-tap.nix`, the scrcpy overlay in `config.nix`), `fetchGit` commit pins
(`config/github_repos.nix`, `modules/kernel_patches.nix`), and a flake input pinned to a fixed
commit on purpose (`nixpkgs-darktable` in `flake.nix`). To bump any of these, use the
`update-pinned-package` skill — it discovers pin sites by grepping for the fetcher functions
rather than assuming this list is complete, since new ones get added over time.
