#!/bin/sh

OWN_DIR=$(dirname "$0")
cd "$OWN_DIR" || exit 1
OWN_DIR=$(pwd -P)
ROOT_DIR="$HOME/Library/Keyboard Layouts"

if [ "$(whoami)" = "root" ]; then
  ROOT_DIR="/Library/Keyboard Layouts"
fi

cp -r "$OWN_DIR/DeveloperDvorak.bundle" "$ROOT_DIR"

/usr/bin/SetFile -a B "$ROOT_DIR/DeveloperDvorak.bundle"