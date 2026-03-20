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
  home.activation.dotfiles = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "${dotfiles}" ]; then
      cd "${dotfiles}"
      ${pkgs.dotbot}/bin/dotbot -c install.conf.yaml
    fi

    # Private dotfiles — no install.conf.yaml, symlink manually
    if [ -d "${dotfiles-private}" ]; then
      ln -sf "${dotfiles-private}/ssh/config" "${home}/.ssh/config"
      chmod 600 "${home}/.ssh/config" 2>/dev/null || true
      ln -sf "${dotfiles-private}/taskrc" "${home}/.taskrc"
    fi
  '';
}
