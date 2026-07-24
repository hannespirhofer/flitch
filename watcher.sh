#!/bin/sh
# watcher.sh

. "$(dirname "$0")/config.sh"

log() {
  printf "%s - %s\n" "$(date)" "$1" >> "$FLITCH_WATCHER_LOG"
}
ailog() {
  printf "%s - %s\n" "$(date)" "$1" >> "$FLITCH_AI_LOG"
}

# STOP execution if inotify is missing
if ! command -v inotifywait > /dev/null 2>&1; then
  echo "Error: inotifywait not found. Install with sudo apt install inotify-tools"
  exit 1
fi

# STOP execution if folder is not set
if ! cd "$FLITCH_NOTES_DIR"; then
  echo "Error: $FLITCH_NOTES_DIR does not exist"
  exit 1
fi

# STOP execution if repo is not a repo
if ! git -C "$FLITCH_DOCS_REPO_DIR" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "Error: $FLITCH_DOCS_REPO_DIR is not a git repo."
  exit 1
fi

log "Watcher started"

# watch the file
while inotifywait -e modify,create,delete "$FLITCH_NOTES_FILE"; do
  if [ ! -s "$FLITCH_NOTES_FILE" ]; then
    log "Saved but no content. No further processing"
    continue
  fi

  log "Change detected. Creating summary now."

  RESULT=$(claude -p \
    "Read $FLITCH_NOTES_FILE. These are raw one-line notes from me.
    First check $FLITCH_STRUCTURE_FILE to see which categories and subpages 
    already exist — use it to quickly find where each note belongs instead of re-scanning all files. 
    If not exist. Create it.
    For each note: clean up the wording, then file it into the matching subpage 
    under $FLITCH_DOCS_REPO_DIR (reuse existing categories/pages where they fit, don't create 
    new subfolders without reason). Keep the structure simple, few main categories, easy to scan.
    No prose, no long explanations — short, bullet-style entries like I wrote them, 
    just cleaned up and filed correctly.
    If a note doesn't fit any existing page, create the new page, add it to $FLITCH_STRUCTURE_FILE, 
    AND add a link to it in $FLITCH_DOCS_REPO_DIR/index.md under the correct category section. 
    A new page is only considered done once it's reachable by clicking through from index.md — 
    verify this before finishing.
    After filing all notes, do a final check: read $FLITCH_DOCS_REPO_DIR/index.md and $FLITCH_STRUCTURE_FILE, confirm every 
    subpage in $FLITCH_DOCS_REPO_DIR is linked from $FLITCH_DOCS_REPO_DIR/index.md. If any page is missing, add it." \
  --allowedTools "Read,Edit,Write" < /dev/null)


  ailog "$RESULT"

  # clean the notes file
  > "$FLITCH_NOTES_FILE"

  cd "$FLITCH_DOCS_REPO_DIR"

  # if no repo changes we exit and dont need to push
  if git diff --quiet && git diff --cached --quiet; then
    log "No changes to commit, skipping commit and push."
    exit
  fi

  git add -A
  git commit -m "flitch: autoupdate docs" > /dev/null 2>&1
  git push > /dev/null 2>&1

  log "Notes summarized and committed"
done