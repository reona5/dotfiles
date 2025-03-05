.PHONY: all init link defaults brew nothing

PASSWORD := $(shell read -s -p "Password: " pass; echo $$pass)

all: init link defaults brew nothing
	@echo all: $(PASSWORD)

init:
	.bin/init.sh

link:
	.bin/link.sh

defaults:
	.bin/defaults.sh

brew:
	.bin/brew.sh

nothing:
	@echo nothing: $(PASSWORD)
