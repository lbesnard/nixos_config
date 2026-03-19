{ config, pkgs, dotfiles-src, ... }:
{
  home.file = {
    ".zshrc".source = "${dotfiles-src}/zsh/zshrc";
    ".zshrc.common".source = "${dotfiles-src}/zsh/zshrc.common";
    ".zshrc.local".source = "${dotfiles-src}/zsh/zshrc.laptop";
    ".zsh_functions" = {
      source = "${dotfiles-src}/zsh/functions";
      recursive = true;
    };
    ".alias_forgit".source = "${dotfiles-src}/alias_forgit";
    ".zsh_alias" = {
      source = "${dotfiles-src}/zsh_alias";
      recursive = true;
    };
  };
}
