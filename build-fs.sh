#!/usr/bin/env bash

OUT_DIR=$OUT_DIR
ROOTFS_NAME=rootfs
ROOTFS=$OUT_DIR/$ROOTFS_NAME

rm -rf $ROOTFS

# Creates filesystem based off debian bullseye
debootstrap bullseye $ROOTFS http://deb.debian.org/debian

# Get libbpf 0.7.0
(cd $OUT_DIR && [ -d "libbpf-0.7.0" ] || wget -q --show-progress --progress=bar:force https://github.com/libbpf/libbpf/archive/refs/tags/v0.7.0.zip 2>&1 && \
	unzip v0.7.0.zip)

# Installs latest version of libbpf
(cd $OUT_DIR/libbpf-0.7.0/src && PKG_CONFIG_PATH=../../${ROOTFS_NAME}/lib64/pkgconfig DESTDIR=../../${ROOTFS_NAME} make install)

# Configure rootfs and add tools
chroot $ROOTFS /bin/bash <<"EOT"
echo -e "1234\n1234" | passwd
apt-get -y install bpftrace bpftool dwarves vim
EOT