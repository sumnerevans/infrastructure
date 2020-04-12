#! /bin/sh
set -e

# Add the SSH key
echo "Adding the SSH key"
eval $(ssh-agent -s)
echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add - > /dev/null

# Send all of the secrets to the server.
echo "Sending secrets to the server"
echo "============================="
echo "$SECRETS_PASSWORD" > .secrets_password_file
./secrets_file_manager.sh extract
rsync -vr --delete-after secrets/ root@deploy.sumnerevans.com:/etc/nixos/secrets
rm -rf .secrets_password_file secrets

echo "SSH into the server and switch to this commit"
echo "============================================="
ssh root@deploy.sumnerevans.com "cd /etc/nixos && git fetch && git reset --hard $CI_COMMIT_SHA"

echo "Running nixos-rebuild build..."
echo "=============================="
ssh root@deploy.sumnerevans.com "nixos-rebuild build --show-trace"

echo "Switch to the new generation..."
echo "==============================="
ssh root@deploy.sumnerevans.com "nixos-rebuild switch"
