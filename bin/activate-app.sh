#!/usr/bin/env bash

# ~~~ Utility to toggle apps
# Requirements:
# - yabai
# - jq

set -eo pipefail
PATH="/opt/homebrew/bin:$HOME/bin:$PATH"

# Focus app if unfocused, otherwise tab to most recent app.
function toggle() {
  focused=$(yabai -m query --windows --window | jq -re '.app')

  # recent and next may not exist if the most recent or any
  # windows are managed by yabai, respectively; in that case cmd-tab
  if [[ $focused == "$1" ]]; then
    yabai -m window --focus recent || \
    yabai -m window --focus next || \
    /usr/bin/osascript -e 'tell application "System Events" to key code 48 using {command down}'
  else
    /usr/bin/osascript -e 'tell application "'"$1"'" to activate'
  fi
}

# Toggle an app using escape to close it if focused. Used for toolbar popups
# that will remain visible if we simply focus another window.
function toggle_escape() {
  focused=$(yabai -m query --windows --window | jq -re '.app')

  if [[ $focused == "$1" ]]; then
    /usr/bin/osascript -e 'tell application "System Events" to key code 53'
  else
    /usr/bin/osascript -e 'tell application "'"$1"'" to activate'
  fi
}

function cycle() {
  # Yabai sorts app windows in order of recency, so in order
  # to avoid just toggling between two windows, we sort them
  # by id, taking the first if unfocused, otherwise the next.
  #
  # Using applescript to send cmd+` only works for windows in
  # the same space.
  yabai -m query --windows | jq -re --arg APP "$1" '
      map(select(.app == $APP and ."is-minimized" == false))
      | first as $recent
      | sort_by(.id)
      | length as $len
      | index(map(select(."has-focus" == true))) as $focused
      | if $focused | not then $recent.id elif $focused < $len - 1 then nth($focused + 1).id else nth(0).id end
  ' | xargs -I{} yabai -m window --focus {}
}

case $1 in
  Chrome|"Google Chrome")
    cycle "Google Chrome"  
    ;;
  Code|Safari)
    cycle "$1"
    ;;
  Glyphfinder)
    toggle_escape "$1"
    ;;
  *)
    toggle "$1"
esac

