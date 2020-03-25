#! /bin/sh
set -e

# Add the SSH key
echo "Adding the SSH key"
eval $(ssh-agent -s)
echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add - > /dev/null

# Send all of the secrets to the server.
echo "Sending secrets to the server"
echo "$SECRETS_PASSWORD" > .secrets_password_file
./secrets_file_manager.sh extract
rsync -vr --delete-after secrets/ root@deploy.sumnerevans.com:/etc/nixos/secrets

echo "SSH into the server and switch to this commit"
ssh root@deploy.sumnerevans.com "cd /etc/nixos && git fetch && git switch $CI_COMMIT_SHA"

echo "Running nixos-rebuild build..."
ssh root@deploy.sumnerevans.com "nixos-rebuild build"

echo "Switch to the new generation..."
ssh root@deploy.sumnerevans.com "nixos-rebuild switch"
