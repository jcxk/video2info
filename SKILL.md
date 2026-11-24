---
name: video2info
description: Turn a YouTube video, playlist or local video file into Markdown notes (slides with OCR text, each with the transcript said while it was shown), or a searchable slide PDF / plain-text transcript.
---
# video2info

Use this when the user wants notes, the slides or the transcript of a YouTube talk, lecture, playlist or a local video file.

1. Make sure it's installed: `video2info --check` (if not: `curl -fsSL https://raw.githubusercontent.com/jcxk/video2info/main/install.sh | bash`).
2. Run `video2info "<url>"` or `video2info <file.mp4>...` (local files: on-device transcript via yap on macOS or whisper.cpp on Linux). Useful options:
   - `-f md,pdf,txt` to choose outputs (default `md`)
   - `--ocr-lang spa` (or `eng+spa`) for non-English slides
   - `--lang <code>` for a specific transcript language (default: the video's own language; local files: `en-US`)
   - `--crop right=25%` to cut off a fixed webcam corner
   - `--transcript-only` / `--no-transcript`, and `-d <dir>` for the output folder
3. Results land in `outputs/<timestamp>/` (or `-d`): `NN_Title.md` (+ `NN_Title_assets/`) per video, `.pdf`/`.txt` if asked, and `Combined.*` for several videos.
   Tell the user where they are.
