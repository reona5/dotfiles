.PHONY: all
all: init link defaults brew mas

.PHONY: init
init:
	.bin/init.sh

.PHONY: link
link:
	.bin/link.sh

.PHONY: defaults
defaults:
	.bin/defaults.sh

.PHONY: brew
brew:
	.bin/brew.sh
