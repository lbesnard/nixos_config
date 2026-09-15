{ pkgs, ... }:

{
  # The Ergoapt Groove has no dedicated Page Up / Page Down keys, and its Fn
  # key is handled entirely inside the keyboard's own firmware (it never
  # shows up as a Linux input event), so it can't be used as a kanata
  # modifier. Instead, holding Space turns Up/Down into Page Up/Page Down
  # (tapping Space still types a space). Handy for scrolling tmux
  # copy-mode/pane history.
  services.kanata = {
    enable = true;
    package = pkgs.kanata;
    keyboards.ergoapt = {
      # Empty devices list = kanata auto-detects and intercepts all
      # keyboards. The Ergoapt Groove is bluetooth/uhid based and doesn't
      # get a stable /dev/input/by-id symlink, so we let kanata find it.
      devices = [ ];
      config = ''
        (defsrc
          spc
          up
          down)

        (defalias
          nav (tap-hold-press 200 200 spc (layer-while-held nav)))

        (deflayer default
          @nav
          up
          down)

        (deflayer nav
          spc
          pgup
          pgdn)
      '';
    };
  };
}
