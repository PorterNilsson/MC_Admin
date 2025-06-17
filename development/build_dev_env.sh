#!/bin/sh
set -e

PRESEED_FILE="vm/ipxe/http/preseed.cfg"
KEY_NAME="mc_admin_dev"
VM_NAME="MC_Admin_Dev"

# Set up SSH Keys and edit preseed files
cd ssh
./set_up_ssh.sh
cd ..

# Start HTTP server
cd vm/ipxe/http
python3 -m http.server 8090 --bind 127.0.0.1 &
SERVER_PID=$!
cd ../../..

# Build VM
cd vm
./build_vm.sh
cd ..

# Clean up HTTP server and preseed file
kill $SERVER_PID
NEW_KEY=""
sed -i '' -E "s|(in-target sh -c \"echo ')[^']*(' > /root/.ssh/authorized_keys\"; \\\\)|\1$NEW_KEY\2|" $PRESEED_FILE

# Set up userland environment
VBoxManage startvm "$VM_NAME" --type headless
sleep 10
scp -i ssh/${KEY_NAME} -P 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null set_up_userspace.sh root@localhost:/root/
ssh -i ssh/${KEY_NAME} -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost '/root/set_up_userspace.sh'