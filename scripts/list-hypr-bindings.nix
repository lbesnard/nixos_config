{ pkgs, host, ... }:

let
  inherit (import ../hosts/${host}/variables.nix) terminal browser;
in
pkgs.writeShellScriptBin "list-hypr-bindings" ''
  yad --width=800 --height=650 \
  --center \
  --fixed \
  --title="Hyprland Keybindings" \
  --no-buttons \
  --list \
  --column=Key: \
  --column=Description: \
  --column=Command: \
  --timeout=90 \
  --timeout-indicator=right \
  " = Windows/Super/CAPS LOCK" "Modifier Key, used for keybindings" "Doesn't really execute anything by itself." \
  " + ENTER" "Terminal" "${terminal}" \
  " + SHIFT + L" "Screen lock" "hyprlock" \
  " + SHIFT + ENTER" "App Launcher" "rofi" \
  " + SHIFT + R" "Change Keyboard layout (aus,fr,no)" "toggle_keyboard_layout" \
  " + SHIFT + M" "Open in fullscreen cmatrix" "kitty cmatrix" \
  " + ALT + W" "Change Wallpaper" "wallsetter" \
  " + Q" "Kill Focused Window" "killactive" \
  " + SHIFT + W" "Search Websites Like Nix Packages" "web-search" \
  " + SHIFT + N" "Reload SwayNC Styling" "swaync-client -rs" \
  " + SHIFT + K" "Open password manager via dmenu - password only" "keepmenu" \
  " + SHIFT + U" "Open password manager via dmenu - user/password" "keepmenu" \
  " + W" "Launch Web Browser" "${browser}" \
  " + E" "Launch Emoji Selector" "emopicker9000" \
  " + S" "Take Screenshot" "screenshootin" \
  ${""/* " + D" "Launch Discord" "discord" \ */}
  " + O" "Launch OBS" "obs" \
  " + G" "Launch GIMP" "gimp" \
  " + T" "Launch New File Browser Window" "thunar" \
  " + M" "Launch Spotify" "spotify" \
  " + P" "Pseudo Tiling" "pseudo" \
  " + SHIFT + I" "Toggle Split Direction" "togglesplit" \
  " + F" "Toggle Focused Fullscreen" "fullscreen" \
  " + SHIFT + F" "Toggle Focused Floating" "fullscreen" \
  " + SHIFT + C" "Quit / Exit Hyprland" "exit" \
  " + Left" "Move Focus To Window On The Left" "movefocus,l" \
  " + Right" "Move Focus To Window On The Right" "movefocus,r" \
  " + Up" "Move Focus To Window On The Up" "movefocus,u" \
  " + Down" "Move Focus To Window On The Down" "movefocus,d" \
  " + SHIFT + Left" "Move Focused Window Left" "movewindow,l" \
  " + SHIFT + Right" "Move Focused Window Right" "movewindow,r" \
  " + SHIFT + Up" "Move Focused Window Up" "movewindow,u" \
  " + SHIFT + Down" "Move Focused Window Down" "movewindow,d" \
  " + H" "Move Focus To Window On The Left" "movefocus,l" \
  " + L" "Move Focus To Window On The Right" "movefocus,r" \
  " + K" "Move Focus To Window On The Up" "movefocus,u" \
  " + J" "Move Focus To Window On The Down" "movefocus,d" \
  " + SHIFT + H" "Move Focused Window Left" "movewindow,l" \
  " + SHIFT + L" "Move Focused Window Right" "movewindow,r" \
  " + SHIFT + K" "Move Focused Window Up" "movewindow,u" \
  " + SHIFT + J" "Move Focused Window Down" "movewindow,d" \
  " + SPACE" "Toggle Special Workspace" "togglespecialworkspace" \
  " + SHIFT + SPACE" "Send Focused Window To Special Workspace" "movetoworkspace,special" \
  " + 1-0" "Move To Workspace 1 - 10" "workspace,X" \
  " + SHIFT + 1-0" "Move Focused Window To Workspace 1 - 10" "movetoworkspace,X" \
  " + MOUSE_LEFT" "Move/Drag Window" "movewindow" \
  " + MOUSE_RIGHT" "Resize Window" "resizewindow" \
  "ALT + TAB" "Cycle Window Focus + Bring To Front" "cyclenext & bringactivetotop" \
  ""
''
