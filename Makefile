PREFIX ?= $(HOME)/.local
.DEFAULT_GOAL := test

.PHONY: test check install uninstall

test: check             ## critical offline tests (plain `make` runs this)
	bash tests/run.sh

check:                  ## syntax check (and shellcheck, if installed)
	bash -n bin/minVid2slides install.sh tests/run.sh
	@command -v shellcheck >/dev/null && shellcheck -S warning bin/minVid2slides install.sh tests/run.sh || echo "(shellcheck not installed, skipped)"

install:                ## install this checkout's bin/minVid2slides (same steps as the curl installer)
	@PREFIX=$(PREFIX) MINVID2SLIDES_SRC=file://$(CURDIR)/bin/minVid2slides ./install.sh

uninstall:
	rm -f $(PREFIX)/bin/minVid2slides
