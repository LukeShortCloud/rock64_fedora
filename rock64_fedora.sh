#!/bin/bash

set -x
TMP_DIR="$HOME/.rock64_fedora_tmp"
ROCK64_VERSION="0.3.0"
echo "rock64_fedora version: $ROCK64_VERSION"
rock64_release_full="0.9.16-1163"
rock64_release=$(echo $rock64_release_full | cut -d\- -f1)
rock64_image="buster-minimal-rock64-${rock64_release_full}-arm64.img"
rock64_url="https://github.com/ayufan-rock64/linux-build/releases/download/${rock64_release}/${rock64_image}.xz"
centos_rootfs="centos-8-aarch64-rootfs-${ROCK64_VERSION}"
mkdir $TMP_DIR
cd $TMP_DIR
echo "Working directory: $(pwd)"
wget https://github.com/ekultails/rock64_fedora/releases/download/${ROCK64_VERSION}/${centos_rootfs}.tar.xz
tar -x -f ${centos_rootfs}.tar.xz
# Clean up existing image that may be modified.
rm -f $rock64_image
wget $rock64_url
xz -d ${rock64_image}.xz
loop_device=$(losetup --show -f -P $rock64_image)
mkdir mnt
# Mount the root partition.
mount ${loop_device}p7 ${TMP_DIR}/mnt
# Copy over the linux kernel and other required files from the official Rock64 image.
rock64_fedora_image="centos-8.0-minimal-rock64-$ROCK64_VERSION"
mkdir $rock64_fedora_image
cd $rock64_fedora_image
cp -r ../${centos_rootfs}/* ./
chmod 1777 ./tmp
cp -r ${TMP_DIR}/mnt/boot ./
cp -r ${TMP_DIR}/mnt/vendor ./
# Fedora uses a symlink from /lib to /usr/lib.
\cp -r -f ${TMP_DIR}/mnt/lib/firmware usr/lib/
\cp -r -f ${TMP_DIR}/mnt/lib/modules usr/lib/
cp -r ${TMP_DIR}/mnt/usr/src/linux-headers-* usr/src/kernels/
# Copy the root filesystem resizing script.
cp ${TMP_DIR}/mnt/etc/systemd/system/first-boot.service etc/systemd/system/first-boot.service
ln -s /usr/lib/systemd/system/first-boot.service etc/systemd/system/multi-user.target.wants/first-boot.service
cp ${TMP_DIR}/mnt/usr/local/sbin/rock64_first_boot.sh usr/local/sbin/
cp ${TMP_DIR}/mnt/usr/local/sbin/resize_rootfs.sh usr/local/sbin/
# Enable the OpenSSH server.
ln -s /usr/lib/systemd/system/sshd.service etc/systemd/system/multi-user.target.wants/sshd.service
# The root password will fail to reset without this option.
# https://bugzilla.redhat.com/show_bug.cgi?id=1410450
echo "dictcheck = 0" >> etc/security/pwquality.conf
# Add the boot entry to the fstab (mirroring the configuration from the Rock64 image).
echo "LABEL=boot /boot/efi vfat defaults,sync 0 0" > etc/fstab
# Set the initial password for root to "rock64".
sed -i s'/root.*/root:$6$2Nr3piSK$Ko3rqyUCr2yadIhU0KATBTlEILsq2OdhNzlOv46n2QkiYXAp0WJnzLgO93DX9SxQjgXlAHw5mMApAZkb8ODZf.:0:0:99999:7:::/g' etc/shadow
rm -rf ${TMP_DIR}/mnt/*
cp -a -r ${TMP_DIR}/${rock64_fedora_image}/* ${TMP_DIR}/mnt/
sync
umount ${TMP_DIR}/mnt
losetup -D $loop_device
cd ${TMP_DIR}
mv buster-minimal-rock64-0.9.16-1163-arm64.img ${rock64_fedora_image}.img
