PREFIX ?= $(HOME)/.local

.PHONY: install uninstall check

install:                ## install this checkout's bin/vid2slides (same steps as the curl installer)
	@PREFIX=$(PREFIX) VID2SLIDES_SRC=file://$(CURDIR)/bin/vid2slides ./install.sh

uninstall:
	rm -f $(PREFIX)/bin/vid2slides

check:                  ## syntax check (and shellcheck, if installed)
	bash -n bin/vid2slides install.sh
	@command -v shellcheck >/dev/null && shellcheck bin/vid2slides install.sh || echo "(shellcheck not installed, skipped)"
