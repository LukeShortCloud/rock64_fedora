#!/bin/bash

container_cli="docker"

if [ -x $(command -v podman) ]; then
    echo "Using podman."
    container_cli="podman"
else
    echo "Using docker (may require root access)."
fi

rock64_release_full="0.9.14-1159"
rock64_release=$(echo $rock64_release_full | cut -d\- -f1)
rock64_image="stretch-minimal-rock64-${rock64_release_full}-arm64.img"
rock64_url="https://github.com/ayufan-rock64/linux-build/releases/download/${rock64_release}/${rock64_image}.xz"

TMP_DIR=$(mktemp --directory)
cd $TMP_DIR
echo "Working directory: $(pwd)"
echo "Downloading the root file system from an OCI image."
$container_cli pull centos:8
$container_cli save centos:8 > centos_8.tar
tar -x -f centos_8.tar
mkdir centos_8_rootfs
tar -x -f ./*/layer.tar -C centos_8_rootfs
wget $rock64_url
xz -d ${rock64_image}.xz
loop_device=$(losetup --show -f -P $rock65_image)
mkdir mnt
# root
mount ${loop_device}p7 ${TMP_DIR}/mnt
# /boot/, /vendor/, /lib/firmware/, and /lib/modules/ need to be kept
# from the Rock64 image. Optionally also keep /usr/src/ which has the
# kernel source code.
cd centos_8_rootfs
cp -r ${TMP_DIR}/mnt/boot ./
cp -r ${TMP_DIR}/mnt/vendor ./
# Fedora uses a symlink from /lib to /usr/lib.
cp -r ${TMP_DIR}/mnt/lib/firmware usr/lib/
cp -r ${TMP_DIR}/mnt/lib/modules usr/lib/
cp -r ${TMP_DIR}/mnt/usr/src/linux-headers-* usr/src/kernels/
# Enable the OpenSSH server.
ln -s /usr/lib/systemd/system/sshd.service /etc/systemd/system/multi-user.target.wants/sshd.service
# The root password will fail to reset without this option.
# https://bugzilla.redhat.com/show_bug.cgi?id=1410450
echo "dictcheck = 0" >> etc/security/pwquality.conf
# Testing using `find` to delete files.
# cd ${TMP_DIR}/mnt
#find . -type d -not \( -wholename "./boot*" -or -wholename "./lib/firmware*" -or -wholename "./lib/modules*" -or -wholename "./usr/src*" \) -delete
# Add the boot entry to the fstab (mirroring the configuration from the Rock64 image).
echo "LABEL=boot /boot/efi vfat defaults,sync 0 0" > etc/fstab
# Set password the root password to "rock64"
sed -i s'/root.*/root:$6$2Nr3piSK$Ko3rqyUCr2yadIhU0KATBTlEILsq2OdhNzlOv46n2QkiYXAp0WJnzLgO93DX9SxQjgXlAHw5mMApAZkb8ODZf.:0:0:99999:7:::/g' etc/shadow
rm -f ${TMP_DIR}/mnt/*
cp -a -r ${TMP_DIR}/centos_8_rootfs/* ${TMP_DIR}/mnt/
# Limitations
#     SSH is not installed
#     Non-privileged user must be manually created
