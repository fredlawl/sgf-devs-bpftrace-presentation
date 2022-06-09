FROM amd64/debian:bullseye-slim

ARG KERNEL_VERSION
ENV KERNEL_VERSION=$KERNEL_VERSION

ARG OUT_DIR
ENV OUT_DIR=$OUT_DIR

ARG BUILD_VOLUME
ENV BUILD_VOLUME=$BUILD_VOLUME

WORKDIR /root

RUN apt-get update && \
    apt-get install -y \
	build-essential \
	libncurses-dev \
	bison \
	flex \
	libssl-dev \
	libelf-dev \
	bc \
	wget \
	qemu-utils \
	initramfs-tools-core \
	zlib1g \
	unzip \
	libguestfs-tools \
	debootstrap \
	dwarves \
	rsync \
    fakeroot \
    fakechroot

COPY build-scripts/*.sh .
COPY rootfs ./rootfs
