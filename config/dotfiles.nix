{ config, pkgs, ... }:
let
  home = config.home.homeDirectory;
  dotfiles = "${home}/github_repos/dotfiles";
  dotfiles-private = "${home}/github_repos/dotfiles_private";
  scriptPath = ./scripts;
in
{
  # NixOS-local files not in the dotfiles repo
  home.file.".config/hypr/toggle_keyboard_layout.sh".source = "${scriptPath}/toggle_keyboard_layout.sh";
  xdg.configFile."kwalletrc".source = ./kwalletrc;

  # Remove conflicting files before home-manager's checkLinkTargets phase.
  # Only remove files that home-manager needs to own on NixOS.
  # WARNING: do NOT rm files inside dotbot-managed directory symlinks
  # (e.g. ~/.config/alacritty/ → dotfiles repo) as it deletes from the repo.
  home.activation.removeConflicts = config.lib.dag.entryBefore [ "checkLinkTargets" ] ''
    # ~/.bashrc: dotbot symlinks it; programs.bash needs to own it on NixOS
    if [ -L "$HOME/.bashrc" ]; then
      rm -f "$HOME/.bashrc"
    fi
    # ~/.config/gh: dotbot manages this dir, but programs.gh owns it on NixOS
    rm -f "$HOME/.config/gh/config.yml"
    rm -f "$HOME/.config/gh/config.yml.backup"
  '';

  # Run dotbot to symlink all public dotfiles (same as on any other machine)
  # Exclude ~/.bashrc — managed by programs.bash (has NixOS-specific aliases like fr/fu)
  home.activation.dotfiles = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "${dotfiles}" ]; then
      cd "${dotfiles}"
      # Write filtered config into dotfiles dir so dotbot uses it as base directory
      # (dotbot resolves relative paths from the config file's directory)
      grep -v '\.bashrc\|\.config/gh' install.conf.yaml > "${dotfiles}/.nixos-install.yaml"
      # Use || true: shell commands in install.conf.yaml may fail in systemd context
      # (e.g. chown $USER when $USER is unset, chmod on non-existent ~/.zplug)
      # but the symlinks themselves are created correctly before those run
      ${pkgs.dotbot}/bin/dotbot -c "${dotfiles}/.nixos-install.yaml" || true
      rm -f "${dotfiles}/.nixos-install.yaml"
    fi

    # Private dotfiles — no install.conf.yaml, symlink manually
    if [ -d "${dotfiles-private}" ]; then
      ln -sf "${dotfiles-private}/ssh/config" "${home}/.ssh/config"
      chmod 600 "${home}/.ssh/config" 2>/dev/null || true
      ln -sf "${dotfiles-private}/taskrc" "${home}/.taskrc"
    fi
  '';
}
