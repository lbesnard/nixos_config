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

  # Run dotbot to symlink all public dotfiles (same as on any other machine)
  # Exclude ~/.bashrc — managed by programs.bash (has NixOS-specific aliases like fr/fu)
  home.activation.dotfiles = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "${dotfiles}" ]; then
      cd "${dotfiles}"
      # Filter out ~/.bashrc from dotbot to avoid conflicting with home-manager's programs.bash
      grep -v '\.bashrc' install.conf.yaml > /tmp/nixos-dotbot.yaml
      ${pkgs.dotbot}/bin/dotbot -c /tmp/nixos-dotbot.yaml -d "${dotfiles}"
      rm -f /tmp/nixos-dotbot.yaml
    fi

    # Private dotfiles — no install.conf.yaml, symlink manually
    if [ -d "${dotfiles-private}" ]; then
      ln -sf "${dotfiles-private}/ssh/config" "${home}/.ssh/config"
      chmod 600 "${home}/.ssh/config" 2>/dev/null || true
      ln -sf "${dotfiles-private}/taskrc" "${home}/.taskrc"
    fi
  '';
}
