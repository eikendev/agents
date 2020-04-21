#!/usr/bin/env bash

set -o errexit
set -o errtrace

cd "$(dirname "${BASH_SOURCE[0]}")"

source config.env

function cleanup() {
	if [ -n "$DIRECTORY" ]; then
		printf "%s\n" "Removing temporary directory '$DIRECTORY'."
		rm -r "$DIRECTORY"
	fi
}

function error_exit() {
	printf "%s\n" 'An error occured!' >&2

	if [ -n "$GOTIFY_TOKEN" ]; then
		curl -q -s -S -L "https://$GOTIFY_HOSTNAME/message?token=$GOTIFY_TOKEN" \
			-F "title=$GOTIFY_TITLE" \
			-F "message=$GOTIFY_MESSAGE" \
			-F "priority=${GOTIFY_PRIORITY:-5}"
	fi

	cleanup
}

trap error_exit ERR

[ -n "$R_MASTER" ]
[ -n "$R_SLAVE" ]

export GIT_SSH_COMMAND='ssh -i sshkey'

printf "%s\n" 'Creating a new temporary directory.'
DIRECTORY="$(mktemp -d)"

printf "%s\n" "Cloning master repository from the master into '$DIRECTORY'."
git clone --mirror "$R_MASTER" "$DIRECTORY"

printf "%s\n" "Pushing '$DIRECTORY' to the slave repository."
git --git-dir "$DIRECTORY" push --prune --mirror "$R_SLAVE"

cleanup

printf "%s\n" 'Writing the time of last success.'
date > timestamp.txt
