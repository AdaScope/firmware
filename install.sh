#!/bin/bash

# Make sure the script is not run as root
if [ "$EUID" -eq 0 ]; then
  echo "This script should not be run as root. Please run it without sudo."
  exit 1
fi

# Make sure Alire is installed
if ! which alr > /dev/null 2>&1; then
    echo "alr command not found. Make sure Alire is installed and in your PATH."
    exit 1
fi

# Get the target directory
if [ -n "$1" ]; then
    target_directory="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
else
    target_directory="$(pwd)/"
fi

# Check if there are any .gpr files in the current directory
if ! ls "$target_directory"/*.gpr >/dev/null 2>&1; then
   echo "No .gpr files found in $target_directory"
   echo "Make sure you specify a directory in the arguments or leave blank for current directory."
   exit 1
fi
# Check if the project has been built before
if [ ! -d "$target_directory/alire/cache/dependencies/gtkada_23.0.0_bac4d634/src/" ] >/dev/null 2>&1; then
   echo "No previous build detected. Building with defaults values now..."
   cd "$target_directory"
   alr -n build >/dev/null 2>&1
   echo -e "Done!\n"
fi
echo -e "Done!\n"

echo "Building project..."
cd "$target_directory"
alr build
echo "Done!"