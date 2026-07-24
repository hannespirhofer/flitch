#!/bin/sh
# config.sh

# Path to the cloned flitch folder
FLITCH_NOTES_DIR="${FLITCH_NOTES_DIR:-$HOME/flitch}"

#the repo path
FLITCH_DOCS_REPO_DIR="${FLITCH_REPO_DIR:-$HOME/my-notes}"

# enough to do the job
FLITCH_ANTHROPIC_MODEL="${ANTHROPIC_MODEL:-claude-haiku-4-5}"

# the file where you write the notes and which gets monitored
FLITCH_NOTES_FILE="$FLITCH_NOTES_DIR/flitchnotes.txt"

# STRUCTURE file used for the LLM to not need to recheck the docs each run
FLITCH_STRUCTURE_FILE="$FLITCH_NOTES_DIR/STRUCTURE.md"

# some logging
FLITCH_WATCHER_LOG="$FLITCH_NOTES_DIR/watcher.log"
FLITCH_AI_LOG="$FLITCH_NOTES_DIR/ai.log"