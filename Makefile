PREFIX ?= $(HOME)/.local

.PHONY: install uninstall check

install:                ## install this checkout's bin/minVid2slides (same steps as the curl installer)
	@PREFIX=$(PREFIX) MINVID2SLIDES_SRC=file://$(CURDIR)/bin/minVid2slides ./install.sh

uninstall:
	rm -f $(PREFIX)/bin/minVid2slides

check:                  ## syntax check (and shellcheck, if installed)
	bash -n bin/minVid2slides install.sh
	@command -v shellcheck >/dev/null && shellcheck bin/minVid2slides install.sh || echo "(shellcheck not installed, skipped)"
