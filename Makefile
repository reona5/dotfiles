.PHONY: all init link defaults brew

all: init link defaults brew

init:
	.bin/init.sh

link:
	.bin/link.sh

defaults:
	.bin/defaults.sh

brew:
	.bin/brew.sh
