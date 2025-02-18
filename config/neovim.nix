{ config, pkgs, ... }: let
  nvimPath = ./lazyvim;
in
{
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      extraPackages = with pkgs; [
        lua-language-server
        gopls
        xclip
        wl-clipboard
        luajitPackages.lua-lsp
        nil
        rust-analyzer
        #nodePackages.bash-language-server
        yaml-language-server
        pyright
        marksman
      ];
    };
  };
  xdg.configFile."nvim".source = nvimPath;
}
