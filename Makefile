export DOCKER_BUILDKIT=1
KERNEL_VERSION ?= 5.17.5
OUT_DIR ?= ./out

.PHONY: all
all: fs kernel

.PHONY: run
run: all
	qemu-system-x86_64 -kernel ${OUT_DIR}/bzImage -nographic -append "root=/dev/sda rw console=ttyS0 debugfs=on" -m 2024 --enable-kvm -cpu host -hda ${OUT_DIR}/disk.img -s

.PHONY: clean
clean:
	sudo rm -rf ${OUT_DIR}
	docker image rm bpf-kernel-builder

.PHONY: image
image: Dockerfile ${OUT_DIR}
	docker build --build-arg OUT_DIR=${OUT_DIR} --build-arg KERNEL_VERSION=${KERNEL_VERSION} --label bpf-kernel-builder -t bpf-kernel-builder:latest .

.PHONY: fresh-image
fresh-image:
	docker build --no-cache --build-arg OUT_DIR=${OUT_DIR} --build-arg KERNEL_VERSION=${KERNEL_VERSION} --label bpf-kernel-builder -t bpf-kernel-builder:latest .

.PHONY: kernel
kernel: ${OUT_DIR}/bzImage

${OUT_DIR}/bzImage: build-kernel.sh | ${OUT_DIR} image
	docker run --mount src="$(PWD)",target=/build,type=bind --rm --name="kernel_build_container" --privileged bpf-kernel-builder ./build-kernel.sh

.PHONY: fs
fs: ${OUT_DIR}/disk.img

${OUT_DIR}/disk.img: build-disk.sh ${OUT_DIR}/rootfs ./rootfs/**/* | ${OUT_DIR} image
	docker run --mount src="$(PWD)",target=/build,type=bind --rm --name="kernel_build_container" --privileged bpf-kernel-builder ./build-disk.sh

${OUT_DIR}/rootfs: build-fs.sh | ${OUT_DIR} image
	docker run --mount src="$(PWD)",target=/build,type=bind --rm --name="kernel_build_container" --privileged bpf-kernel-builder ./build-fs.sh

${OUT_DIR}:
	mkdir -p ${OUT_DIR}