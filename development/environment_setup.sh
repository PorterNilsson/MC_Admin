#!/bin/sh

VM_NAME="MC_Admin_Development_Environment"
VM_DIR="$HOME/VirtualBox VMs/$VM_NAME"
ISO_PATH="$(pwd)/iso/debian-12.11.0-arm64-netinst-preseeded.iso"
OVA_PATH="$(pwd)/MC_Admin_Development_Environment.ova"
ISO_URL="https://github.com/PorterNilsson/MC_Admin/releases/download/v1-debian-preseeeded-iso/debian-12.11.0-arm64-netinst-preseeded.iso"

if [ ! -f "$ISO_PATH" ]; then
    echo "ISO not found."
    echo "Downloading from $ISO_URL."
    curl -L -o ./iso/debian-12.11.0-arm64-netinst-preseeded.iso "https://github.com/PorterNilsson/MC_Admin/releases/download/v1-debian-preseeeded-iso/debian-12.11.0-arm64-netinst-preseeded.iso"
else
    echo "ISO found."
fi

if VBoxManage list vms | grep -q "\"$VM_NAME\""; then
    echo "VM '$VM_NAME' already exists. Deleting."
    VBoxManage unregistervm "$VM_NAME" --delete-all
else
    echo "VM '$VM_NAME' does not yet exist. Proceeding with creation."
fi

echo "Importing VM from OVA file."
VBoxManage import "$OVA_PATH" --vsys 0 --vmname "$VM_NAME"

echo "Reattaching ISO."
VBoxManage storageattach "$VM_NAME" \
  --storagectl "VirtioSCSI" \
  --port 1 --device 0 \
  --type dvddrive \
  --medium "$ISO_PATH"

echo "Booting VM for the first time to install OS."
VBoxManage startvm "$VM_NAME" --type headless

while VBoxManage showvminfo "$VM_NAME" --machinereadable | grep -q '^VMState="running"$'; do
    echo "Install is still in progress..."
    sleep 20
done

sleep 5
echo "Install finished. Restarting VM to install userland tools."
VBoxManage startvm "$VM_NAME" --type headless

sleep 20
echo 
echo "-----------------------------------------------------"
echo "YOU MUST ENTER PASSWORD \"mcadmindev\" THREE TIMES HERE"
echo "----------------------------------------------------"
echo

scp -P 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null userland_setup.sh mcadmindev@127.0.0.1:~
ssh -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 mcadmindev@127.0.0.1 'sudo ~/userland_setup.sh'

echo "Finished setting up userland. Full Installation complete. Shutting down VM."
VBoxManage controlvm "$VM_NAME" acpipowerbutton
