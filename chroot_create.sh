#!/bin/bash

apt-get update -y
apt-get install -y yum
mkdir /etc/yum.repos.d/
cat <<EOF >/etc/yum.repos.d/centos8.repo
[centos_8_baseos_aarch64]
name=centos_8_baseos_aarch64
baseurl=http://mirror.centos.org/centos/8/BaseOS/aarch64/os/
enabled=1

[centos_8_appstream_aarch64]
name=centos_8_appstream_aarch64
baseurl=http://mirror.centos.org/centos/8/AppStream/aarch64/os/
enabled=1
EOF
centos_rootfs="centos-8.0-aarch64-rootfs-0.2.1"
yum install -y centos-release dnf e2fsprogs gdisk less openssh-server parted passwd sudo @base --installroot=/home/rock64/$centos_rootfs
cd /home/rock64
> ${centos_rootfs}/etc/machine-id
rm -rf ${centos_rootfs}/var/cache/yum/*
tar -c -f ${centos_rootfs}.tar $centos_rootfs
