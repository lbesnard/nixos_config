{
  pkgs,
  username,
  ...
}:

let
  inherit (import ./variables.nix) gitUsername;
  joplin = pkgs.callPackage ./joplin.nix { }; # Call the package here
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
      ];
      shell = pkgs.bash;

      ignoreShellProgramCheck = true;
      packages = with pkgs; [
        # Development & Programming
        gcc
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
        gh-dash
        lazygit
        zsh-forgit

        # System Utilities
        lsd
        bash-completion
        zsh
        zoxide
        autojump
        thefuck
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
        thefuck
        caligula
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
        darktable
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
        pinentry
        ydotool

        # Virtualisation & Containers
        virtualbox
        virt-manager
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
        slack
        zoom-us
        whatsapp-for-linux
        joplin # manually built
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
