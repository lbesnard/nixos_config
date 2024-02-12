# ZaneyOS 🟰 Best ❄️ NixOS Configs

ZaneyOS is a way of reproducing my configuration on any NixOS system. This includes the wallpaper, scripts, applications, config files, and more. *Please remember to change username and hostname in flake.nix.*

![](./config/home/files/media/demo.jpg)

## READ THE WIKI

If you want to learn more about my system, [this project has a Wiki](https://gitlab.com/Zaney/zaneyos/-/wikis/home) that explains a ton. It even explains what NixOS is why you may want to choose it and so much more.

# Install / Steps To Reproduce My System

- Run this command to ensure Git is installed:

```
nix-shell -p git vim 
```

- Clone this repo & enter it:

```
git clone https://gitlab.com/zaney/zaneyos.git
cd zaneyos
```

- *You should stay in this folder for the rest of the install*
- Change any options in options.nix as needed.
- Generate your hardware.nix like so:

```
nixos-generate-config --show-hardware-config > hardware.nix
```

- Run this to enable flakes and install the flake:

```
NIX_CONFIG="experimental-features = nix-command flakes" 

sudo nixos-rebuild switch --flake .#thehostnameyousetinoptions.nix
```

Now when you want to rebuild the configuration you have access to an alias called flake-rebuild that will rebuild the flake based of the flakeDir variable you set in options.nix!

Hope you enjoy!
