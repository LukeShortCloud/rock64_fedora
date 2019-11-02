# rock64_fedora

Build scripts for creating CentOS and Fedora images for Rock64 devices.

## Instructions (Manual)

These steps are verified to be work on setting up CentOS 8 on a Rock64. Refer to the non-working rock64_fedora.sh script for how the backup and restore steps are handled.

- `dd` a Debian 10/Buster Rock64 images from the [official releases](https://github.com/ayufan-rock64/linux-build/releases) to a microSD card.
- Boot the Rock64 up. Scripts will run to automatically resize the root partitions.
- Use the `chroot_create.sh` script to create a CentOS 8 aarch64 chroot.
- Turn off the Rock64.
- Mount the microSD card back into a PC.
- Backup the `/boot` (from the `linux-root` partition), `/vendor`, `/lib/firmware`, `/lib/modules`, and `/usr/src/linux-headers-*` directories along with the CentOS 8 tarball.
- `rm` the mounted microSD card.
- Extract the CentOS 8 tarball to the microSD card.
- `rsync` the backed up Rock64 directories back onto the microSD card. `/lib` libraries will need to go into `/usr/lib` on CentOS.
- Boot the Rock64 and log into the `root` account with the password `rock64`. It will then prompt to change the root password.

## Scripts Change Log

- 0.1.0 = Start of a proof-of-concept script (not working) to use a CentOS 8 container image and a Debian 10 Rock64 baremetal image to build a CentOS 8 baremetal image.

## License

GPLv3
