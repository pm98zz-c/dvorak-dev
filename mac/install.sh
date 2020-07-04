#!/bin/sh

OWN_DIR=$(dirname "$0")
cd "$OWN_DIR" || exit 1
OWN_DIR=$(pwd -P)

ROOT_DIR="/Library/Keyboard Layouts"

cp -r "$OWN_DIR/Developer Dvorak.bundle" "$ROOT_DIR"

/usr/bin/SetFile -a B "$ROOT_DIR/Developer Dvorak.bundle"