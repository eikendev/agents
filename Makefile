SHELL_FILES = $(shell find . -type f -name '*.sh')

.PHONY: all
all: check

.PHONY: check
check:
	shellcheck ${SHELL_FILES}
