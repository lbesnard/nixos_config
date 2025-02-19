{ config, pkgs, ... }:
let
  tmuxPath = ./tmux;
in
{
  home.file = {
    ".tmux.conf" = {
      source = "${tmuxPath}/tmux.conf";
    };
    ".tmux.conf.laptop" = {
      source = "${tmuxPath}/tmux.conf.laptop";
    };
  };
}
