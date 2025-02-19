#!/usr/bin/env bash

toggle_keyboard_layout() {
  local layouts=("us" "fr" "no")
  local current_layout
  current_layout=$(hyprctl getoption input:kb_layout -j | jq -r '.str')

  local next_layout="${layouts[0]}"
  for i in "${!layouts[@]}"; do
    if [[ "${layouts[i]}" == "$current_layout" ]]; then
      next_layout="${layouts[((i + 1) % ${#layouts[@]})]}"
      break
    fi
  done

  hyprctl keyword input:kb_layout "$next_layout"
  notify-send "Keyboard Layout" "Switched to: $next_layout"
}

toggle_keyboard_layout
