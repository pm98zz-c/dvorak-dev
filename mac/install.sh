#!/bin/sh
set -e -x
LAYOUT="Developer Dvorak"
LANGUAGE=en
VERSION=1.0
COPYRIGHT="Copyright 2020 (c) Pascal Morin"

OWN_DIR=$(dirname "$0")
cd "$OWN_DIR" || exit 1
OWN_DIR=$(pwd -P)

ROOT_DIR="/Library/Keyboard Layouts"
BUNDLE_DIR="$ROOT_DIR/$LAYOUT.bundle"
if [ ! -d "$BUNDLE_DIR/Contents/Resources/English.lproj" ]; then
  mkdir -p "$BUNDLE_DIR/Contents/Resources/English.lproj"
fi

cp "$OWN_DIR/dvorak-dev.keylayout" "$BUNDLE_DIR/Contents/Resources/"

cat > "$BUNDLE_DIR/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>CFBundleIdentifier</key><string>com.apple.keyboardlayout.$LAYOUT</string>
<key>CFBundleName</key><string>$LAYOUT</string>
<key>CFBundleVersion</key><string>$VERSION</string>
<key>KLInfo_$LAYOUT</key>
  <dict>
  <key>TISInputSourceID</key><string>com.apple.keyboardlayout.$LAYOUT</string>
  <key>TISIntendedLanguage</key><string>$LANGUAGE-Latn</string>
  </dict>
</dict>
</plist>
EOF

cat > "$BUNDLE_DIR/Contents/version.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>BuildVersion</key><string>$VERSION</string>
<key>CFBundleVersion</key><string>$VERSION</string>
<key>ProjectName</key><string>$LAYOUT</string>
<key>SourceVersion</key><string>$VERSION</string>
</dict>
</plist>
EOF


cat > "$BUNDLE_DIR/Contents/Resources/English.lproj/InfoPlist.strings" <<EOF
NSHumanReadableCopyright = "$COPYRIGHT";
"$LAYOUT" = "$LAYOUT";
EOF

/usr/bin/SetFile -a B "$BUNDLE_DIR"