#!/bin/bash
set -e

# Variables
EFI_NAME="ipxe.efi"
IMG_NAME="ipxe-boot.img"
VDI_NAME="ipxe-boot.vdi"
EFI_REL_PATH="EFI/BOOT/BOOTAA64.EFI"
MOUNT_NAME="IPXE"
SIZE_MB=64

# Create blank image
dd if=/dev/zero of="$IMG_NAME" bs=1M count=$SIZE_MB

# Attach image and capture disk number
DISK_ENTRY=$(hdiutil attach -nomount "$IMG_NAME" | tail -n1)
DISK_DEV=$(echo "$DISK_ENTRY" | awk '{print $1}')

# Partition and format as FAT32 with MBR
diskutil partitionDisk "$DISK_DEV" 1 MBRFormat "MS-DOS FAT32" "$MOUNT_NAME" 100%

# Mount the partition
diskutil mountDisk "$DISK_DEV"

# Wait for /Volumes/IPXE to appear
sleep 1

# Create EFI folder and copy ipxe.efi
mkdir -p "/Volumes/$MOUNT_NAME/EFI/BOOT"
cp $EFI_NAME "/Volumes/$MOUNT_NAME/$EFI_REL_PATH"

# Unmount and detach
diskutil unmountDisk "$DISK_DEV"
hdiutil detach "$DISK_DEV"

# Convert to VDI
VBoxManage convertfromraw "$IMG_NAME" "../$VDI_NAME" --format VDI

# Clean up
rm "$IMG_NAME"

echo "Created $VDI_NAME successfully."
