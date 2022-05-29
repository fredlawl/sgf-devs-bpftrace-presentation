FROM amd64/debian:bullseye-slim

ARG KERNEL_VERSION
ENV KERNEL_VERSION=$KERNEL_VERSION

ARG OUT_DIR
ENV OUT_DIR=$OUT_DIR

WORKDIR /build

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
	rsync

COPY build-kernel.sh .
COPY build-fs.sh .
COPY build-disk.sh .