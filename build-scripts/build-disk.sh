#!/usr/bin/env bash

ROOTFS=./rootfs
USER_ROOTFS=$(pwd)/$ROOTFS

echo "Creating disk.img"
cd $BUILD_VOLUME

# Copy our custom rootfs over to the pre-built one
rsync -avh --delete $USER_ROOTFS/root/ $ROOTFS/root

# Create the disk
qemu-img create disk.img 4096M
mkfs -t ext4 disk.img
mount -o loop disk.img /mnt
cp -ax $ROOTFS/* /mnt
umount /mnt

cp disk.img $OUT_DIR
chown 1000:1000 $OUT_DIR/disk.img