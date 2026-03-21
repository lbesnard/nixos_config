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
    # ~/.aws: agenix manages credentials; remove dotbot symlink so agenix file is used
    if [ -L "$HOME/.aws" ]; then
      rm -f "$HOME/.aws"
    fi
  '';

  # Run dotbot to symlink all public dotfiles (same as on any other machine)
  # Exclude ~/.bashrc — managed by programs.bash (has NixOS-specific aliases like fr/fu)
  home.activation.dotfiles = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "${dotfiles}" ]; then
      cd "${dotfiles}"
      # Exclude entries managed by NixOS on this machine:
      # - ~/.bashrc: managed by programs.bash (NixOS fr/fu aliases)
      # - ~/.config/gh: managed by programs.gh
      # - ~/.aws: managed by agenix (secrets) — dotbot must not overwrite credentials
      # NOTE: pattern uses $ anchor so ~/.config/gh: doesn't match ~/.config/ghostty
      grep -vE '\.bashrc|\.config/gh:|\.aws:' install.conf.yaml > "${dotfiles}/.nixos-install.yaml"
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
      # ~/.aws: must be a real dir so agenix can write credentials there safely
      # (if dotbot made it a symlink into the repo, credentials end up in git!)
      mkdir -p "${home}/.aws"
      ln -sf "${dotfiles-private}/aws/config" "${home}/.aws/config" 2>/dev/null || true
    fi
  '';
}
