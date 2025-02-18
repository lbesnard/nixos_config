
{ config, pkgs,... }: let
  dotfilesPath = ./dotfiles;
  ghPath = ./gh;

in
{
  xdg.configFile."gh".source = ghPath;

  home.file = {
    ".gitconfig" = { source = "${dotfilesPath}/gitconfig"; };
    ".alias" = { source = "${dotfilesPath}/alias"; };
    ".bashrc-personal" = { source = "${dotfilesPath}/bashrc-personal"; };
    ".aws/config" = { source = "${dotfilesPath}/aws/config";}; 
    };
}
