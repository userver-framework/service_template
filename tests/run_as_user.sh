#!/usr/bin/env bash

# Exit on any error and treat unset variables as errors
set -euo pipefail

DIR_UID="$(stat -c '%u' .)"

if ! id -u user > /dev/null 2> /dev/null; then
    if [ "$DIR_UID" = "0" ]; then
        useradd --create-home --no-user-group user
    else
        useradd --create-home --no-user-group --uid $DIR_UID user
    fi
elif [ "$DIR_UID" != "0" ]; then
    usermod -u $DIR_UID user
fi

HOME=/home/user sudo -E -u user "$@"
