PREFIX ?= $(HOME)/.local

.PHONY: install uninstall check

install:                ## install this checkout's bin/videoToSlides (same steps as the curl installer)
	@PREFIX=$(PREFIX) VIDEOTOSLIDES_SRC=file://$(CURDIR)/bin/videoToSlides ./install.sh

uninstall:
	rm -f $(PREFIX)/bin/videoToSlides

check:                  ## syntax check (and shellcheck, if installed)
	bash -n bin/videoToSlides install.sh
	@command -v shellcheck >/dev/null && shellcheck bin/videoToSlides install.sh || echo "(shellcheck not installed, skipped)"
