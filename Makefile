SHELL_FILES = $(shell find . -type f -name '*.sh')

.PHONY: all
all: lint

.PHONY: lint
lint:
	shellcheck ${SHELL_FILES}
