#!/bin/sh
set -ex

# Initialize variables
VM_NAME="MC_Admin_Dev"
DISK1="ipxe-boot.vdi"
DISK2="main.vdi"

# Initialize folders
mkdir -p vm

# Delete old VM if it exists
if VBoxManage showvminfo "$VM_NAME" >/dev/null 2>&1; then
  VBoxManage unregistervm "$VM_NAME" --delete-all
fi

# Delete old vdi files if they exist
rm -f $DISK1
rm -f $DISK2

# Create and register a new VM
VBoxManage createvm --name "$VM_NAME" --ostype "Debian12_arm64" --register

# Set VM resources
VBoxManage modifyvm "$VM_NAME" --cpus 4 --memory 2048
VBoxManage modifyvm "$VM_NAME" --ioapic on


# Use EFI firmware
VBoxManage modifyvm "$VM_NAME" --firmware efi

# Setup VM Networking
VBoxManage modifyvm "$VM_NAME" \
  --nic1 nat \
  --nictype1 virtio

VBoxManage modifyvm "$VM_NAME" \
  --natpf1 "SSH,tcp,,2222,,22"

# Setup VM Audio
VBoxManage modifyvm "$VM_NAME" --audio-driver Default --audiocontroller hda

# Setup peripherals
VBoxManage modifyvm "$VM_NAME" \
  --usb-xhci on \
  --mouse usbtablet \
  --keyboard usb

# Setup Storage
VBoxManage storagectl "$VM_NAME" \
  --name "VirtioSCSI" \
  --add virtio-scsi \
  --portcount 4

cd ipxe
./build_ipxe_vdi.sh
cd ..

VBoxManage storageattach "$VM_NAME" \
  --storagectl "VirtioSCSI" \
  --port 0 --device 0 \
  --type hdd \
  --medium "$DISK1"

VBoxManage createmedium disk --filename $DISK2 --size 20480 --format VDI

VBoxManage storageattach "$VM_NAME" \
  --storagectl "VirtioSCSI" \
  --port 1 --device 0 \
  --type hdd \
  --medium "$DISK2"

VBoxManage storageattach "$VM_NAME" \
  --storagectl "VirtioSCSI" \
  --port 2 --device 0 \
  --type dvddrive \
  --medium emptydrive

# Configure Video Settings
VBoxManage modifyvm "$VM_NAME" \
  --graphicscontroller vmsvga \
  --vram 16


sleep 10

# Start VM
VBoxManage startvm "$VM_NAME" --type gui

# Wait for installation to finish
while VBoxManage showvminfo "$VM_NAME" --machinereadable | grep -q 'VMState="running"'; do
    echo "Waiting for install to finish..."
    sleep 30
done

sleep 5