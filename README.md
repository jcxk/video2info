# videoToSlides

YouTube talks, playlists or local videos → searchable slide PDFs + timestamped transcripts. One bash script.

```mermaid
flowchart LR
    U([YouTube URL]) --> C[yt-dlp + jq<br/>captions → transcript]
    U --> S[yt-dlp ⇢ ffmpeg<br/>1 frame / 2 s]
    F([local videos]) --> Y[yap<br/>on-device speech → transcript]
    F --> S
    S --> X[ffmpeg SSIM<br/>one frame per slide]
    X --> O[tesseract<br/>searchable PDF]
    O --> W[awk<br/>drop duplicates]
    W --> P[pdfunite<br/>per video + combined]
```

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/jcxk/videoToSlides/main/install.sh | bash
```
Installs to `~/.local/bin` (change with `PREFIX=…`) and lists any missing tools with the command to install them.
Needs `yt-dlp jq ffmpeg tesseract poppler`, plus `yap` for local transcripts. Check any time with `videoToSlides --check`.

> ⚠️ **macOS only for local transcripts:** they use [`yap`](https://github.com/finnvoor/yap) (`brew install yap`, macOS 26+).
> Elsewhere, add `--no-transcript`. Tested on macOS only.

## Pending

- ⚠️ Local video transcripts on Linux and Windows (WSL): a cross-platform speech-to-text engine in place of `yap`, e.g. [whisper.cpp](https://github.com/ggml-org/whisper.cpp).

## Usage

```bash
videoToSlides "https://youtu.be/VIDEO_ID"                    # YouTube video or playlist
videoToSlides talk.mp4                                       # local file
videoToSlides ~/Movies/*.mp4 --lang es-ES --ocr-lang spa     # several files → one combined deck
```

| Option | Description |
|---|---|
| `-d DIR` | Output folder (default `./outputs/<timestamp>`) |
| `-o NAME.pdf` | Combined PDF name (default `Combined_Slides.pdf`) |
| `--lang CODE` | Transcript language (YouTube: the video's own; local: `en-US`) |
| `--ocr-lang LANGS` | Tesseract languages, e.g. `eng+spa` (default `eng`; more: `brew install tesseract-lang`) |
| `--crop SIDES` | Cut edges off frames, e.g. `right=25%` for a webcam |
| `--ssim T` | Slide-change threshold 0–1 (default `0.9`; higher = more slides) |
| `-j N` | Parallel OCR jobs (default: CPU cores) |
| `--transcript-only` / `--no-transcript` | Only the transcript / skip it |

Output: `NN_Title.pdf` and `NN_Title_transcript.txt` per video, plus `Combined_Slides.pdf` (and `Combined_Transcripts.txt` for several videos).

## Credits

Inspired by [youtube-slide-extractor-ai](https://github.com/vkr1729/youtube-slide-extractor-ai) by Kedarnath Reddy.

License: [MIT](LICENSE)
