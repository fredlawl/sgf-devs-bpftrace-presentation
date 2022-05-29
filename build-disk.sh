#!/usr/bin/env bash

OUT_DIR=$OUT_DIR
ROOTFS=$OUT_DIR/rootfs

# Copy our custom rootfs over to the pre-built one
rsync -avh --delete rootfs/root/ $ROOTFS/root/

cd $OUT_DIR

echo "Creating disk.img"
qemu-img create disk.img 1024M
mkfs -t ext4 disk.img
mount -o loop disk.img /mnt
cp -ax rootfs/* /mnt
umount /mnt

chown 1000:1000 disk.img