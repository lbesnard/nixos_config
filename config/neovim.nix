{ config, pkgs, ... }:
{
  # ~/.config/nvim is managed by dotbot (symlinked from ~/github_repo/dotfiles/nvim/,
  # which bootstraps LazyVim). Home Manager's `programs.neovim` module writes its own
  # generated init.lua through that symlink regardless of config, clobbering the real
  # file in the dotfiles repo -- so neovim is installed as a plain package here instead
  # and left entirely unmanaged/unconfigured by Home Manager.
  home.packages = with pkgs; [
    neovim

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
}
