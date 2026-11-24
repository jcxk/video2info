---
name: minVid2slides
description: Extract presentation slides (searchable PDF) and the transcript from a YouTube video, playlist or local video file.
---
# minVid2slides

Use this when the user wants the slides or the transcript of a YouTube talk, lecture, playlist or a local video file.

1. Make sure it's installed: `minVid2slides --check` (if not: `curl -fsSL https://raw.githubusercontent.com/jcxk/minVid2slides/main/install.sh | bash`).
2. Run `minVid2slides "<url>"` or `minVid2slides <file.mp4>...` (local files: on-device transcript via yap on macOS or whisper.cpp on Linux). Useful options:
   - `--ocr-lang spa` (or `eng+spa`) for non-English slides
   - `--lang <code>` for a specific transcript language (default: the video's own language; local files: `en-US`)
   - `--crop right=25%` to cut off a fixed webcam corner
   - `--transcript-only` / `--no-transcript`, and `-d <dir>` for the output folder
3. Results land in `outputs/<timestamp>/` (or `-d`): one PDF and one `_transcript.txt` per video, plus `Combined_Slides.pdf`.
   Tell the user where they are.
