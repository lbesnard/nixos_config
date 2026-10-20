# Switch Frame Tap on NixOS

How to set up [Switch Frame Tap](https://github.com/TomasUribe/switch-frame-tap)
(stream/record a Nintendo Switch over USB) on NixOS, without the upstream
`install.sh` + `sudo cp .../99-switch-frame-tap.rules` steps, which don't fit
NixOS's declarative config.

This repo's working setup lives in `hosts/loz_dell_nixos/switch-frame-tap.nix`,
wired into `config.nix` and `users.nix`. Copy those three snippets into your
own host's config (changing the host directory as needed).

## 1. The package

`switch-frame-tap.nix` (next to your host's `config.nix`):

```nix
# switch-frame-tap: Linux viewer for streaming/recording a Nintendo Switch over USB
# https://github.com/TomasUribe/switch-frame-tap
# Update: bump version/url below and re-run nix-prefetch-url on the new tarball
{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  makeWrapper,
  libusb1,
  SDL2,
  alsa-lib,
  libGL,
  libglvnd,
  mesa,
  libpulseaudio,
  wayland,
  libxkbcommon,
  libdecor,
  libdrm,
  libva,
  dbus,
  xorg,
}:

stdenv.mkDerivation rec {
  pname = "switch-frame-tap";
  version = "0.7.13.1";

  src = fetchzip {
    url = "https://github.com/TomasUribe/switch-frame-tap/releases/download/v${version}/switch-frame-tap-${version}-linux.tar.gz";
    hash = "sha256-4H5KbzQ0c0zm4AyCzk3+puhC5IvwnQ+AokhQqwKzkXM=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  # Most of SDL2's backends (X11, Wayland, OpenGL/EGL, audio) and libva are
  # dlopen()'d at runtime rather than linked, so autoPatchelfHook (which only
  # patches DT_NEEDED entries) can't find them. runtimeLibs below is injected
  # into LD_LIBRARY_PATH so those dlopen() calls succeed.
  runtimeLibs = [
    SDL2
    alsa-lib
    libGL
    libglvnd
    mesa
    libpulseaudio
    wayland
    libxkbcommon
    libdecor
    libdrm
    libva
    dbus
    xorg.libX11
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXi
    xorg.libXext
    xorg.libXfixes
    xorg.libXScrnSaver
  ];

  buildInputs = [
    libusb1
    stdenv.cc.cc.lib
  ] ++ runtimeLibs;

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 switch-frame-tap-viewer $out/bin/switch-frame-tap-viewer
    install -Dm644 switch-frame-tap.svg $out/share/icons/hicolor/scalable/apps/switch-frame-tap.svg
    install -Dm644 99-switch-frame-tap.rules $out/lib/udev/rules.d/99-switch-frame-tap.rules
    install -Dm644 licenses/*.txt -t $out/share/licenses/switch-frame-tap

    wrapProgram $out/bin/switch-frame-tap-viewer \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"

    mkdir -p $out/share/applications
    cat > $out/share/applications/switch-frame-tap.desktop <<DESK
    [Desktop Entry]
    Type=Application
    Name=Switch Frame Tap
    Comment=Watch and record your Switch, streamed over USB or the network
    Exec=$out/bin/switch-frame-tap-viewer --app
    PrefersNonDefaultGPU=true
    Icon=switch-frame-tap
    Terminal=false
    Categories=Game;AudioVideo;
    DESK

    runHook postInstall
  '';

  meta = with lib; {
    description = "Watch and record your Nintendo Switch, streamed over USB or the network";
    homepage = "https://github.com/TomasUribe/switch-frame-tap";
    license = licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "switch-frame-tap-viewer";
  };
}
```

To bump to a newer release: change `version`, then run
`nix-prefetch-url --type sha256 <the .tar.gz release URL>` and convert the
result with `nix hash convert --to sri --hash-algo sha256 <hash>` — but note
`fetchzip` hashes the *extracted* contents, not the raw archive, so the
first build attempt will fail with a hash mismatch and print the correct
hash to copy in (`got: sha256-...`).

## 2. Wire it in

In your host's `config.nix` (or wherever you declare `services.udev`):

```nix
# Switch Frame Tap: installs the udev rule (1209:5f1e) so the viewer may
# open the Nintendo Switch over USB without root.
services.udev.packages = [ (pkgs.callPackage ./switch-frame-tap.nix { }) ];
```

In your host's `users.nix` (or wherever your user's `packages` list lives):

```nix
let
  switch-frame-tap = pkgs.callPackage ./switch-frame-tap.nix { };
in
{
  users.users."<you>".packages = [
    # ...
    switch-frame-tap
  ];
}
```

This gives you:
- `switch-frame-tap-viewer` on `$PATH`
- a "Switch Frame Tap" entry in your app menu
- the udev rule (`1209:5f1e`, `uaccess`) applied automatically at boot/rebuild,
  so no manual `sudo cp .../rules.d/` + `udevadm trigger` is needed

## 3. Apply and use

```sh
sudo nixos-rebuild switch --flake .#<your-host>
```

Then:
1. On the Switch: install the `-switch.zip` sysmodule from the same release
   onto the SD card root and reboot (see upstream README) and launch the
   manager app, selecting **USB**.
2. On the PC: connect the Switch **in handheld mode** (USB only works
   undocked — the dock uses the port) via a USB-C cable with data lines
   (not charge-only).
3. Launch a game on the Switch (the HOME menu alone won't stream).
4. Run `switch-frame-tap-viewer` (or launch it from the app menu).

## Troubleshooting

- **`lsusb` never shows `1209:5f1e` after plugging in** — try a different
  cable (many USB-C cables are charge-only, no data lines) and/or a
  different port on the PC.
- **Viewer prints `waiting for the console (1209:5f1e) - boot it with 'usb'
  in sdmc:/applet-mitm.armed...`** — the PC hasn't opened the USB device at
  all yet. Check `lsusb` first; if the device *is* listed but this message
  persists, it's almost always a permissions problem (see next point).
- **Device shows in `lsusb` but the viewer still won't open it** — check
  `getfacl /dev/bus/usb/<bus>/<dev>`. If there's no `user:<you>:rw-` entry,
  the udev rule hasn't been applied to that specific device yet (it only
  auto-applies to devices detected *after* the rule is loaded). Fix with:
  ```sh
  sudo udevadm control --reload-rules
  sudo udevadm trigger --action=add --subsystem-match=usb
  ```
  After a full `nixos-rebuild switch` and a fresh plug-in, this shouldn't be
  needed again.
- **Viewer connects (`waiting for frames on ... ep 0x81`) but no window
  appears, plus `SDL_Init: x11 not available`** — SDL2's video/audio/GL
  backends are `dlopen()`'d at runtime, not linked, so `autoPatchelfHook`
  can't see them; the wrapper's `LD_LIBRARY_PATH` (in the package above)
  fixes this. If you still see this after rebuilding, make sure you're
  actually running the Nix-built binary and not a stray copy from running
  upstream's `install.sh` manually — check with `which switch-frame-tap-viewer`
  and remove any `~/.local/bin/switch-frame-tap-viewer` left over from that.
