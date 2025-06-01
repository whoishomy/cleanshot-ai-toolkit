#!/bin/bash

# Check if a component name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <component-name>"
  exit 1
fi

COMPONENT_NAME="$1"
INBOX_DIR="$HOME/Desktop/CleanShot-Capture"

# Find the most recent screenshot
LAST_FILE=$(ls -t "$INBOX_DIR"/*.png | head -n 1)

if [ -z "$LAST_FILE" ]; then
  echo "No screenshots found in $INBOX_DIR"
  exit 1
fi

# Extract the base name and directory
BASE_NAME=$(basename "$LAST_FILE")
DIR_NAME=$(dirname "$LAST_FILE")

# Create the new file name with the component name
NEW_NAME="$(date +%d-%B-%Y)-[$COMPONENT_NAME]-${BASE_NAME}"

# Rename the file
mv "$LAST_FILE" "$DIR_NAME/$NEW_NAME"

echo "Renamed $BASE_NAME to $NEW_NAME" 