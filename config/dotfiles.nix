{ config, pkgs, dotfiles-src, dotfiles-private-src, ... }:
let
  scriptPath = ./scripts;
in
{
  home.file = {
    # Shell
    ".alias".source            = "${dotfiles-src}/alias";
    # .bashrc managed by programs.bash (home-manager); use .bashrc-personal for customizations
    ".bashrc-personal".source  = ./bashrc-personal;    # NixOS-local
    ".complete".source         = "${dotfiles-src}/complete";
    ".env".source              = "${dotfiles-src}/env";
    ".env_private".source      = "${dotfiles-src}/env_private";
    ".xsessionrc".source       = "${dotfiles-src}/xsessionrc";

    # Git — .gitconfig managed by programs.git in home.nix
    ".gitignore".source        = "${dotfiles-src}/gitignore";

    # Dev tools
    ".ansible.cfg".source      = "${dotfiles-src}/ansible.cfg";
    ".flake8".source           = "${dotfiles-src}/flake8";
    ".psqlrc".source           = "${dotfiles-src}/psqlrc";
    ".myclirc".source          = "${dotfiles-src}/myclirc";
    ".pgpass".source           = "${dotfiles-src}/pgadmin/pgpass";
    ".initsys.sh".source       = "${dotfiles-src}/initsys.sh";

    # Misc tools
    ".gpligrc".source          = "${dotfiles-src}/gpligrc";
    ".ogierc".source           = "${dotfiles-src}/ogierc";
    ".lynx.cfg".source         = "${dotfiles-src}/lynx.cfg";
    ".screenrc".source         = "${dotfiles-src}/screenrc";
    ".whatlastgenre" = {
      source    = "${dotfiles-src}/whatlastgenre";
      recursive = true;
    };
    ".irssi" = {
      source    = "${dotfiles-src}/irssi";
      recursive = true;
    };
    ".snes9x" = {
      source    = "${dotfiles-src}/snes9x";
      recursive = true;
    };
    ".screenlayout" = {
      source    = "${dotfiles-src}/screenlayout";
      recursive = true;
    };
    ".cheat" = {
      source    = "${dotfiles-src}/cheat";
      recursive = true;
    };

    # Vim
    ".vimrc".source = "${dotfiles-src}/vim/vimrc";

    # AWS
    ".aws/config".source = "${dotfiles-src}/aws/config";

    # Scripts on PATH
    "bin" = {
      source    = "${dotfiles-src}/bin";
      recursive = true;
    };

    # cmus
    ".cmus/cmus-tmux-statusbar.sh".source = "${dotfiles-src}/cmus/cmus-tmux-statusbar.sh";
    ".cmus/cmus_add_similar.py".source    = "${dotfiles-src}/cmus/cmus_add_similar.py";

    # Hyprland helper (NixOS-local script)
    ".config/hypr/toggle_keyboard_layout.sh".source = "${scriptPath}/toggle_keyboard_layout.sh";

    # SSH pub keys (from private repo; config itself is in ssh_clients.nix)
    ".ssh/id_rsa.pub".source     = "${dotfiles-src}/ssh/id_rsa.pub";
    ".ssh/id_rsa.pub.pem".source = "${dotfiles-src}/ssh/id_rsa.pub.pem";
    ".ssh/rc".source             = "${dotfiles-src}/ssh/rc";

    # taskrc from private repo
    ".taskrc".source = "${dotfiles-private-src}/taskrc";
  };

  # XDG config files
  xdg.configFile = {
    "kwalletrc".source              = ./kwalletrc;    # NixOS-local
    "alacritty.toml".source         = "${dotfiles-src}/config/alacritty/alacritty.toml";
    "beets".source                  = "${dotfiles-src}/config/beets";
    "cheat/conf.yml".source         = "${dotfiles-src}/cheat.yml";
    "cmus/autosave".source          = "${dotfiles-src}/cmus/autosave";
    "gh".source                     = "${dotfiles-src}/config/gh";
    "joplin-desktop".source         = "${dotfiles-src}/config/joplin-desktop";
    "Nextcloud".source              = "${dotfiles-src}/config/Nextcloud";
    "passhole.ini".source           = "${dotfiles-src}/config/passhole.ini";
    "pgcli".source                  = "${dotfiles-src}/config/pgcli";
    "ranger".source                 = "${dotfiles-src}/config/ranger";
    # redlist: use private repo version if it exists, fallback to public
    "redlist".source                = "${dotfiles-private-src}/config/redlist";
  };
}
