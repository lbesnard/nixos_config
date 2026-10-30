# nixos_config

My NixOS + Home Manager setup for the laptop **`loz_dell_nixos`** (user `lbesnard`).
It started as a copy of [ZaneyOS](https://gitlab.com/Zaney/zaneyos) (~v2.3, Feb 2025) and
has since diverged: it no longer tracks upstream, and it is on **NixOS 25.11** (stable) with a
few packages pulled from `nixos-unstable`.

## Daily commands

| Alias | What it does |
|-------|--------------|
| `fr`  | **f**lake **r**ebuild: apply this repo to the machine (`nh os switch ...`) |
| `fu`  | **f**lake **u**pdate: same, but first updates `flake.lock` (newer packages) |
| `ncg` | **c**lean **g**arbage: delete old generations and free disk space |

They are defined in `hosts/loz_dell_nixos/home.nix` (the `.alias.nixos` file) and rely on `nh`.
Typical workflow: edit a file, run `fr`, and if it breaks, reboot and pick the previous generation in the boot menu.

Without the aliases:

```sh
sudo nixos-rebuild switch --flake ~/nixos_config#loz_dell_nixos   # apply
nixos-rebuild build --flake .#loz_dell_nixos                      # test-build only, changes nothing
nix flake update                                                  # bump flake.lock
```

## Crash course: Nix, flakes, Home Manager

- **NixOS**: the whole system (packages, services, users, drivers) is described in `.nix` files.
  You change the files and rebuild; you never `apt install` things by hand.
  Every rebuild creates a **generation**, so you can always roll back.
- **Nix language**: `.nix` files are mostly attribute sets (`{ name = value; }`) and functions
  (`{ pkgs, ... }: { ... }`). A file is usually a *module* that sets options.
  Search for packages at <https://search.nixos.org/packages> and for options at
  <https://search.nixos.org/options>.
- **Flake** (`flake.nix`): the entry point. It lists the **inputs** (where nixpkgs, Home Manager,
  Stylix, agenix come from) and the **outputs** (here, one system called `loz_dell_nixos`).
  `flake.lock` pins the exact version of every input so builds are reproducible. Updating the
  lock (`fu` / `nix flake update`) is how you get newer software.
- **Home Manager**: does the same job as NixOS but for the *user* (`~/.config/...`, shell, git,
  Hyprland, per-user packages). Here it is built into the system rebuild, so one `fr` applies both.
- **Two kinds of files**: *system* settings go in `config.nix` (and `users.nix`), *user* settings go in
  `home.nix`. If an option isn't found, it is probably in the other one.
- **`pkgs-unstable`**: a second package set (nixos-unstable) passed to modules for the few
  packages that need to be newer, e.g. `pkgs-unstable.tailscale`.

## How the flake wires things together

```
flake.nix
 ├─ nixosSystem "loz_dell_nixos"
 │   ├─ agenix, stylix, home-manager modules
 │   ├─ hosts/loz_dell_nixos/config.nix   <- system config (imports the files below)
 │   └─ home-manager user lbesnard -> hosts/loz_dell_nixos/home.nix  <- user config
```

The host name and username are set at the top of `flake.nix` (`host`, `username`) and passed to
every module, so files can use `${host}` and `${username}`.

## Layout

| Path | Purpose |
|------|---------|
| `flake.nix`, `flake.lock` | Inputs, the one system definition, pinned versions |
| `hosts/loz_dell_nixos/` | **The active host.** `config.nix` (system), `home.nix` (user), `users.nix` (user packages/groups), `hardware.nix` (auto-generated disks/CPU), `variables.nix` (git identity, browser, terminal, keyboard layouts) |
| `hosts/loz_dell_nixos/*.nix` | Self-contained feature modules: `tailscale`, `kanata` (Space+Up/Down = PgUp/PgDn), `switch-frame-tap` (see its `.md`), `joplin`, `task-tui`, `zoomus` (currently disabled) |
| `hosts/default/` | Leftover ZaneyOS template; **not used** by the build |
| `modules/` | Reusable system modules: GPU drivers (amd/intel/nvidia/prime), kernel patches, VM guest services, hardware clock. `apple-silicon-support` and `firmware` are for Asahi Macs and are not used by the Dell |
| `config/` | Program configs imported by `home.nix`: `hyprland.nix`, `waybar.nix`, `rofi/`, `swaync.nix`, `wlogout`, `zsh.nix`, `tmux.nix`, `neovim.nix` (+ `lazyvim/`), `keepmenu`, `ssh_clients.nix`, `fastfetch`, `wallpapers/` |
| `scripts/` | Small helper scripts packaged as Nix (wallpaper setter, screenshots, rofi launcher, keybinding viewer, ...). Added to the user's packages in `home.nix` |
| `secrets/` | Encrypted secrets (agenix `.age` files) and who can decrypt them |

## Dotfiles

Most dotfiles are **not** managed by Nix. They live in separate repos cloned at
`~/github_repos/dotfiles` (public) and `~/github_repos/dotfiles_private`, and are symlinked with
[dotbot](https://github.com/anishathalye/dotbot), the same way on every machine.
`config/dotfiles.nix` runs dotbot on each rebuild (a Home Manager *activation script*) and skips the
files NixOS owns itself: `~/.bashrc`, `~/.config/gh`, `~/.aws`.

Rule of thumb: Hyprland, Waybar, rofi, zsh, tmux and neovim are configured here via Nix (`config/`);
other apps (e.g. alacritty) come from the dotfiles repo.

## Secrets (agenix)

Secrets (AWS credentials, Tailscale token) are stored encrypted in `secrets/*.age` and decrypted at
boot with the machine's SSH key. Which keys can read each secret is listed in `secrets/secrets.nix`.

```sh
cd secrets && agenix -e aws_cred.age   # edit a secret
```

## Hyprland

- Main modifier is `SUPER`. Settings and binds are in `config/hyprland.nix`.
- `SUPER+SHIFT+R` toggles keyboard layout (`us,fr,no`, see `variables.nix`).
- Clicking the bindings icon (󱕴) in Waybar shows the full list of keybindings (`list-hypr-bindings`).
- Wallpapers are in `config/wallpapers/` (trimmed from upstream) and set by `swww`.

## Common tasks

- **Add a system package**: `environment.systemPackages` in `hosts/loz_dell_nixos/config.nix`, then `fr`.
- **Add a user package**: `users.nix` or `home.packages` in `home.nix`, then `fr`.
- **Add a new feature file**: create `hosts/loz_dell_nixos/foo.nix`, add `./foo.nix` to `imports` in `config.nix`.
- **Update everything**: `fu`.
- **Something broke after an update**: reboot, choose the previous generation in the boot menu, then `git checkout flake.lock`.
- **Disk full**: `ncg`.

## Updating darktable (pinned on purpose)

darktable is built with AI support (`withAi = true`, `hosts/loz_dell_nixos/users.nix`). That variant is
**not in the binary cache**, so it compiles locally (~1 h). To keep `fu` fast, it comes from its own
flake input, `nixpkgs-darktable` in `flake.nix`, pinned to a fixed nixpkgs **commit hash**. `fu` /
`nix flake update` never changes it. Other unstable packages (digikam, tailscale, ...) use
`nixpkgs-unstable` and update normally.

To upgrade darktable manually:

1. See which version is in nixpkgs-unstable now, and get the latest commit hash:
   ```sh
   git ls-remote https://github.com/NixOS/nixpkgs nixos-unstable      # first column = commit hash
   nix eval --raw github:nixos/nixpkgs/<hash>#darktable.version        # check the darktable version at that commit
   ```
   Pick a commit whose darktable version is the one you want (`nixos-unstable` only moves after its tests
   pass, so its latest commit is a safe choice). The version currently pinned is
   `nix eval --raw github:nixos/nixpkgs/31ecbaca1bdefa45dffc409f0250bd8039ea0010#darktable.version`
   (use the hash currently in `flake.nix`).
2. Put the hash in the URL of `nixpkgs-darktable` in `flake.nix`:
   ```nix
   nixpkgs-darktable.url = "github:nixos/nixpkgs/<new-hash>";
   ```
3. Refresh the lock for that input only, then rebuild (expect ~1 h of compiling once):
   ```sh
   nix flake lock
   fr
   ```
4. If it fails, `git checkout flake.nix flake.lock` goes back to the previous pin (already built, so instant).

Don't want AI? Use `pkgs-unstable.darktable` in `users.nix` (cached, no compile) and delete the
`nixpkgs-darktable` input, the `pkgs-darktable` line in `flake.nix` and the `pkgs-darktable` argument in `users.nix`.

## Relationship to ZaneyOS

Upstream is far ahead (v2.6.x: Noctalia shell, `zcli`, nixvim, multi-profile flake) and the layouts no
longer match, so merging is impractical. Treat it as a reference only: check its `CHANGELOG.md` when
something breaks after an update, and copy individual fixes by hand.
