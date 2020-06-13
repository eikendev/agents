SHELL_FILES = $(shell find . -type f -name '*.sh')

.PHONY: check
check:
	shellcheck ${SHELL_FILES}
