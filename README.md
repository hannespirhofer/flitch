# Flitch

Quick-capture notes with an LLM-powered auto-filing pipeline — jot it, forget it, let AI organize it.

## Requirements

- `inotify-tools`
- `claude` CLI

## Setup

1. Clone flitch:
   ```
   git clone git@github.com:hannespirhofer/flitch.git
   cd flitch
   ```

2. Clone your docs repo (or an empty one) **anywhere separate from flitch** — e.g. `~/my-docs`.

3. Configure `.env`:
   - `FLITCH_NOTES_DIR` — absolute path to your cloned `flitch` directory
   - `FLITCH_REPO_DIR` — absolute path to your docs repo from step 2

4. Make the watcher executable:
   ```
   chmod u+x watcher.sh
   ```

5. Configure `watcher.service`:
   - Update `EnvironmentFile=` and `ExecStart=` to match your flitch path
   - `%h` = your home directory

6. Copy the service file:
   ```
   mkdir -p ~/.config/systemd/user
   cp watcher.service ~/.config/systemd/user/
   ```

6. Enable and start the service:
   ```
   systemctl --user enable watcher.service   # activates on next login
   systemctl --user start watcher.service    # activates now
   systemctl --user status watcher.service   # check it's running
   ```

   Optional check: log out and back in, then run `status` again — should already be active.

7. Add the quick-capture function to your shell config (Append the notes - as the cleaning of the file gets done by the watcher):
   ```
   nano ~/.bashrc
   ```
   ```sh
   note() { echo "$1" >> ~/the/path/to/flitch/flitchnotes.txt }
   ```
   ```
   source ~/.bashrc
   ```

## Usage

That's it — you're set up. Now just capture a note, from anywhere:

```
note "With the usage of Flitch (Link: git@github.com:hannespirhofer/flitch.git) I can now write quick and dirty notes and have them sorted and summarized in the background!"
```

Flitch picks it up, cleans it up, files it into your docs repo, and commits + pushes — no further action needed.

> **Attention:** some text editors save by deleting and recreating the file (atomic save) instead of writing directly to it. `inotifywait` won't catch that as a `modify` event, so flitch won't trigger. **Please test with the editor of your choice** before relying on it.

*Check the logs in your flitch directory (`watcher.log`, `ai.log`) to see what happened.*