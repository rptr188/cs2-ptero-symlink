#!/bin/bash

# Prompt user for Pterodactyl UUID
read -p "Enter UUID: " UUID
read -p "Enter base folder: " BASE
# Define paths
TARGET_FOLDER="/var/lib/pterodactyl/volumes/$UUID"/
BASE_FOLDER="$BASE"
GAME_BIN_FOLDER="/game/bin"

# Check if UUID folder exists
if [ ! -d "$TARGET_FOLDER" ]; then
  echo "Error: Target folder does not exist."
  exit 1
fi

# Create symlinks for .vpk files from the base folder
find "$BASE_FOLDER" -type f -name "*.vpk" -exec ln -s {} "$TARGET_FOLDER" \;

# Copy contents of /game/bin/ to the target folder
cp -r "$GAME_BIN_FOLDER"/* "$TARGET_FOLDER"

# Copy files without .vpk extension from the base folder to the target folder
find "$BASE_FOLDER" -type f ! -name "*.vpk" -exec cp {} "$TARGET_FOLDER" \;

echo "Clone has been completed"
