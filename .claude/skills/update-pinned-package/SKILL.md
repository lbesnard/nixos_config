---
name: update-pinned-package
description: Find and bump any manually-pinned package/dependency in this nixos_config repo — a fetchurl/fetchzip/fetchFromGitHub release pin, a fetchGit/fetchTarball commit pin, or a flake input pinned to a fixed commit — to a newer upstream version or commit, re-fetching the hash and verifying the build. Use whenever asked to update/upgrade/bump a package that isn't plain nixpkgs (i.e. not just the `fu` alias / `nix flake update`).
---

# Update a Pinned Package or Dependency

Most software in this repo comes straight from nixpkgs and is updated in bulk via `fu`/`nix flake
update` (see `README.md`) — this skill is **not** for that. It's for the parts of the repo that
pin a specific upstream version or commit by hand, bypassing nixpkgs' own versioning. There are
more of these than a quick look suggests, and new ones get added over time, so **find the target
by searching, not from a hardcoded filename list.**

## 1. Discover pinned-dependency sites

Grep the whole repo (skip `modules/apple-silicon-support/` — unused on the active host, see
`CLAUDE.md` — and `flake.lock`, which `nix flake update` manages, not this skill):

```sh
grep -rn "fetchurl\|fetchzip\|fetchFromGitHub\|fetchGit\|fetchTarball" --include="*.nix" . \
  | grep -v apple-silicon
```

Also check `flake.nix` directly for any input whose `url` ends in a commit hash rather than a
branch/tag name — that's the flake-input version of the same pattern.

Known sites as of writing (**not exhaustive — re-run the grep above**, this table will go stale):

| File | Fetcher | Pin style |
|---|---|---|
| `hosts/loz_dell_nixos/task-tui.nix` | `fetchurl` | release tag + wheel hash |
| `hosts/loz_dell_nixos/joplin.nix` | `fetchurl` | release tag + AppImage hash |
| `hosts/loz_dell_nixos/switch-frame-tap.nix` | `fetchzip` | release tag + tarball hash (hashes *extracted* contents) |
| `hosts/loz_dell_nixos/config.nix` (scrcpy overlay) | `fetchFromGitHub` + `fetchurl` | release tag + **two** hashes (`src` and `prebuilt_server`) that must move together |
| `config/github_repos.nix` (LingoAnki, Koreader_Highlights_2_Anki) | `fetchGit` | commit `rev`, no version/tag, no hash — "latest commit on a branch" |
| `modules/kernel_patches.nix` (ipu6-drivers) | `fetchGit` | commit `rev` on `master` feeding a kernel patch — higher-risk, touches `boot.kernelPackages` |
| `hosts/loz_dell_nixos/zoomus.nix` | `fetchTarball` | pins an entire nixpkgs commit for one package; **currently disabled/unused** (not imported) — confirm before spending effort |
| `flake.nix` (`nixpkgs-darktable` input) | flake input URL | pinned to a fixed commit *on purpose*, per its comment — same "bump by hand" shape, different file |

## 2. Classify the pin: release-style vs commit-style

- **Release-style** (`version = "x.y.z"` + a tagged download URL): there's a concrete "latest
  release" to check against:
  ```sh
  gh release list --repo <owner>/<repo> --limit 5
  ```
- **Commit-style** (`rev = "<sha>"`, no version field, tracks a branch/ref): "latest" means the
  current tip of the tracked ref:
  ```sh
  git ls-remote <repo-url> <branch>
  # or, for a GitHub repo:
  gh api repos/<owner>/<repo>/commits/<branch> --jq .sha
  ```

## 3. Re-fetch the hash

Pick the prefetch command by fetcher, not by filename:

| Fetcher | Hashes | Command |
|---|---|---|
| `fetchurl` | raw file | `nix-prefetch-url <url>` |
| `fetchzip` / `fetchTarball` | *extracted* contents | `nix-prefetch-url --unpack <url>` |
| `fetchFromGitHub` (tag) | extracted source tree | `nix-prefetch-url --unpack https://github.com/<owner>/<repo>/archive/<tag>.tar.gz` (or let the build fail once and copy the hash it reports — see step 5) |
| `fetchGit` | none — content-addressed by `rev` itself; just update `rev` (and `ref` if the tracked branch name changed) |

Convert a base32 result to SRI with `nix hash to-sri --type sha256 <hash>`.

If a site has two fetchers coupled by the same `version` (scrcpy's `src` + `prebuilt_server` in
`config.nix`), bump both hashes together — don't update one and leave the other stale.

## 4. Edit the file

Update `version`/`rev`/`tag` and hash field(s) together. Watch for `v` prefix mismatches between
the tag string and how it's interpolated into the URL (`v${version}` vs `${version}`).

## 5. Verify it builds

- If the edited expression is a **standalone derivation file** that `callPackage`s cleanly
  (`task-tui.nix`, `joplin.nix`):
  ```sh
  nix-build -E 'with import <nixpkgs> {}; callPackage ./path/to/file.nix {}' --no-out-link
  ```
- If it's embedded in an **overlay or NixOS module** with no standalone file to build directly
  (scrcpy override in `config.nix`, `switch-frame-tap.nix`, `kernel_patches.nix`), verify through
  the full host build instead — safe, doesn't touch the running system:
  ```sh
  nixos-rebuild build --flake ~/nixos_config#loz_dell_nixos
  ```
- For a flake-input commit bump (`nixpkgs-darktable`), update the URL in `flake.nix` then:
  ```sh
  nix flake lock --update-input nixpkgs-darktable
  nixos-rebuild build --flake ~/nixos_config#loz_dell_nixos
  ```
- If the hash you supplied is wrong, the build fails and prints the *correct* hash in the error —
  copy that in directly instead of re-running the prefetch command; it's faster and avoids
  transcription mistakes.

## 6. Report, don't apply

State what moved (old → new version/commit) and that the build was verified with `nix-build` or
`nixos-rebuild build`. Do not run `nixos-rebuild switch` / `fr` / `fu` to actually apply it —
that's the user's call (see `CLAUDE.md`).
