#!/bin/bash

# Ask for a commit message; fall back to the date if left empty
read -r -p "Commit message (press Enter for date): " msg
if [ -z "$msg" ]; then
   msg="$(date +'%Y-%m-%d %H:%M')"
fi

# Check if the current directory is a git repository
if git rev-parse --is-inside-work-tree &> /dev/null; then
   # If in a git repo, print the current directory and run as usual
   echo "Using directory: $(pwd)"
   git status && git add . && git commit -m "$msg" && git push
else
   # If not in a git repo, navigate to ~/obsidian and run the commands there
   cd ~/obsidian || exit
   echo "Using directory: $(pwd)"
   git status && git add . && git commit -m "$msg" && git push
fi
