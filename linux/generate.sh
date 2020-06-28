#!/bin/sh

# Developer Dvorak layout.
#
# Author: Pascal Morin <pm98zz.c@gmail.com>
# Source: github

GIT_DIR=$(git rev-parse --show-toplevel)
cd "$GIT_DIR" || exit 1
GIT_DIR=$(pwd -P)
OWN_DIR="$GIT_DIR/linux"

# Markers
DELIMITER='/////////////////////////////// MATRIX'
SRC_FILE="$GIT_DIR/matrix.csv"
# Main layout
TPL_FILE="$OWN_DIR/dvorak-dev.tpl"
DEST_FILE="$OWN_DIR/dvorak-dev"
TMP_FILE="/tmp/dvorak-dev.tmp"
# Numeric layout
NUM_TPL_FILE="$OWN_DIR/dvorak-num-dev.tpl"
NUM_DEST_FILE="$OWN_DIR/dvorak-num-dev"
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
# @param $1 char
# @param $2 int
convert_to_code(){
  STRING=""
  PREFIX=" "
  if [ "$2" -gt 1 ]; then
    PREFIX=","
  fi
  case $1 in
    'NoSymbol')
      STRING=" "
      PREFIX=" "
    ;;
    [[:alnum:]])
      STRING="$1"
    ;;
    #@todo Something is wrong with the hyphen
    'hyphen')
      STRING="U2010"
    ;;
    'dead'*)
      STRING="$1"
    ;;
    'comma')
      STRING="$1"
    ;;
    'Space')
      STRING="space"
    ;;
    'NoBreakSpace')
      STRING="U00A0"
    ;;
    'NarrowNoBreakSpace')
      STRING="U202F"
    ;;
    'BackSpace')
      STRING="BackSpace"
    ;;
    *)
      STRING="$(printf "%s" "$1" | iconv -f utf8 -t utf32be |  xxd -p | sed -r 's/^0+/0x/' | xargs printf 'U%04X\n')"
    ;;
  esac
  STRING="$PREFIX""$(printf %$((20 - ${#STRING}))s)""$STRING"
  printf "%s" "$STRING"
}

# Parse a single line.
# @param $1 string to parse.
# @param $2 int level to start with.
# @param $3 string path to output file.
parse_line(){
  KEY=$(echo "$1" | cut -d ',' -f9 )
  OUTPUT=""
  COUNT=$2
  LEVEL=1
  while [ "$COUNT" -lt  7 ]; do
    CHAR=$(echo "$1" | cut -d ',' -f"$COUNT" )
    CHAR="$(convert_to_code "$CHAR" "$LEVEL")"
    OUTPUT="$OUTPUT""$CHAR"
    COUNT=$((COUNT + 1))
    LEVEL=$((LEVEL + 1))
  done
  echo "    key <$KEY> {[$OUTPUT           ]};" >> "$3"
}

# Generate the keys definition from CSV.
generate_keys(){
  while read -r LINE; do
    # Main layout.
    parse_line "$LINE" 1 "$TMP_FILE"
    # Numeric layout.
    parse_line "$LINE" 5 "$NUM_TMP_FILE"
  done < "$SRC_FILE"
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
generate_keys
# Generate main layout
generate_layouts "$TPL_FILE" "$DEST_FILE" "$TMP_FILE"
# Generate numeric layout
generate_layouts "$NUM_TPL_FILE" "$NUM_DEST_FILE" "$NUM_TMP_FILE"