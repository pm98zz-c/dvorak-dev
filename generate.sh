#!/bin/sh

# Developer Dvorak layout.
#
# Author: Pascal Morin <pm98zz.c@gmail.com>
# Source: github

OWN_DIR=$(dirname "$0")
cd "$OWN_DIR" || exit 1
OWN_DIR=$(pwd -P)

# Markers
DELIMITER='/////////////////////////////// MATRIX'
SRC_FILE="$OWN_DIR/matrix.csv"
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

# Generate the keys definition from CSV.
generate_keys(){
  while read -r LINE; do
  KEY=$(echo "$LINE" | cut -d ',' -f1 )
  LEVEL_1=$(echo "$LINE" | cut -d ',' -f2 )
  LEVEL_1_TABS=$(printf %$((20 - ${#LEVEL_1}))s)
  LEVEL_2=$(echo "$LINE" | cut -d ',' -f3 )
  LEVEL_2_TABS=$(printf %$((20 - ${#LEVEL_2}))s)
  LEVEL_3=$(echo "$LINE" | cut -d ',' -f4 )
  LEVEL_3_TABS=$(printf %$((20 - ${#LEVEL_3}))s)
  LEVEL_4=$(echo "$LINE" | cut -d ',' -f5 )
  LEVEL_4_TABS=$(printf %$((20 - ${#LEVEL_4}))s)
  LEVEL_5=$(echo "$LINE" | cut -d ',' -f6 )
  LEVEL_5_TABS=$(printf %$((20 - ${#LEVEL_5}))s)
  LEVEL_6=$(echo "$LINE" | cut -d ',' -f7 )
  LEVEL_6_TABS=$(printf %$((20 - ${#LEVEL_6}))s)
  # Main layout.
  echo "    key <$KEY> {[                $LEVEL_1, $LEVEL_1_TABS $LEVEL_2, $LEVEL_2_TABS $LEVEL_3, $LEVEL_3_TABS $LEVEL_4, $LEVEL_4_TABS $LEVEL_5, $LEVEL_5_TABS $LEVEL_6 $LEVEL_6_TABS]};" >> "$TMP_FILE"
  # Numeric layout.
  echo "    key <$KEY> {[                $LEVEL_5, $LEVEL_5_TABS $LEVEL_6 $LEVEL_6_TABS]};" >> "$NUM_TMP_FILE"
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