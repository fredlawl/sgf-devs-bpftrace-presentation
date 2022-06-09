export DOCKER_BUILDKIT=1
KERNEL_VERSION ?= 5.17.5
OUT_DIR ?= /out
LOCAL_OUT_DIR = $(PWD)/${OUT_DIR}
VOLUME_DIR ?= /build
SCRIPTS_DIR ?= ./build-scripts
DOCKER_RUN = docker run -v ${DOCKER_VOLUME}:${VOLUME_DIR}:rw --mount src="${LOCAL_OUT_DIR}",target=${OUT_DIR},type=bind --rm --name="kernel_build_container"
DOCKER_IMG = bpf-kernel-builder
DOCKER_VOLUME = bpf-kernel-builder-vol
QEMU = qemu-system-x86_64 -kernel ${LOCAL_OUT_DIR}/bzImage -nographic -append "root=/dev/sda rw console=ttyS0 debugfs=on" -m 2024 -hda ${LOCAL_OUT_DIR}/disk.img -s

.PHONY: all
all: fs kernel

.PHONY: run
run: all
	$(QEMU) --enable-kvm -cpu host

.PHONY: run-mac
	$(QEMU)

.PHONY: clean
clean:
	sudo rm -rf ${LOCAL_OUT_DIR}
	-docker volume rm ${DOCKER_VOLUME}
	-docker image rm ${DOCKER_IMG}

.PHONY: image
image: Dockerfile | ${LOCAL_OUT_DIR} img-volume
	docker build --build-arg OUT_DIR=${OUT_DIR} --build-arg BUILD_VOLUME=${VOLUME_DIR} --build-arg KERNEL_VERSION=${KERNEL_VERSION} --label ${DOCKER_IMG} -t ${DOCKER_IMG}:latest .

.PHONY: fresh-image
fresh-image: Dockerfile | ${LOCAL_OUT_DIR} img-volume
	docker build --no-cache --build-arg OUT_DIR=${OUT_DIR} --build-arg BUILD_VOLUME=${VOLUME_DIR} --build-arg KERNEL_VERSION=${KERNEL_VERSION} --label ${DOCKER_IMG} -t ${DOCKER_IMG}:latest .

.PHONY: debug-img
debug-img: Dockerfile image | ${LOCAL_OUT_DIR} img-volume
	$(DOCKER_RUN) -ti --privileged ${DOCKER_IMG} bash

.PHONY: img-volume
img-volume:
	docker volume create ${DOCKER_VOLUME}

.PHONY: kernel
kernel: ${LOCAL_OUT_DIR}/bzImage

${LOCAL_OUT_DIR}/bzImage: ${SCRIPTS_DIR}/build-kernel.sh | ${LOCAL_OUT_DIR} image
	$(DOCKER_RUN) ${DOCKER_IMG} ./build-kernel.sh

.PHONY: fs
fs: ${LOCAL_OUT_DIR}/disk.img

${LOCAL_OUT_DIR}/disk.img: ${SCRIPTS_DIR}/build-disk.sh ${LOCAL_OUT_DIR}/rootfs ./rootfs/**/* | ${LOCAL_OUT_DIR} image
	$(DOCKER_RUN) --privileged ${DOCKER_IMG} ./build-disk.sh

${LOCAL_OUT_DIR}/rootfs: ${SCRIPTS_DIR}/build-fs.sh | ${LOCAL_OUT_DIR} image
	$(DOCKER_RUN) --privileged ${DOCKER_IMG} ./build-fs.sh

${LOCAL_OUT_DIR}:
	mkdir -p ${LOCAL_OUT_DIR}
