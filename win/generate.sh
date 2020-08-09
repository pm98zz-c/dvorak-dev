#!/bin/sh

# Developer Dvorak layout.
#
# Author: Pascal Morin <pm98zz.c@gmail.com>
# Source: github

GIT_DIR=$(git rev-parse --show-toplevel)
cd "$GIT_DIR" || exit 1
GIT_DIR=$(pwd -P)
OWN_DIR="$GIT_DIR/win"

# Markers
DELIMITER='// MATRIX'
SRC_FILE="$GIT_DIR/matrix.csv"
# Main layout
TPL_FILE="$OWN_DIR/dvorak-dev.tpl.klc"
DEST_FILE="$OWN_DIR/dvorak-dev.klc"
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

pad(){
  STRING="$(printf %$((20 - ${#1}))s)""$1"
  printf "%s" "$STRING"
}

# Convert char to output.
# @param $1 char
# @param $2 int
convert_to_code(){
  STRING=""
  case $1 in
    'NoSymbol')
      STRING="-1"
    ;;
    [[:alnum:]])
      STRING="$1"
    ;;
    #@todo Something is wrong with the hyphen
    'hyphen')
      STRING="2010"
    ;;
    'dead'*)
      STRING="-1"
    ;;
    'comma')
      STRING="002C"
    ;;
    'Space')
      STRING="0020"
    ;;
    'NoBreakSpace')
      STRING="00A0"
    ;;
    'NarrowNoBreakSpace')
      STRING="202F"
    ;;
    'BackSpace')
      STRING="-1"
    ;;
    *)
      STRING="$(printf "%s" "$1" | iconv -f utf8 -t utf32be |  xxd -p | sed -r 's/^0+/0x/' | xargs printf '%04X\n')"
    ;;
  esac
  pad "$STRING"
}

# Parse a single line.
# @param $1 string to parse.
# @param $2 int level to start with.
# @param $3 string path to output file.
parse_line(){
  KEY=$(echo "$1" | cut -d ',' -f11 )
  if [ -z "$KEY" ] || [ "$KEY" = "NULL" ]; then
    return
  fi
  SC=$(echo "$KEY" | cut -d '/' -f1 )
  VK=$(echo "$KEY" | cut -d '/' -f2 )
  OUTPUT=""
  COUNT=$2
  LEVEL=1
  while [ "$COUNT" -lt  5 ]; do
    CHAR=$(echo "$1" | cut -d ',' -f"$COUNT" )
    CHAR="$(convert_to_code "$CHAR" "$LEVEL")"
    OUTPUT="$OUTPUT""$CHAR"
    COUNT=$((COUNT + 1))
    LEVEL=$((LEVEL + 1))
  done
  echo "$SC $(pad "$VK") $(pad SGCap) $OUTPUT" >> "$3"
  OUTPUT=""
  while [ "$COUNT" -lt  7 ]; do
    CHAR=$(echo "$1" | cut -d ',' -f"$COUNT" )
    CHAR="$(convert_to_code "$CHAR" "$LEVEL")"
    OUTPUT="$OUTPUT""$CHAR"
    COUNT=$((COUNT + 1))
    LEVEL=$((LEVEL + 1))
  done
  echo "-1 -1 0 $OUTPUT" >> "$3"
}

# Generate the keys definition from CSV.
generate_keys(){
  while read -r LINE; do
    # Main layout.
    parse_line "$LINE" 1 "$TMP_FILE"
    # Numeric layout.
    #parse_line "$LINE" 5 "$NUM_TMP_FILE"
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
  # Convert line ending.
  unix2dos "$2"
}

# Remove target files
cleanup
# Generate key definitions
generate_keys
# Generate main layout
generate_layouts "$TPL_FILE" "$DEST_FILE" "$TMP_FILE"
# Generate numeric layout
# generate_layouts "$NUM_TPL_FILE" "$NUM_DEST_FILE" "$NUM_TMP_FILE"