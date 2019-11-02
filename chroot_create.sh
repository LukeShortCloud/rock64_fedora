#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y yum
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
sudo yum groupinstall standard --installroot=/home/rock64/centos_8_aarch64
sudo yum install centos-release dnf openssh-server sudo @base --installroot=/home/rock64/centos_8_aarch64
sudo tar -c -f centos_8_aarch64.tar centos_8_aarch64
