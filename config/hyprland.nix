{
  lib,
  username,
  host,
  config,
  ...
}:

let
  inherit (import ../hosts/${host}/variables.nix)
    browser
    terminal
    keyboardLayout
    ;
in
with lib;
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    configType = "lua";
    extraConfig = ''
      -- Environment variables
      hl.env("NIXOS_OZONE_WL", "1")
      hl.env("NIXPKGS_ALLOW_UNFREE", "1")
      hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
      hl.env("XDG_SESSION_TYPE", "wayland")
      hl.env("XDG_SESSION_DESKTOP", "Hyprland")
      hl.env("WLR_NO_HARDWARE_CURSORS", "1")
      hl.env("GDK_BACKEND", "wayland,x11")
      hl.env("CLUTTER_BACKEND", "wayland")
      hl.env("QT_QPA_PLATFORM", "wayland;xcb")
      hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
      hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
      hl.env("SDL_VIDEODRIVER", "x11")
      hl.env("MOZ_ENABLE_WAYLAND", "1")
      hl.env("NEXTCLOUD_QT_PLATFORM_OVERRIDE", "wayland")

      -- Autostart
      hl.on("hyprland.start", function()
          hl.exec_cmd("dbus-update-activation-environment --systemd --all")
          hl.exec_cmd("systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
          hl.exec_cmd("killall -q awww-daemon; sleep .5 && awww-daemon")
          hl.exec_cmd("killall -q waybar; sleep .5 && waybar")
          hl.exec_cmd("killall -q swaync; sleep .5 && swaync")
          hl.exec_cmd("nm-applet --indicator")
          hl.exec_cmd("lxqt-policykit-agent")
          hl.exec_cmd("sleep 1.5 && awww img /home/${username}/Pictures/Wallpapers/beautifulmountainscape.jpg")
      end)

      -- Monitor
      hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

      -- Config
      hl.config({
          general = {
              gaps_in = 6,
              gaps_out = 8,
              border_size = 2,
              layout = "dwindle",
              resize_on_border = true,
              col = {
                  active_border   = { colors = {"rgb(${config.lib.stylix.colors.base08})", "rgb(${config.lib.stylix.colors.base0C})"}, angle = 45 },
                  inactive_border = "rgb(${config.lib.stylix.colors.base01})",
              },
          },
          input = {
              kb_layout  = "${keyboardLayout}",
              kb_options = "grp:alt_shift_toggle,caps:super",
              follow_mouse = 1,
              sensitivity  = 0,
              accel_profile = "flat",
              touchpad = {
                  natural_scroll      = false,
                  disable_while_typing = true,
                  scroll_factor       = 0.8,
              },
          },
          misc = {
              initial_workspace_tracking = 0,
              force_default_wallpaper    = 0,
              mouse_move_enables_dpms    = true,
              key_press_enables_dpms     = false,
          },
          decoration = {
              rounding = 10,
              shadow = {
                  enabled      = true,
                  range        = 4,
                  render_power = 3,
                  color        = 0xee1a1a1a,
              },
              blur = {
                  enabled        = true,
                  size           = 5,
                  passes         = 3,
                  ignore_opacity = false,
              },
          },
          dwindle = {
              preserve_split = true,
          },
      })

      -- Animations
      hl.curve("wind",   { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
      hl.curve("winIn",  { type = "bezier", points = { {0.1,  1.1}, {0.1, 1.1}  } })
      hl.curve("winOut", { type = "bezier", points = { {0.3, -0.3}, {0,   1}    } })
      hl.curve("liner",  { type = "bezier", points = { {1,    1},   {1,   1}    } })
      hl.animation({ leaf = "windows",     enabled = true, speed = 6,  bezier = "wind",   style = "slide" })
      hl.animation({ leaf = "windowsIn",   enabled = true, speed = 6,  bezier = "winIn",  style = "slide" })
      hl.animation({ leaf = "windowsOut",  enabled = true, speed = 5,  bezier = "winOut", style = "slide" })
      hl.animation({ leaf = "windowsMove", enabled = true, speed = 5,  bezier = "wind",   style = "slide" })
      hl.animation({ leaf = "border",      enabled = true, speed = 1,  bezier = "liner" })
      hl.animation({ leaf = "fade",        enabled = true, speed = 10, bezier = "default" })
      hl.animation({ leaf = "workspaces",  enabled = true, speed = 5,  bezier = "wind" })

      -- Window rules
      hl.window_rule({ name = "wofi-noborder",   match = { class = "wofi" },                                              border_size = 0 })
      hl.window_rule({ name = "wofi-center",     match = { class = "wofi" },                                              center = true })
      hl.window_rule({ name = "steam-float",     match = { class = "steam" },                                             float = true, size = "1080 900" })
      hl.window_rule({ name = "portal-float",    match = { class = "xdg-desktop-portal-gtk" },                           float = true, size = "70% 70%" })
      hl.window_rule({ name = "look-float",      match = { class = "nwg-look|qt5ct|qt6ct" },                             float = true })
      hl.window_rule({ name = "nm-float",        match = { class = "nm-applet|nm-connection-editor|blueman-manager" },   float = true })
      hl.window_rule({ name = "archive-float",   match = { class = "file-roller|org.gnome.FileRoller" },                 float = true, size = "60% 70%" })
      hl.window_rule({ name = "thunar-progress", match = { class = "thunar", title = "File Operation Progress" },        float = true })
      hl.window_rule({ name = "thunar-confirm",  match = { class = "thunar", title = "Confirm to replace files" },       float = true })
      hl.window_rule({ name = "steam-nofocus",   match = { class = "steam", title = "^$" },                              no_focus = true, min_size = "1 1" })
      hl.window_rule({ name = "thunar-opacity",  match = { class = "thunar" },                                           opacity = "0.9 0.7" })
      hl.window_rule({ name = "sysmon-size",     match = { class = "gnome-system-monitor|org.gnome.SystemMonitor" },     size = "70% 70%" })
      hl.window_rule({ name = "qt6ct-size",      match = { class = "qt6ct" },                                            float = true, size = "60% 70%" })

      -- Suppress maximize events globally
      hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })

      -- Keybinds
      local mod = "SUPER"

      hl.bind(mod .. " + Return",         hl.dsp.exec_cmd("${terminal}"))
      hl.bind(mod .. " + SHIFT + L",      hl.dsp.exec_cmd("hyprlock"))
      hl.bind(mod .. " + SHIFT + R",      hl.dsp.exec_cmd("~/.config/hypr/toggle_keyboard_layout.sh"))
      hl.bind(mod .. " + SHIFT + Return", hl.dsp.exec_cmd("rofi-launcher"))
      hl.bind(mod .. " + SHIFT + M",      hl.dsp.exec_cmd("kitty --start-as fullscreen -e cmatrix"))
      hl.bind(mod .. " + SHIFT + W",      hl.dsp.exec_cmd("web-search"))
      hl.bind(mod .. " + ALT + W",        hl.dsp.exec_cmd("wallsetter"))
      hl.bind(mod .. " + SHIFT + N",      hl.dsp.exec_cmd("swaync-client -rs"))
      hl.bind(mod .. " + W",              hl.dsp.exec_cmd("${browser}"))
      hl.bind(mod .. " + SHIFT + U",      hl.dsp.exec_cmd("keepmenu"))
      hl.bind(mod .. " + SHIFT + K",      hl.dsp.exec_cmd("keepmenu -a {PASSWORD}{ENTER}"))
      hl.bind(mod .. " + E",              hl.dsp.exec_cmd("emopicker9000"))
      hl.bind(mod .. " + S",              hl.dsp.exec_cmd("screenshootin"))
      hl.bind(mod .. " + D",              hl.dsp.exec_cmd("discord"))
      hl.bind(mod .. " + O",              hl.dsp.exec_cmd("obs"))
      hl.bind(mod .. " + C",              hl.dsp.exec_cmd("hyprpicker -a"))
      hl.bind(mod .. " + G",              hl.dsp.exec_cmd("gimp"))
      hl.bind(mod .. " + SHIFT + G",      hl.dsp.exec_cmd("godot4"))
      hl.bind(mod .. " + T",              hl.dsp.exec_cmd("thunar"))
      hl.bind(mod .. " + M",              hl.dsp.exec_cmd("spotify"))
      hl.bind(mod .. " + Q",              hl.dsp.window.close())
      hl.bind(mod .. " + P",              hl.dsp.window.pseudo())
      hl.bind(mod .. " + SHIFT + I",      hl.dsp.layout("togglesplit"))
      hl.bind(mod .. " + F",              hl.dsp.window.fullscreen())
      hl.bind(mod .. " + SHIFT + F",      hl.dsp.window.float({ action = "toggle" }))
      hl.bind(mod .. " + SHIFT + C",      hl.dsp.exit())

      -- Move windows in tiling. Up/down fall back to toggling the dwindle
      -- split orientation when there's no window in that direction to swap
      -- with (e.g. two windows side-by-side becoming stacked).
      local function move_or_toggle_split(direction)
          return function()
              local before = hl.get_active_window()
              hl.dispatch(hl.dsp.window.move({ direction = direction }))
              local after = hl.get_active_window()
              if before and after and before.at[1] == after.at[1] and before.at[2] == after.at[2] then
                  hl.dispatch(hl.dsp.layout("togglesplit"))
              end
          end
      end

      hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
      hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
      hl.bind(mod .. " + SHIFT + up",    move_or_toggle_split("u"))
      hl.bind(mod .. " + SHIFT + down",  move_or_toggle_split("d"))
      hl.bind(mod .. " + SHIFT + H",     hl.dsp.window.move({ direction = "l" }))
      hl.bind(mod .. " + SHIFT + J",     move_or_toggle_split("d"))

      -- Focus
      hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
      hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
      hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
      hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))
      hl.bind(mod .. " + H",     hl.dsp.focus({ direction = "left" }))
      hl.bind(mod .. " + L",     hl.dsp.focus({ direction = "right" }))
      hl.bind(mod .. " + K",     hl.dsp.focus({ direction = "up" }))
      hl.bind(mod .. " + J",     hl.dsp.focus({ direction = "down" }))

      -- Workspaces
      for i = 1, 10 do
          local key = i % 10
          hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
          hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
      end

      hl.bind(mod .. " + SHIFT + SPACE", hl.dsp.window.move({ workspace = "special" }))
      hl.bind(mod .. " + SPACE",         hl.dsp.workspace.toggle_special())
      hl.bind(mod .. " + CTRL + right",  hl.dsp.focus({ workspace = "e+1" }))
      hl.bind(mod .. " + CTRL + left",   hl.dsp.focus({ workspace = "e-1" }))
      hl.bind(mod .. " + mouse_down",    hl.dsp.focus({ workspace = "e+1" }))
      hl.bind(mod .. " + mouse_up",      hl.dsp.focus({ workspace = "e-1" }))

      -- Mouse
      hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
      hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

      -- Alt+Tab
      hl.bind("ALT + Tab", hl.dsp.window.cycle_next())
      hl.bind("ALT + Tab", hl.dsp.window.bring_to_top())

      -- Audio / Media
      hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))
      hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
      hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true })
      hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"))
      hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("playerctl play-pause"))
      hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"))
      hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"))

      -- Brightness
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))
      hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +5%"))

      -- Lid switch
      hl.bind("switch:Lid Switch", hl.dsp.exec_cmd("hyprlock & disown && systemctl suspend"), { locked = true })
    '';
  };
}
