#!/usr/bin/env bash

function set_shell_options() {
	set -o errexit
	set -o errtrace
}

set_shell_options

cd "$(dirname "${BASH_SOURCE[0]}")"

source config.env

function error_exit() {
	printf "%s\n" 'An error occured!' >&2

	if [ -n "$GOTIFY_TOKEN" ]; then
		curl -q -s -S -L "https://$GOTIFY_HOSTNAME/message?token=$GOTIFY_TOKEN" \
			-F "title=$GOTIFY_TITLE" \
			-F "message=$GOTIFY_MESSAGE" \
			-F "priority=${GOTIFY_PRIORITY:-5}"
	fi

	exit 1
}

function enable_error_handling() {
	set_shell_options
	trap error_exit ERR
}

function unset_shell_options() {
	set +o errexit
	set +o errtrace
}

function disable_error_handling() {
	unset_shell_options
	trap - ERR
}

enable_error_handling

function handle_change() {
	printf "%s\n" 'Writing repository state.'
	printf "%s" "$VERSIONS" > state.txt

	printf "%s\n" 'Sending HTTP POST request to trigger endpoint.'
	curl -q -s -S -L -X POST "$DOCKER_HUB_TRIGGER"
}

function compare_state() {
	disable_error_handling
	printf "%s" "$VERSIONS" | diff state.txt - > /dev/null
	EXITCODE="$?"
	enable_error_handling

	case "$EXITCODE" in
    	'0')
			printf "%s\n" 'State did not change.'
        	;;
    	'1')
			printf "%s\n" 'State did change.'
			handle_change
        	;;
    	*)
			printf "%s\n" 'Error while calculating state differences.'
    		false
        	;;
	esac
}

[ -n "$DOCKER_HUB_ORG" ]
[ -n "$DOCKER_HUB_REPO" ]

DOCKER_HUB_TAG="${DOCKER_HUB_TAG:-latest}"

AUTH_DOMAIN='auth.docker.io'
AUTH_SERVICE='registry.docker.io'
AUTH_SCOPE="repository:$DOCKER_HUB_ORG/$DOCKER_HUB_REPO:pull"

API_DOMAIN='registry-1.docker.io'

printf "%s\n" 'Requesting authentication bearer.'
TOKEN="$(curl -q -s -S -L "https://$AUTH_DOMAIN/token?service=$AUTH_SERVICE&scope=$AUTH_SCOPE" | jq -r '.token')"

printf "%s\n" 'Requesting repository manifest.'
VERSIONS="$(curl -q -s -S -L -H "Authorization: Bearer $TOKEN" "https://$API_DOMAIN/v2/$DOCKER_HUB_ORG/$DOCKER_HUB_REPO/manifests/$DOCKER_HUB_TAG" | jq -c '.fsLayers')"

if [ -f state.txt ]; then
	compare_state
else
	printf "%s\n" 'State is empty.'
	handle_change
fi

printf "%s\n" 'Writing the time of last success.'
date > timestamp.txt
