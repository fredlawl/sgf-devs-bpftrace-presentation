#!/usr/bin/env -S bash -e

ROOTFS=./rootfs
ROOTFS_CREATED=$OUT_DIR/.rootfs

echo "Creating file system"
cd $BUILD_VOLUME

rm -rf $ROOTFS
rm -f $ROOTFS_CREATED

# Creates filesystem based off debian bullseye
fakeroot debootstrap --include=dwarves,vim,gcc,clang-11,llvm-11,make,zlib1g-dev,libelfin-dev,screen bullseye $ROOTFS http://deb.debian.org/debian

# Configure rootfs and add tools
fakeroot fakechroot chroot $ROOTFS /bin/bash <<"EOT"
echo -e "1234\n1234" | passwd
echo "deb http://deb.debian.org/debian bullseye-backports main" >> /etc/apt/sources.list
apt-get update
apt-get install -y -t bullseye-backports libbpf-dev bpftrace bpftool
EOT

# Hack for makefile to not attmpt to build fs each run
touch $ROOTFS_CREATED