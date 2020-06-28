#!/bin/sh

# Developer Dvorak layout.
#
# Author: Pascal Morin <pm98zz.c@gmail.com>
# Source: github

GIT_DIR=$(git rev-parse --show-toplevel)
cd "$GIT_DIR" || exit 1
GIT_DIR=$(pwd -P)
OWN_DIR="$GIT_DIR/mac"

# Markers
DELIMITER='	<keyMapSet id="ANSI">'
SRC_FILE="$GIT_DIR/matrix.csv"
# Main layout
TPL_FILE="$OWN_DIR/dvorak-dev.tpl.keylayout"
DEST_FILE="$OWN_DIR/dvorak-dev.keylayout"
TMP_FILE="/tmp/dvorak-dev.tmp"
# Numeric layout
NUM_TPL_FILE="$OWN_DIR/dvorak-num-dev.tpl.keylayout"
NUM_DEST_FILE="$OWN_DIR/dvorak-num-dev.keylayout"
NUM_TMP_FILE="/tmp/dvorak-num-dev.tmp"

# Remove tmp and artifacts.
cleanup(){
  for FILE in $DEST_FILE $NUM_DEST_FILE $TMP_FILE $NUM_TMP_FILE; do
    if [ -f "$FILE" ]; then
      rm "$FILE"
    fi
  done
}

# Convert char to output.
# @param $1 string char
# @param $2 int keycode
# @param $3 string filepath
convert_to_code(){
  STRING=""
  case $1 in
    'NoSymbol')
      return
    ;;
    [[:alpha:]])
      echo "		<key code=\"$2\" action=\"$1\"/>" >> "$3"
    ;;
    [[:digit:]])
      echo "		<key code=\"$2\" output=\"$1\"/>" >> "$3"
    ;;
    #@todo Something is wrong with the hyphen
    'hyphen')
      STRING="&#x2010;"
      echo "		<key code=\"$2\" output=\"$STRING\"/>" >> "$3"
    ;;
    'dead'*)
      echo "		<key code=\"$2\" action=\"$1\"/>" >> "$3"
    ;;
    'comma')
      echo "		<key code=\"$2\" output=\",\"/>" >> "$3"
    ;;
    'Space')
      echo "		<key code=\"$2\" output=\" \"/>" >> "$3"
    ;;
    'NoBreakSpace')
      STRING="&#x00A0;"
      echo "		<key code=\"$2\" output=\"$STRING\"/>" >> "$3"
    ;;
    'NarrowNoBreakSpace')
      STRING="&#x202F;"
      echo "		<key code=\"$2\" output=\"$STRING\"/>" >> "$3"
    ;;
    'BackSpace')
      STRING="&#x08;"
      echo "		<key code=\"$2\" output=\"$STRING\"/>" >> "$3"
    ;;
    *)
      STRING="$(printf "%s" "$1" | iconv -f utf8 -t utf32be |  xxd -p | sed -r 's/^0+/0x/' | xargs printf '&#x%04X;\n')"
      echo "		<key code=\"$2\" output=\"$STRING\"/>" >> "$3"
    ;;
  esac
  # ISO/JIS
  if [ "$2" = "10" ]; then
    convert_to_code "$1" "50" "$3"
    convert_to_code "$1" "93" "$3"
  fi
}

# Generate the keys definition from CSV.
# @param $1 int level to start with.
# @param $2 string filepath
generate_keys(){
  COUNT=1
  LEVEL=0
  while [ $COUNT -lt  7 ]; do
    if [ "$COUNT" -gt "$1" ]; then
      echo "<keyMap index=\"$LEVEL\" baseMapSet=\"static\" baseIndex=\"$LEVEL\">" >> "$2"
      #echo "<keyMap index=\"$LEVEL\">" >> "$2"
      while read -r LINE; do
        KEY=$(echo "$LINE" | cut -d ',' -f10 )
        CHAR=$(echo "$LINE" | cut -d ',' -f$COUNT )
        convert_to_code "$CHAR" "$KEY" "$2"
      done < "$SRC_FILE"
      echo "</keyMap>" >> "$2"
    fi
    COUNT=$((COUNT + 1))
    LEVEL=$((LEVEL + 1))
  done
}

# Generate the layout definitions.
# @param $1 src template
# @param $2 dest file
# @param $3 key definition file
generate_layouts(){
  IFS=''
  while read -r LINE; do
    case $LINE in
    "$DELIMITER")
      echo "$LINE" >> "$2"
      cat "$3" >> "$2"
    ;;
    *)
      echo "$LINE" >> "$2"
    ;;
    esac
  done < "$1"
}

# Remove target files
cleanup
# Generate key definitions
generate_keys 0 "$TMP_FILE"
generate_keys 4 "$NUM_TMP_FILE"
# Generate main layout
generate_layouts "$TPL_FILE" "$DEST_FILE" "$TMP_FILE"
# Generate numeric layout
generate_layouts "$NUM_TPL_FILE" "$NUM_DEST_FILE" "$NUM_TMP_FILE"