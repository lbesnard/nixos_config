{ config, pkgs, dotfiles-src, dotfiles-private-src, ... }:
let
  scriptPath = ./scripts;
in
{
  home.file = {
    ".gitconfig".source = "${dotfiles-src}/gitconfig";
    ".alias".source = "${dotfiles-src}/alias";
    # NixOS-local file (not in dotfiles repo)
    ".bashrc-personal".source = ./bashrc-personal;
    ".aws/config".source = "${dotfiles-src}/aws/config";
    ".config/hypr/toggle_keyboard_layout.sh".source = "${scriptPath}/toggle_keyboard_layout.sh";
  };
  # NixOS-local file (not in dotfiles repo)
  xdg.configFile."kwalletrc".source = ./kwalletrc;
  xdg.configFile."alacritty.toml".source = "${dotfiles-src}/config/alacritty/alacritty.toml";
}
