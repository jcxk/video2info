# Changelog

All notable changes to this project are listed here. Versions follow [Semantic Versioning](https://semver.org/).

## [0.2.0] - 2026-11-24

### Changed
- Renamed `vid2slides` to `minVid2slides` (command, repository, and `MINVID2SLIDES_*` environment variables), to avoid confusion with the unrelated `patrickmineault/vid2slides`.

### Added
- Linux support, tested on Ubuntu 26.10 (x86_64). Every dependency installs with apt.
- Local video transcripts with [whisper.cpp](https://github.com/ggml-org/whisper.cpp) (`whisper-cli`) wherever `yap` isn't available. The model downloads once to `~/.cache/minVid2slides`; override it with `MINVID2SLIDES_WHISPER_MODEL`, and choose the engine with `MINVID2SLIDES_STT=yap|whisper`.
- An "At a glance" table in the README: category, input, output, processing, editability, platforms.
- `--check` and the install hints now cover the transcript engine, including the apt package `whisper.cpp`.

### Removed
- The "macOS only" restriction on local video transcripts.

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

[0.2.0]: https://github.com/jcxk/minVid2slides/releases/tag/v0.2.0
[0.1.0]: https://github.com/jcxk/minVid2slides/releases/tag/v0.1.0
