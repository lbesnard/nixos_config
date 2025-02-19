{ config, pkgs, ... }:
let
  keepmenuPath = ./keepmenu/config.ini;
in
{
  xdg.configFile."keepmenu/config.ini".source = keepmenuPath;
}
