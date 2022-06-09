#!/usr/bin/env bash

OUT_DIR=$OUT_DIR
KERNEL_DIR=linux-$KERNEL_VERSION

cd $OUT_DIR

# Get Kernel source & extract
[ -d $KERNEL_DIR ] || wget -q --show-progress --progress=bar:force https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$KERNEL_VERSION.tar.xz 2>&1 && \
	tar -xf linux-$KERNEL_VERSION.tar.xz

cd $KERNEL_DIR

make -j$(nproc) defconfig && scripts/config \
	-e CONFIG_BPF -e CONFIG_BPF_EVENTS -e CONFIG_BPF_JIT -e CONFIG_BPF_SYSCALL \
	-e CONFIG_FTRACE_SYSCALLS -e CONFIG_HAVE_EBPF_JIT -e DEBUG_INFO_BTF \
	-e PAHOLE_HAS_SPLIT_BTF -e CONFIG_FUNCTION_TRACER -e CONFIG_HAVE_DYNAMIC_FTRACE \
	-e CONFIG_DYNAMIC_FTRACE -e CONFIG_HAVE_KPROBES -e CONFIG_KPROBES \
	-e CONFIG_KPROBE_EVENTS -e CONFIG_ARCH_SUPPORTS_UPROBES \
	-e CONFIG_UPROBES -e CONFIG_UPROBE_EVENTS -e CONFIG_DEBUG_FS

make ARCH=x86_64 -j$(nproc))

cp $KERNEL_DIR/arch/x86/boot/bzImage .
chown 1000:1000 bzImage