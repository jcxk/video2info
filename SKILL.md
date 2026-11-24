---
name: yt-slides
description: Extract presentation slides (searchable PDF) and the transcript from a YouTube video or playlist.
---
# yt-slides

Use this when the user wants the slides or the transcript of a YouTube talk, lecture or playlist.

1. Make sure it's installed: `yt-slides --check` (if not: `curl -fsSL https://raw.githubusercontent.com/jcxk/yt-slides/main/install.sh | bash`).
2. Run `yt-slides "<url>"`. Useful options:
   - `--ocr-lang spa` (or `eng+spa`) for non-English slides
   - `--lang <code>` for a specific transcript language (default: the video's own language)
   - `--crop right=25%` to cut off a fixed webcam corner
   - `--transcript-only` / `--no-transcript`, and `-d <dir>` for the output folder
3. Results land in `outputs/<timestamp>/` (or `-d`): one PDF and one `_transcript.txt` per video, plus `Combined_Slides.pdf`.
   Tell the user where they are.
