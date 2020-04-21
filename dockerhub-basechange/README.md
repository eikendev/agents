# About

This script is used to detect updates of base images on [Docker Hub](https://hub.docker.com/).
Since automatic updates on base image updates do not work for official images, one has to trigger the builds manually.
This script can be used to trigger a rebuild of the image when the base image updates.

# Usage

You have to change the `DOCKER_HUB_ORG` and `DOCKER_HUB_REPO` variables, which identify the repository you want to keep updated.
You can additionally set a tag with `DOCKER_HUB_TAG`, which defaults to `latest`.
Finally, the `DOCKER_HUB_TRIGGER` variable specifies the endpoint that will receive a HTTP POST when the trigger activates.

Additionally, you can set up notifications for [Gotify](https://gotify.net/).
The notifications will be sent when errors occur.
