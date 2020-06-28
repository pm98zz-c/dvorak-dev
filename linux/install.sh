#!/bin/sh

# Developer Dvorak layout installer.
#
# Author: Pascal Morin <pm98zz.c@gmail.com>
# Source: github

set -e

XKB_ROOT=/usr/share/X11/xkb
if [ -n "$1" ] && [ -d "$1" ]; then
  XKB_ROOT="$1"
fi
if [ -n "$2" ] && [ -d "$2" ]; then
  XKB_ROOT="$1"
fi
# TMP install only.
KEEP="false"
if [ "$1" = "--keep" ] || [ "$2" = "--keep" ]; then
  KEEP="true"
fi

# Source files
XKB_EVDEV_LST="$XKB_ROOT/rules/evdev.lst"
XKB_EVDEV_XML="$XKB_ROOT/rules/evdev.xml"
XKB_US_SYMBOLS="$XKB_ROOT/symbols/us"

# Backup dir.
BACKUP_DIR="$HOME/.dvorak-dev"

OWN_DIR=$(dirname "$0")
cd "$OWN_DIR" || exit 1
OWN_DIR=$(pwd -P)

# Backup original files
backup(){
  if [ ! -d "$BACKUP_DIR" ]; then
    mkdir "$BACKUP_DIR"
  fi
  for FILE in $XKB_US_SYMBOLS $XKB_EVDEV_LST $XKB_EVDEV_XML; do
    cp "$FILE" "$BACKUP_DIR/$(basename "$FILE")"
  done
}
# Restore original files
restore(){
  for FILE in $XKB_US_SYMBOLS $XKB_EVDEV_LST $XKB_EVDEV_XML; do
    cp "$BACKUP_DIR/$(basename "$FILE")" "$FILE"
  done
}

# Check we have all our files
if [ ! -f "$XKB_EVDEV_LST" ] || [ ! -f "$XKB_EVDEV_XML" ] || [ ! -f "$XKB_US_SYMBOLS" ]; then
  echo "Could not find files. Your distribution probably doesn't store those settings in the same place."
  echo "Expected:"
  echo "- $XKB_EVDEV_LST"
  echo "- $XKB_EVDEV_XML"
  echo "- $XKB_US_SYMBOLS"
  exit 1
fi

# Layout definition.
install_symbols(){
  # Markers
  DELIMITER_START="/////////////////////////////// $1 START"
  DELIMITER_END="/////////////////////////////// $1 END"
  # Temp files
  TMP_WFILE="$XDG_RUNTIME_DIR/$1.symbols"
  if [ -f "$TMP_WFILE" ]; then
    rm "$TMP_WFILE"
  fi
  touch "$TMP_WFILE"
  WRITE="true"
  IFS=''
  while read -r LINE; do
    case $LINE in
    "$DELIMITER_START")
      WRITE="false"
    ;;
    "$DELIMITER_END")
      WRITE="true"
    ;;
    *)
      if [ "$WRITE" = "true" ]; then
        echo "$LINE" >> "$TMP_WFILE"
      fi
    ;;
    esac
  done < "$XKB_US_SYMBOLS"
  echo "" >> "$TMP_WFILE"
  cat "$OWN_DIR/$1" >> "$TMP_WFILE"
  printf '%s\n' "$(cat "$TMP_WFILE")" > "$XKB_US_SYMBOLS"
  rm "$TMP_WFILE"
}

create_evdev_xml(){
  if [ "$(grep -c "$1" "$XKB_EVDEV_XML")" = 0 ]; then
    TMP_WFILE="$XDG_RUNTIME_DIR/$1.evdev.xml"
    if [ -f "$TMP_WFILE" ]; then
      rm "$TMP_WFILE"
    fi
    touch "$TMP_WFILE"
    WRITE="false"
    IFS=''
    while read -r LINE; do
      case $LINE in
      *"<name>dvorak-intl</name>"*)
        WRITE="true"
        echo "$LINE" >> "$TMP_WFILE"
      ;;
      *"</variant>"*)
        echo "$LINE" >> "$TMP_WFILE"
        if [ $WRITE = "true" ]; then
          cat "$OWN_DIR/$1.xml" >> "$TMP_WFILE"
          echo "" >> "$TMP_WFILE"
        fi
        WRITE="false"
      ;;
      *)
        echo "$LINE" >> "$TMP_WFILE"
      ;;
      esac
    done < "$XKB_EVDEV_XML"
    printf '%s\n' "$(cat "$TMP_WFILE")" > "$XKB_EVDEV_XML"
    rm "$TMP_WFILE"
  fi
}

create_evdev_lst(){
  if [ "$(grep -c "$1" "$XKB_EVDEV_LST")" = 0 ]; then
    TMP_WFILE="$XDG_RUNTIME_DIR/$1.evdev.lst"
    if [ -f "$TMP_WFILE" ]; then
      rm "$TMP_WFILE"
    fi
    touch "$TMP_WFILE"
    IFS=''
    while read -r LINE; do
      case $LINE in
      '! variant')
        echo "$LINE" >> "$TMP_WFILE"
        cat "$OWN_DIR/$1.lst" >> "$TMP_WFILE"
        echo "" >> "$TMP_WFILE"
      ;;
      *)
        echo "$LINE" >> "$TMP_WFILE"
      ;;
      esac
    done < "$XKB_EVDEV_LST"
    printf '%s\n' "$(cat "$TMP_WFILE")" > "$XKB_EVDEV_LST"
    rm "$TMP_WFILE"
  fi
}

# Always revert if anything fails.
if [ "$KEEP" = "false" ]; then
  trap restore EXIT INT TERM QUIT HUP
fi

# Backup files.
backup
# Install main layout
install_symbols dvorak-dev
create_evdev_xml dvorak-dev
create_evdev_lst dvorak-dev
# Install numeric layout
# install_symbols dvorak-num-dev
# create_evdev_xml dvorak-num-dev
# create_evdev_lst dvorak-num-dev

if [ "$KEEP" = "false" ]; then
  echo "Modified the system config."
  echo "Press enter to restore initial configuration."
  read -r KEEP
  echo "$KEEP"
fi