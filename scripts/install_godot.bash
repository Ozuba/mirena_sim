#!/bin/bash


set -euo pipefail

# === Step 0: Ensure a single argument was given and it is a directory ===
if [ "$#" -ne 1 ]; then
  echo "Error: Exactly one argument is required."
  exit 1
fi

GODOT_EXE_DIR="$1"
exec >"${GODOT_EXE_DIR}/install_log.txt" 2>&1

if [ ! -d "$GODOT_EXE_DIR" ]; then
  echo "Error: '$GODOT_EXE_DIR' is not a directory."
  exit 1
fi

# === File and URL definitions ===
FILE1_NAME="Godot_v4.4-stable_linux.arm64"
FILE2_NAME="Godot_v4.4-stable_linux.x86_64"
ZIP1_NAME="${FILE1_NAME}.zip"
ZIP2_NAME="${FILE2_NAME}.zip"
URL1="https://github.com/godotengine/godot-builds/releases/download/4.4-stable/Godot_v4.4-stable_linux.arm64.zip"
URL2="https://github.com/godotengine/godot-builds/releases/download/4.4-stable/Godot_v4.4-stable_linux.x86_64.zip"

FILE1_PATH="$GODOT_EXE_DIR/$FILE1_NAME"
FILE2_PATH="$GODOT_EXE_DIR/$FILE2_NAME"
ZIP1_PATH="$GODOT_EXE_DIR/$ZIP1_NAME"
ZIP2_PATH="$GODOT_EXE_DIR/$ZIP2_NAME"

# === Step 1: Check if both files exist ===
if [ -f "$FILE1_PATH" ] && [ -f "$FILE2_PATH" ]; then
  echo "Both files already exist. No action needed."
  exit 0
fi

# === Step 2: Download the zip files ===
echo "Downloading missing files..."

if [ ! -f "$FILE1_PATH" ]; then
  curl -fSL "$URL1" -o "$ZIP1_PATH" || { echo "Download failed for $URL1"; exit 1; }
  unzip -q "$ZIP1_PATH" -d "$GODOT_EXE_DIR" || { echo "Extraction failed for $ZIP1_PATH"; exit 1; }
  rm -f "$ZIP1_PATH" || { echo "Failed to remove $ZIP1_PATH"; exit 1; }
fi

if [ ! -f "$FILE2_PATH" ]; then
  curl -fSL "$URL2" -o "$ZIP2_PATH" || { echo "Download failed for $URL2"; exit 1; }
  unzip -q "$ZIP2_PATH" -d "$GODOT_EXE_DIR" || { echo "Extraction failed for $ZIP2_PATH"; exit 1; }
  rm -f "$ZIP2_PATH" || { echo "Failed to remove $ZIP2_PATH"; exit 1; }
fi

# Final confirmation
if [ -f "$FILE1_PATH" ] && [ -f "$FILE2_PATH" ]; then
  echo "Download and extraction successful."
  exit 0
else
  echo "Files are still missing after extraction."
  exit 1
fi

