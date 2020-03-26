#! /bin/sh
set -e

# Dependencies
apk add openssh rsync openssl

# Known Hosts
mkdir -p ${HOME}/.ssh
chmod 700 ${HOME}/.ssh
echo "$SSH_KNOWN_HOSTS" > ${HOME}/.ssh/known_hosts
chmod 644 ${HOME}/.ssh/known_hosts