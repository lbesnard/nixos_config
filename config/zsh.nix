{ config, pkgs, ... }: let
  zshPath = ./zsh;
in
{
home.file = {
    ".zshrc" = { source = "${zshPath}/zshrc"; };
    ".zshrc.common" = { source = "${zshPath}/zshrc.common"; };
    ".zshrc.local" = { source = "${zshPath}/zshrc.local"; };
    ".zsh_functions" = { source = "${zshPath}/zsh_functions"; recursive = true; };
    ".alias_forgit" = { source = "${zshPath}/alias_forgit"; };
    ".zsh_alias" = { source = "${zshPath}/zsh_alias"; recursive = true; };
  };
}
