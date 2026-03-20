{ config, pkgs, dotfiles-src, ... }:
{
  home.file = {
    # Core zshrc files
    ".zshrc".source                       = "${dotfiles-src}/zsh/zshrc";
    ".zshrc.common".source                = "${dotfiles-src}/zsh/zshrc.common";
    ".zshrc.laptop".source                = "${dotfiles-src}/zsh/zshrc.laptop";
    ".zshrc.server".source                = "${dotfiles-src}/zsh/zshrc.server";
    ".zshrc.homeserver".source            = "${dotfiles-src}/zsh/zshrc.homeserver";
    # Legacy symlinks (backward compat)
    ".zshrc.local".source                 = "${dotfiles-src}/zsh/zshrc.laptop";
    ".zshrc.bfunk".source                 = "${dotfiles-src}/zsh/zshrc.homeserver";
    ".zshrc.ssh".source                   = "${dotfiles-src}/zsh/zshrc.server";

    # Aliases and functions
    ".alias_forgit".source                = "${dotfiles-src}/alias_forgit";
    ".zsh_functions" = {
      source    = "${dotfiles-src}/zsh/functions";
      recursive = true;
    };
    ".zsh_alias" = {
      source    = "${dotfiles-src}/zsh_alias";
      recursive = true;
    };
    ".zsh_complete" = {
      source    = "${dotfiles-src}/zsh/completions";
      recursive = true;
    };
    ".zplug/complete/beet/_beet".source   = "${dotfiles-src}/zsh/_beet";
  };
}
