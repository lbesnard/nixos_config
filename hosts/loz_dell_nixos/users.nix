{
  pkgs,
  pkgs-unstable,
  username,
  ...
}:

let
  inherit (import ./variables.nix) gitUsername;
  joplin = pkgs.callPackage ./joplin.nix { };
  task-tui = pkgs.callPackage ./task-tui.nix { };
in
{

  users.users = {
    "${username}" = {
      homeMode = "755";
      isNormalUser = true;
      description = "${gitUsername}";
      extraGroups = [
        "networkmanager"
        "wheel"
        "libvirtd"
        "scanner"
        "lp"
        "docker"
        "ydotool"
        "video"
      ];
      shell = pkgs.zsh;

      ignoreShellProgramCheck = true;
      packages = with pkgs; [

        x2goclient

        # Development & Programming
        gcc
        openjdk
        gem
        lua
        cargo
        ruby
        gnumake
        tree-sitter
        ghostscript
        neovim
        luajitPackages.luarocks
        chafa

        micromamba
        poetry
        nodejs
        perl
        python3
        pyenv
        bat
        delta
        diff-so-fancy
        fd
        fzf
        jq
        yq
        sad
        silver-searcher
        ripgrep

        # github
        git
        gh
        gh-copilot
        gh-dash
        lazygit
        zsh-forgit

        # System Utilities
        lsd
        bash-completion
        cockpit
        zsh
        zoxide
        autojump
        fasd
        btop
        lnav
        dfc
        lsof
        ethtool
        exiftool
        zip
        p7zip
        usbutils
        udiskie
        # thefuck
        caligula # create usb bootable imaage
        rpi-imager
        usbimager
        rclone
        gparted

        # Networking Tools
        dig
        dnsutils
        wireshark
        termshark
        ifwifi # nmcli
        iw
        netscanner
        tcpdump
        croc
        iperf3
        awscli2
        curl
        httpie
        tailscale
        wireguard-tools
        openvpn
        act
        aria2
        nmap
        filezilla
        transmission_4-qt

        # File & Process Management
        nnn
        ranger
        tree
        tmux
        tig
        viu
        yazi
        ueberzug
        ueberzugpp
        ncdu
        gnome-disk-utility
        android-tools

        # Multimedia & Graphics
        ffmpeg
        vlc
        digikam
        shotcut
        audacity
        inkscape-with-extensions
        kazam
        obs-studio
        conjure
        cheese
        imagemagick
        krita
        pkgs-unstable.darktable
        hugin # panorama
        digikam
        evince
        handbrake
        yt-dlp

        # Office & Documentation
        libreoffice-qt6-fresh
        tldr
        cheat
        glow
        koreader
        calibre

        # Security & Password Management
        authenticator
        keepassxc
        pinentry-curses
        ydotool

        # Virtualisation & Containers
        virtualbox
        virt-manager
        libvirt-glib
        qemu
        docker
        docker-compose

        # Desktop & Window Management
        alacritty
        ghostty
        wofi
        dmenu
        xdotool
        keepmenu
        wdisplays
        # nwg-displays  # has issues https://github.com/nwg-piotr/nwg-displays/issues/81

        # Communication
        hugo # blog
        slack
        zoom-us
        wasistlos
        joplin # manually built
        # joplin-desktop
        # logseq  ## issue with non free package
        appflowy
        nextcloud-client
        firefox
        # element-desktop # replaced by element installed via brave

        anki-bin # flashcards

        # NetCDF
        netcdf
        nco
        netcdfcxx4
        ncview

        # database
        pgcli
        sqlite
        mycli

        # task management
        taskwarrior3
        task-tui

        # games
        # emulationstation-de
        (pkgs.retroarch.withCores (cores: with cores; [
          snes9x    # SNES
          nestopia   # NES
          mgba       # GBA
          mupen64plus # N64
        ]))
      ];
    };
    # "newuser" = {
    #   homeMode = "755";
    #   isNormalUser = true;
    #   description = "New user account";
    #   extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    #   shell = pkgs.bash;
    #   ignoreShellProgramCheck = true;
    #   packages = with pkgs; [];
    # };
  };
}
