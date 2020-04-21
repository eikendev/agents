# About

This script is used to mirror a Git repository.
If you want to keep two repositories synchronized, it is recommended to use a [systemd](https://freedesktop.org/wiki/Software/systemd/) timer that calls this script periodically.
Note, however, that this script will not synchronize the repositories in a two-way sense: the mirror only knows a master, from which it will copy the state to the slave.

# Usage

The `config.env.sample` file acts as a base for your configuration.
Copy it as `config.env` in the directory of `main.sh`, and adapt it to your needs.
Specifically, you have to change the `R_MASTER` and `R_SLAVE` variables, which will be directly used by Git as links for the remotes of the mirror.

Additionally, you can set up notifications for [Gotify](https://gotify.net/).
The notifications will be sent when errors occur.

For authentication purposes, you can put a private SSH key named `sshkey` into the directory of the `main.sh` script.
Of course, you can also use authentication tokens in the URLs to the repositories.
