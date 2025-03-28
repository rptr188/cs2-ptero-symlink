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

# Create the same folder structure as the base folder
echo "Mirroring folder structure from $BASE_FOLDER to $TARGET_FOLDER..."
find "$BASE_FOLDER" -type d -exec bash -c 'mkdir -p "$0/${1#$2}"' "$TARGET_FOLDER" "{}" "$BASE_FOLDER" \;

# Recursively copy files except those with .vpk extension
echo "Copying files (excluding .vpk) from $BASE_FOLDER to $TARGET_FOLDER..."
find "$BASE_FOLDER" -type f ! -name "*.vpk" -exec bash -c 'cp "$1" "$0/${1#$2}"' "$TARGET_FOLDER" "{}" "$BASE_FOLDER" \;

# Create symlinks for .vpk files from the base folder to the target folder
echo "Creating symlinks for .vpk files..."
find "$BASE_FOLDER" -type f -name "*.vpk" -exec bash -c 'ln -s "$1" "$0/${1#$2}"' "$TARGET_FOLDER" "{}" "$BASE_FOLDER" \;

echo "Operation completed successfully!"
