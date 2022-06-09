#!/usr/bin/env -S bash -e

ROOTFS=./rootfs
OUT=$OUT_DIR/$ROOTFS

echo "Creating file system"
cd $BUILD_VOLUME

rm -rf $ROOTFS

# Creates filesystem based off debian bullseye
fakeroot debootstrap --include=bpftrace,dwarves,bpftool bullseye $ROOTFS http://deb.debian.org/debian

# Get libbpf 0.7.0
([ -d "libbpf-0.7.0" ] || wget -q --show-progress --progress=bar:force https://github.com/libbpf/libbpf/archive/refs/tags/v0.7.0.zip 2>&1 && \
	unzip v0.7.0.zip)

# Installs latest version of libbpf
(cd libbpf-0.7.0/src && PKG_CONFIG_PATH=../../${ROOTFS}/usr/lib64/pkgconfig DESTDIR=../../${ROOTFS} make -j$(nproc) install)

# Configure rootfs and add tools
fakeroot fakechroot chroot $ROOTFS /bin/bash <<"EOT"
echo -e "1234\n1234" | passwd
apt-get -y install vim
EOT

mkdir -p $OUT
cp -ax $ROOTFS/* $OUT