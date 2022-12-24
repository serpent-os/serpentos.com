---
title: "Download"
date: 2022-01-04T17:10:00+01:00
draft: false
Callout: "Grab them images"
---

## ISOs

Currently we only provide a very basic **validation** ISO, used to verify some basic functionality,
boot sequence, the kernel ansd toolchain. You can experiment with the `moss` package manager too!

[snekvalidator.iso](https://download.serpentos.com/snekvalidator.iso)

**SHA256SUM**

    b7175763ec97e777b8e197af52ba6a1fa61075a4d1787ed3703453e86106866d  snekvalidator.iso

While it **can** boot on certain UEFI-enabled Intel laptops (write USB with `dd`) - it is recommended
to boot with the OVMF (EDK2) firmware via Qemu, for example:

```bash
qemu-system-x86_64 -enable-kvm -cdrom snekvalidator.iso -bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd -m 8096m -cpu host
```

## Docker images

#### Base image

The base image allows experimentation with the Seprnet OS package manager, moss. Note that building
via `boulder` is __currently__ unsupported.


`docker run -ti --rm serpentos/base:latest`

#### Python image

Our Python image extends the base image with Python 3, and can be used to experiment with our Python
interpreter build.

`docker run -ti --rm serpentos/python:latest`
