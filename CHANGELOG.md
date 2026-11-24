# Changelog

All notable changes to this project are listed here. Versions follow [Semantic Versioning](https://semver.org/).

## [0.1.0] - 2026-11-24

First release.

### Added
- One bash script, `vid2slides`, that turns YouTube videos and playlists (or any site `yt-dlp` supports) into searchable slide PDFs and timestamped transcripts.
- Local video files: `vid2slides talk.mp4` or `vid2slides *.mp4`. Several files make one combined deck and transcript.
- On-device transcripts for local videos with [`yap`](https://github.com/finnvoor/yap) (macOS 26+, default `en-US`, `--lang` to change).
- Slide detection with `ffmpeg` SSIM (keeps the last frame of each slide, so bullet builds are complete), parallel `tesseract` OCR, and text-based removal of duplicates and revisited slides.
- Options: `--lang`, `--ocr-lang`, `--crop`, `--ssim`, `-j`, `-d`, `-o`, `--transcript-only`, `--no-transcript`, `--check`, `--version`.
- `curl | bash` installer that checks dependencies and prints the install command for brew, apt, dnf or pacman.

### Known limitations
- ⚠️ Local video transcripts are macOS only. On other systems, use `--no-transcript`.
- Tested on macOS only.

[0.1.0]: https://github.com/jcxk/vid2slides/releases/tag/v0.1.0
