{ config, pkgs, dotfiles-src, ... }:
{
  home.file = {
    ".tmux.conf".source            = "${dotfiles-src}/tmux/tmux.conf";
    ".tmux.conf.laptop".source     = "${dotfiles-src}/tmux/tmux.conf.laptop";
    ".tmux.conf.ssh".source        = "${dotfiles-src}/tmux/tmux.conf.ssh";
    ".tmux.conf.ssh_laptop".source = "${dotfiles-src}/tmux/tmux.conf.ssh_laptop";
  };
}
