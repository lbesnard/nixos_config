{ config, pkgs, ... }:
let
  nvimPath = ./lazyvim;
in
{
  programs = {
    neovim = {
      enable = true;
      withPython3 = true;
      withNodeJs = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      extraPackages = with pkgs; [
        gcc
        gnumake
        ruby
        cargo

        tree-sitter

        #nix
        deadnix
        nil
        nixd
        statix
        alejandra

        #lua
        luajitPackages.luarocks
        luajitPackages.luacheck
        luajitPackages.lua-lsp
        lua-language-server

        typos-lsp

        gopls
        xclip
        wl-clipboard
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
