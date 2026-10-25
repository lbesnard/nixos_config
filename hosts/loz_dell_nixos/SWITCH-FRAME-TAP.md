# Switch Frame Tap on NixOS

How to set up [Switch Frame Tap](https://github.com/TomasUribe/switch-frame-tap)
(stream/record a Nintendo Switch over USB) on NixOS, without the upstream
`install.sh` + `sudo cp .../99-switch-frame-tap.rules` steps, which don't fit
NixOS's declarative config.

## 1. Copy the module

Copy `hosts/loz_dell_nixos/switch-frame-tap.nix` from this repo to wherever
your own host config lives — it's a **single self-contained NixOS module**:
it defines the package, installs the udev rule, puts the viewer on `$PATH`
and in your app menu, and works around every issue hit while setting this
up (see Troubleshooting below).

## 2. Add it to your host's imports

```nix
imports = [
  # ...your existing imports...
  ./switch-frame-tap.nix
];
```

That's it — no other files need editing. Then:

```sh
sudo nixos-rebuild switch --flake .#<your-host>
```

To bump to a newer release later: edit `version` and `hash` inside the
module, then run
`nix-prefetch-url --type sha256 <the .tar.gz release URL>` and convert the
result with `nix hash convert --to sri --hash-algo sha256 <hash>` — but note
`fetchzip` hashes the *extracted* contents, not the raw archive, so the
first build attempt after a bump will fail with a hash mismatch and print
the correct hash to copy in (`got: sha256-...`).

## 3. First-time use

1. On the Switch: install the `-switch.zip` sysmodule from the same release
   onto the SD card root and reboot (see upstream README), then launch the
   manager app and select **USB**.
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
- **Device shows in `lsusb` but the viewer still won't open it (same
  "waiting for the console" message)** — check
  `getfacl /dev/bus/usb/<bus>/<dev>`. If there's no `user:<you>:rw-` entry,
  the udev rule hasn't been applied to that specific device yet — this
  happens because the Switch can reconnect as a "new" USB device (e.g.
  after a sysmodule update reboots it) before udevd re-evaluates the rule
  for it. The module's `system.activationScripts.switch-frame-tap-udev`
  re-runs `udevadm control --reload-rules` + `udevadm trigger
  --action=add --subsystem-match=usb` on every boot/rebuild to fix this
  automatically; if you still hit it between rebuilds, just run those two
  commands with `sudo` yourself.
- **Viewer connects (`waiting for frames on ... ep 0x81`) but no window
  appears, plus `SDL_Init: x11 not available`** — SDL2's video/audio/GL
  backends are `dlopen()`'d at runtime, not linked, so `autoPatchelfHook`
  can't see them; the module's `wrapProgram ... LD_LIBRARY_PATH` already
  works around this. If you still see this, make sure you're actually
  running the Nix-built binary and not a stray copy from running
  upstream's `install.sh` manually — check with
  `which switch-frame-tap-viewer` and remove any
  `~/.local/bin/switch-frame-tap-viewer` left over from that.
