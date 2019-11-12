# rock64_fedora

Build scripts for creating CentOS and Fedora images for Rock64 devices.

## Instructions (Automatic Build)

Create the Rock64 image for CentOS or download it from the [releases page](https://github.com/ekultails/rock64_fedora/releases).

```
$ sudo bash rock64_fedora.sh
```

Use `dd` to copy the `/root/.rock64_fedora_tmp/centos-8.0-minimal-rock64-X.Y.Z.img` image to a microSD card.

## Instructions (Manual Build)

These steps are verified to be work on setting up CentOS 8 on a Rock64.

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

## Known Issues

- The RPM database that Rock64 Debian/Ubuntu based distribution creates is incompatible with CentOS (due to version differences with RPM/Yum).
    - After the first successful boot of Rock64, recreate the RPM database and then re-install the packages defined in `chroot_create.sh`. If these are not reinstalled, package dependency and upgrade issues can occur later on.

```
# cd /var/lib/rpm/
# rm -rf ./*
# rpm --initdb
# dnf install --releasever 8 ...
```

- NetworkManager.service fails to start causing a delayed boot. DHCP will still get correctly configured automatically.
- SELinux is not enabled.

## Scripts Change Log

- 0.2.1 = Install the required dependencies for resizing the root partition on the first boot. List known issues.
- 0.2.0 = Use Debian 10/Buster instead of 9/Stretch. Use a prebuilt root filesystem (container images are no longer used). Use a folder in the `$HOME` directory for temporary files (instead of /tmp to handle operating systems that use tmpfs with limited space). The rock64_fedora.sh script now works as intended.
- 0.1.0 = Start of a proof-of-concept script (not working) to use a CentOS 8 container image and a Debian 10 Rock64 baremetal image to build a CentOS 8 baremetal image.

## License

GPLv3
