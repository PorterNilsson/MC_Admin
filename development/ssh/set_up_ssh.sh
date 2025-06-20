#!/bin/sh
set -e

KEY_NAME="mc_admin_dev"
PRESEED_FILE="../vm/ipxe/http/preseed.cfg"
PRESEED_TEMPLATE="../vm/ipxe/preseed_debian_template.cfg"

# Remove old key if it exists
rm -f "$KEY_NAME"
rm -f "${KEY_NAME}.pub"

# Recreate SSH key
ssh-keygen -f "$KEY_NAME" -N "" -q
chmod 600 $KEY_NAME

# Send the key
PUBKEY=$(cat mc_admin_dev.pub)

cp "$PRESEED_TEMPLATE" "$PRESEED_FILE"
echo "  in-target sh -c \"echo '$PUBKEY' > /root/.ssh/authorized_keys\";" >> "$PRESEED_FILE"