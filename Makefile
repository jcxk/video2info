PREFIX ?= $(HOME)/.local
.DEFAULT_GOAL := test

.PHONY: test check install uninstall

test: check             ## critical offline tests (plain `make` runs this)
	bash tests/run.sh

check:                  ## syntax check (and shellcheck, if installed)
	bash -n bin/video2info install.sh tests/run.sh
	@if command -v shellcheck >/dev/null; then shellcheck -S warning bin/video2info install.sh tests/run.sh; \
	else echo "(shellcheck not installed, skipped)"; fi

install:                ## install this checkout's bin/video2info (same steps as the curl installer)
	@PREFIX=$(PREFIX) VIDEO2INFO_SRC=file://$(CURDIR)/bin/video2info ./install.sh

uninstall:
	rm -f $(PREFIX)/bin/video2info
