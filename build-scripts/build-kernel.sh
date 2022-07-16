#!/usr/bin/env bash

KERNEL_DIR=linux-$KERNEL_VERSION

echo "Compiling kernel"
cd $BUILD_VOLUME

# Get Kernel source & extract
[ -d $KERNEL_DIR ] || wget -q --show-progress --progress=bar:force https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$KERNEL_VERSION.tar.xz 2>&1 && \
	tar -xf linux-$KERNEL_VERSION.tar.xz

cd $KERNEL_DIR

# Clean up from last compilation
make mrproper

# Setup ebpf settings
make -j$(nproc) defconfig && scripts/config \
	-e ARCH_SUPPORTS_UPROBES -e BPF -e BPF_EVENTS -e BPF_JIT -e BPF_JIT_ALWAYS_ON \
	-e BPF_LSM -e BPF_SYSCALL -e BPF_UNPRIV_DEFAULT_OFF -e DEBUG_FS -e DEBUG_INFO \
	-e DEBUG_INFO_BTF -e DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT -e DYNAMIC_FTRACE \
	-e FTRACE_SYSCALLS -e FUNCTION_TRACER -e HAVE_DYNAMIC_FTRACE \
	-e HAVE_EBPF_JIT -e HAVE_KPROBES -e KPROBE_EVENTS -e KPROBES \
	-e PAHOLE_HAS_SPLIT_BTF -e UPROBE_EVENTS -e UPROBES

# Set defaults after configuration
make olddefconfig

make ARCH=x86_64 -j$(nproc)

cp ./arch/x86/boot/bzImage $OUT_DIR
chown 1000:1000 $OUT_DIR/bzImage