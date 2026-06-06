#!/bin/bash

# Stage everything, commit with a timestamp message, and push.
# In a git repo: operates on the current directory.
# Outside a repo: falls back to ~/obsidian.

if git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Using directory: $(pwd)"
    git status && git add . && git commit -m "$(date +'%Y-%m-%d %H:%M')" && git push
else
    cd ~/obsidian || exit
    echo "Using directory: $(pwd)"
    git status && git add . && git commit -m "$(date +'%Y-%m-%d %H:%M')" && git push
fi
