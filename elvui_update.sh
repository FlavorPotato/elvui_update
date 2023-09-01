#!/bin/bash

# Constants
CONFIG_DIR="$HOME/.config/elvui_update"
CONFIG_FILE="$CONFIG_DIR/elvui_update.config"
REPO_DIR="$HOME/.local/ElvUI"

# Function to update ElvUI repository
update_repo() {
  cd "$REPO_DIR" || { echo "Directory ElvUI not found."; exit 1; }
  git pull origin development
}

# Initialize Configuration Directory
mkdir -p "$CONFIG_DIR"

# Read or Create Configuration File
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  read -rp "Enter the compatdata ID: " COMPAT_ID
  read -rp "Enter the game version (classic or retail): " GAME_VERSION_INPUT

  # Transform the input into the correct format for the folder name
  GAME_VERSION="_${GAME_VERSION_INPUT}_"

  echo "COMPAT_ID=$COMPAT_ID" > "$CONFIG_FILE"
  echo "GAME_VERSION=$GAME_VERSION" >> "$CONFIG_FILE"
fi

# Define Target Directory
TARGET_DIR="$HOME/.steam/steam/steamapps/compatdata/$COMPAT_ID/pfx/drive_c/Program Files (x86)/World of Warcraft/$GAME_VERSION/Interface/AddOns/"

# Command Line Argument Handling
case $1 in
  -uninstall)
    rm -rf "$REPO_DIR"
    rm -f "$CONFIG_FILE"
    echo "ElvUI and config removed."
    exit 0
    ;;
  *)
    # Check for Existing Installation and Update
    if [ -d "$REPO_DIR" ] && [ -L "$TARGET_DIR/ElvUI" ]; then
      update_repo
    fi
    ;;
esac

# Clone ElvUI Repository if it doesn't exist
if [ ! -d "$REPO_DIR" ]; then
  git clone https://github.com/tukui-org/ElvUI.git "$REPO_DIR"
else
  echo "ElvUI directory already exists, skipping clone."
fi

# Navigate into ElvUI directory and Create Symbolic Links
cd "$REPO_DIR" || { echo "Directory ElvUI not found."; exit 1; }
ln -sf "$(pwd)/ElvUI" "$TARGET_DIR"
ln -sf "$(pwd)/ElvUI_Libraries" "$TARGET_DIR"
ln -sf "$(pwd)/ElvUI_Options" "$TARGET_DIR"
