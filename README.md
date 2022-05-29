# SGF DEVS bpftrace Presentation

This project sets up a eBPF-ready Linux virtual machine to make developing
eBPF programs a little bit easier across operating systems.

## Project Setup

### Dependencies (TODO)

#### Linux

#### MacOS (Intel)

#### Windows

### Compile & Launch VM

> WARN: This can take a long time, but subsequent runs are much faster.

```sh
$ make run
```

**Username/Password login**: root/1234

### Configuration

**How can I persist my work between rebuilds?**

Add your own files to *./rootfs/root*, and they'll be automatically sync'd 
over to the home directory of the root user of the virtual machine.

**How can I configure the root user's shell profile and persist between builds?**

Add your *.bash_profile* etc... to *./rootfs/root*.

**How can I add and persist my favorite development tools between builds?**

Add them to the "# Configure rootfs and add tools" section in *build-fs.sh*.