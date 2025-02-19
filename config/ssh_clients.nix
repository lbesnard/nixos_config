{ pkgs, config, ... }:
{
  programs.ssh.enable = true;

  # Structured SSH Host Entries
  programs.ssh.matchBlocks = {
    "bastion-prod" = {
      hostname = "bastion.aodn.org.au";
    };
    "bastion-prodapp" = {
      hostname = "bastion.prod.aodn.org.au";
    };
    "bastion-sysapp" = {
      hostname = "bastion.systest.aodn.org.au";
    };
    "bastion-dev" = {
      hostname = "bastion.dev.aodn.org.au";
    };

    "nectar_rdsi" = {
      hostname = "131.217.175.208";
      user = "ubuntu";
      forwardAgent = true;
      forwardX11 = true;
    };

    "necfunk" = {
      hostname = "131.217.175.170";
      user = "ubuntu";
      port = 22;
      forwardAgent = true;
      forwardX11 = true;
    };

    "dfunk" = {
      hostname = "100.109.170.21";
      port = 22;
      forwardAgent = true;
      forwardX11 = true;
    };

    "bfunk" = {
      hostname = "100.92.18.39";
      port = 22;
      forwardAgent = true;
      forwardX11 = true;
    };

    "beefunk" = {
      hostname = "100.107.210.10";
      port = 22;
      forwardAgent = true;
      forwardX11 = true;
    };

    "efunk" = {
      hostname = "100.65.194.124";
      port = 22;
      forwardAgent = true;
      forwardX11 = true;
    };

    "ec2_cloudopt" = {
      hostname = "13.55.255.109";
      user = "ubuntu";
      port = 22;
      identityFile = "${config.home.homeDirectory}/.ssh/loz_aws.pem";
    };

    "laptop_work" = {
      hostname = "100.86.85.122";
      user = "lbesnard";
      port = 22;
      identityFile = "${config.home.homeDirectory}/.ssh/id_rsa";
    };
  };

  # Extra SSH Configuration for Global Options & Wildcard Hosts
  programs.ssh.extraConfig = ''
    # MAIN OPTIONS
    Host *
      VisualHostKey no
      AddKeysToAgent yes  

    # Bastion Hosts
    Host bastion-*
      ControlMaster auto
      ControlPath ${config.home.homeDirectory}/.ssh/control-%r@%h:%p
      ControlPersist 5m

    # ProxyJump for different hosts
    Host *-nec-hob
      ProxyJump bastion-prod
      HostName %h.emii.org.au
      ForwardAgent yes
      ForwardX11 yes

    Host *-nec-hob.emii.org.au
      ProxyJump bastion-prod
      HostName %h
      ForwardAgent yes
      ForwardX11 yes

    Host *-aws-syd 
      ProxyJump bastion-prod
      HostName %h-internal.emii.org.au
      ForwardAgent yes
      ForwardX11 yes

    Host *-aws-syd-internal.emii.org.au
      ProxyJump bastion-prod
      HostName %h
      ForwardAgent yes
      ForwardX11 yes

    Host pipeline-rc-nec-hob
      HostName %h.emii.org.au
      ProxyJump bastion-prod
      ForwardAgent yes
      ForwardX11 yes

    Host pipeline-prod-aws-syd
      ProxyJump bastion-prod
      HostName %h.emii.org.au
      ForwardAgent yes
      ForwardX11 yes

    # Direct hosts
    Host po.aodn.org.au
      User vagrant

    Host commandpost
      ProxyJump bastion-prod
      HostName po-dev-aws-syd-internal.emii.org.au
      ForwardAgent yes
      ForwardX11 yes
      ControlMaster auto

    Host pipeline-vagrant
      HostName 127.0.0.1
      User vagrant
      Port 2222
      UserKnownHostsFile /dev/null
      StrictHostKeyChecking no
      PasswordAuthentication no
      IdentityFile $CHEF_DIR/.vagrant/machines/pipeline/virtualbox/private_key
      IdentitiesOnly yes
      LogLevel FATAL
      ForwardAgent yes

    Host geoserver-stack
      User ec2-user
      HostName geoserver-aodnstack-lbesnard.dev.aodn.org.au
      ForwardAgent yes
      PermitLocalCommand yes
      ProxyCommand ssh -q commandpost nc -q0 %h %p
      SetEnv LANG=C LC_CTYPE="en_US.UTF-8"
      LocalCommand tar ch -C${config.home.homeDirectory} .gitconfig .initsys.sh | ssh -o PermitLocalCommand=no %n "tar mx -C/home/ec2-user"
      StrictHostKeyChecking no
      UserKnownHostsFile /dev/null
      LogLevel QUIET

    Host github.com
      IdentityFile ${config.home.homeDirectory}/.ssh/id_rsa
      HostName ssh.github.com
      ForwardX11 no

    # gcw0
    Host gcw0_wlan
      HostName 10.1.1.40
      User root
      Port 22
      IdentityFile ${config.home.homeDirectory}/.ssh/id_dsa.pub

    Host gcw0_usb0
      HostName 10.1.1.2
      User root
      Port 22
      IdentityFile ${config.home.homeDirectory}/.ssh/id_rsa.pub
  '';
}
