{ config, pkgs, dotfiles-private-src, ... }:
{
  home.file.".ssh/config" = {
    source = "${dotfiles-private-src}/ssh/config";
  };
}
