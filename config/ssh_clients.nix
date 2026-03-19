{ config, pkgs, dotfiles-private-src, ... }:
{
  home.file.".ssh/config" = {
    source = "${dotfiles-private-src}/ssh/config";
    onChange = "chmod 600 ${config.home.homeDirectory}/.ssh/config";
  };
}
