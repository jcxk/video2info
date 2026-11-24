PREFIX ?= $(HOME)/.local

.PHONY: install uninstall check

install:                ## install this checkout's bin/yt-slides (same steps as the curl installer)
	@PREFIX=$(PREFIX) YT_SLIDES_SRC=file://$(CURDIR)/bin/yt-slides ./install.sh

uninstall:
	rm -f $(PREFIX)/bin/yt-slides

check:                  ## syntax check (and shellcheck, if installed)
	bash -n bin/yt-slides install.sh
	@command -v shellcheck >/dev/null && shellcheck bin/yt-slides install.sh || echo "(shellcheck not installed, skipped)"
