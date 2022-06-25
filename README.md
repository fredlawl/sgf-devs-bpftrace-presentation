# SGF DEVS bpftrace Presentation

This project sets up a eBPF-ready Linux virtual machine to make developing
eBPF programs a little bit easier across operating systems.

## Project Setup

### Dependencies

1. make
2. qemu
3. Docker ([install instructions](https://docs.docker.com/get-docker/))

#### Linux

```sh
apt-get install make qemu-system-x86
```

#### MacOS (Intel)

```sh
brew install make qemu
```

#### Windows

WSL2 is the preferred approach

```sh
apt-get install make qemu-system-x86
```

### Compile & Launch VM

> WARN: This can take a long time, but subsequent runs are much faster.

```sh
$ make run (for Linux)
$ make run-mac
$ make run-windows
```

**Username/Password login**: root/1234

To exit QEMU VM, `ctrl + a` then press `c`, then type `quit` and press enter.

### Configuration

**How can I persist my work between rebuilds?**

Add your own files to *./rootfs/root*, and they'll be automatically sync'd 
over to the home directory of the root user of the virtual machine.

**How can I configure the root user's shell profile and persist between builds?**

Add your *.bash_profile* etc... to *./rootfs/root*.

**How can I add and persist my favorite development tools between builds?**

Add them to the "# Configure rootfs and add tools" section in *build-scripts/build-fs.sh*.