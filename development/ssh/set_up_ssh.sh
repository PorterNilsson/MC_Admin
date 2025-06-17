#!/bin/sh
set -e

KEY_NAME="mc_admin_dev"
PRESEED_FILE="../vm/ipxe/http/preseed.cfg"

# Remove old key if it exists
rm -f "$KEY_NAME"
rm -f "${KEY_NAME}.pub"

# Recreate SSH key
ssh-keygen -f "$KEY_NAME" -N "" -q

# Send the key
PUBKEY=$(cat mc_admin_dev.pub)

# Escape the public key for safe use in sed
ESCAPED_KEY=$(printf "%s" "$PUBKEY" | sed "s/'/'\\\\''/g")

# Use sed to replace the line in-place
sed -i '' "s|in-target sh -c \"echo '' > /root/.ssh/authorized_keys\"; \\\\|in-target sh -c \"echo '$ESCAPED_KEY' > /root/.ssh/authorized_keys\"; \\\\|" "$PRESEED_FILE"
