{
  pkgs,
  username,
  host,
  ...
}:
let
  inherit (import ./variables.nix) gitUsername gitEmail;
in
{
  # Home Manager Settings
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "23.11";

  # Import Program Configurations
  imports = [
    # ../../config/github_repos.nix
    ../../config/ssh_clients.nix
    ../../config/keepmenu.nix
    ../../config/emoji.nix
    ../../config/dotfiles.nix
    ../../config/fastfetch
    ../../config/hyprland.nix
    ../../config/neovim.nix
    ../../config/zsh.nix
    ../../config/tmux.nix
    ../../config/rofi/rofi.nix
    ../../config/rofi/config-emoji.nix
    ../../config/rofi/config-long.nix
    ../../config/swaync.nix
    ../../config/waybar.nix
    ../../config/wlogout.nix
    ../../config/fastfetch
  ];

  # Place Files Inside Home Directory
  home.file."Pictures/Wallpapers" = {
    source = ../../config/wallpapers;
    recursive = true;
  };
  home.file.".config/wlogout/icons" = {
    source = ../../config/wlogout;
    recursive = true;
  };
  home.file.".face.icon".source = ../../config/face.jpg;
  home.file.".config/face.jpg".source = ../../config/face.jpg;
  home.file.".config/swappy/config".text = ''
    [Default]
    save_dir=/home/${username}/Pictures/Screenshots
    save_filename_format=swappy-%Y%m%d-%H%M%S.png
    show_panel=false
    line_size=5
    text_size=20
    text_font=Ubuntu
    paint_mode=brush
    early_exit=true
    fill_shape=false
  '';

  # Create XDG Dirs
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  # Styling Options
  stylix.targets.waybar.enable = false;
  stylix.targets.rofi.enable = false;
  stylix.targets.hyprland.enable = false;
  gtk = {
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  qt = {
    enable = true;
    style.name = "adwaita-dark";
    platformTheme.name = "gtk3";
  };

  # Scripts
  home.packages = [
    (import ../../scripts/emopicker9000.nix { inherit pkgs; })
    (import ../../scripts/task-waybar.nix { inherit pkgs; })
    (import ../../scripts/squirtle.nix { inherit pkgs; })
    (import ../../scripts/nvidia-offload.nix { inherit pkgs; })
    (import ../../scripts/wallsetter.nix {
      inherit pkgs;
      inherit username;
    })
    (import ../../scripts/web-search.nix { inherit pkgs; })
    (import ../../scripts/rofi-launcher.nix { inherit pkgs; })
    (import ../../scripts/screenshootin.nix { inherit pkgs; })
    (import ../../scripts/list-hypr-bindings.nix {
      inherit pkgs;
      inherit host;
    })
  ];

  services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
        };
        listener = [
          {
            timeout = 900;
            on-timeout = "hyprlock";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };

  programs.awscli = {
    enable = true;
    # credentials =  {
    #   "default" = {
    #     # "aws_access_key_id" = config.age.secrets.aws_cred.path;  # not working...
    #     "aws_access_key_id" = "this is a test";  # working
    #   };
    # };
  };

  # Install & Configure Git
  programs.git = {
    enable = true;
    userName = "${gitUsername}";
    userEmail = "${gitEmail}";
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "ssh";
      github.com = {
        git_protocol = "ssh";
        users."${gitUsername}" = { };
        user = "${gitUsername}";
      };
      editor = "";
      prompt = "enabled";
      pager = "bat --style plain";
      aliases = {
        co = ''!id="$(gh pr list -L100 | fzf --no-preview --reverse | cut -f1)"; [ -n "$id" ] && gh pr checkout "$id"'';
        _issue_user_repo_view = ''
          !(
                  tmp_getops=`getopt -o a:r:m:c,s: --long assignee:,repo:,milestone:,comment,state: -- "$@"`
                  eval set -- "$tmp_getops"

                  while true ; do
                      case "$1" in
                          -a|--assignee) user="-a $2"; shift 2;;
                          -r|--repo) repo="$2"; shift 2;;
                          -m|--milestone) milestone="$2"; shift 2;;
                          -c|--comment) comment=true; shift 1;;
                          -s|--state) state="-s $2"; shift 2;;
                          --) shift; break;;
                          *) ;;
                      esac
                  done

                  [ -z "$comment" ] && command=view || command=comment

                  [ ! -z "$milestone" ] && (echo "$milestone" | grep -q -i top) && milestone="Top of PO Backlog"

                  if [ -z "$milestone" ]
                  then
                      id="$(gh issue list -L100 $state $user -R $repo | fzf --preview '(gh issue -R '$repo' view $(echo {} | awk '{print $1;}') | mdcat)' --reverse --multi=1 | cut -f1)"
                  else
                      re_number="^[0-9]+$"
                      echo "$milestone" | grep -q -E "$re_number"  && \
                          id="$(gh issue list -L100 $user -R $repo $state --search "milestone:\"Iteration $milestone\"" | fzf --preview '(gh issue -R '$repo' view $(echo {} | awk '{print $1;}') | mdcat)' --reverse --multi=1 | cut -f1)" || \
                          id="$(gh issue list -L100 $user -R $repo $state --search "milestone:\"$milestone\"" | fzf --preview '(gh issue -R '$repo' view $(echo {} | awk '{print $1;}') | mdcat)' --reverse --multi=1 | cut -f1)"
                  fi

                  [ -n "$id" ] && gh issue -R $repo $command "$id"
                )'';
        issues = ''
          !(
                  case $1 in
                    content|issues|backlog|po-backlog|data-services|python-aodntools|python-aodncore|python-aodndata)
                      organisation=aodn
                      repo="$organisation/$1";

                      tmp_getops=`getopt -o c,a,m: --long comment,all,milestone:,closed -- "$@"`
                      eval set -- "$tmp_getops"

                      while true ; do
                          case "$1" in
                              -c|--comment) comment="$1"; shift 1;;
                              -a|--all) all_users=True; shift 1;;
                              -m|--milestone) milestone="-m $2"; shift 2;;
                              --closed) state="-s closed"; shift 1;;
                              --) shift; break;;
                              *) ;;
                          esac
                      done

                      if [ -z "$all_users" ]
                      then
                          user="$GIT_USER"
                          gh _issue_user_repo_view -a $user -r $repo $comment $milestone $state
                      else
                          gh _issue_user_repo_view -r $repo $comment $milestone $state
                      fi
                      ;;

                    *)
                      echo "The following commands are supported from 'gh issues':"
                      echo "\tcontent, po-backlog, data-services... \t list all issues for user from content repo"
                      echo "\t-m [223, Iteration 223, top] \t list all issues for specific milestone"
                      echo "\t-a --all \t list all issues for all users"
                      echo "\t--closed \t list closed issues"
                      ;;
                  esac
                )'';
      };
    };
  };

  programs = {
    gh-dash = {
      enable = true;
    };
    ghostty.enable = true;
    btop = {
      enable = true;
      settings = {
        vim_keys = true;
      };
    };
    kitty = {
      enable = true;
      package = pkgs.kitty;
      settings = {
        font_size = 10;
        scrollback_lines = 6000;
        wheel_scroll_min_lines = 1;
        window_padding_width = 4;
        confirm_os_window_close = 0;
      };
      extraConfig = ''
        tab_bar_style fade
        tab_fade 1
        active_tab_font_style   bold
        inactive_tab_font_style bold
      '';
    };
    starship = {
      enable = true;
      package = pkgs.starship;
    };
    bash = {
      enable = true;
      enableCompletion = true;
      profileExtra = ''
        #if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        #  exec Hyprland
        #fi
      '';
      initExtra = ''
        # fastfetch
        if [ -f $HOME/.bashrc-personal ]; then
          source $HOME/.bashrc-personal
        fi
      '';
      shellAliases = {
        sv = "sudo nvim";
        fr = "nh os switch --hostname ${host} /home/${username}/nixos_config";
        fu = "nh os switch --hostname ${host} --update /home/${username}/nixos_config";
        zu = "sh <(curl -L https://gitlab.com/Zaney/zaneyos/-/raw/main/install-zaneyos.sh)";
        ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
        v = "nvim";
        cat = "bat";
        # ls = "eza --icons";
        # ll = "eza -lh --icons --grid --group-directories-first";
        # la = "eza -lah --icons --grid --group-directories-first";
        ".." = "cd ..";
      };
    };
    home-manager.enable = true;
    hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 1;
          hide_cursor = true;
          no_fade_in = false;
        };
        lib.mkPrio.background = [
          {
            # path = "/home/${username}/Pictures/Wallpapers/Rainnight.jpg";
            # blur_passes = 3;
            # blur_size = 8;
          }
        ];
        image = [
          {
            # path = "/home/${username}/.config/face.jpg";
            path = "/home/${username}/Pictures/Wallpapers/Rainnight.jpg";
            size = 150;
            border_size = 4;
            border_color = "rgb(0C96F9)";
            rounding = -1; # Negative means circle
            position = "0, 200";
            halign = "center";
            valign = "center";
          }
        ];
        #   lib.mkPrio.input-field = [
        #     {
        #       size = "200, 50";
        #       position = "0, -80";
        #       monitor = "";
        #       dots_center = true;
        #       fade_on_empty = false;
        #       font_color = "rgb(CFE6F4)";
        #       inner_color = "rgb(657DC2)";
        #       outer_color = "rgb(0D0E15)";
        #       outline_thickness = 5;
        #       placeholder_text = "Password...";
        #       shadow_passes = 2;
        #     }
        #   ];
      };
    };

  };
}
