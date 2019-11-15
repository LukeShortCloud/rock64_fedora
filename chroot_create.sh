#!/bin/bash

ROCK64_VERSION="0.3.0"

if [[ -d /etc/apt ]]; then
    apt-get update -y
    apt-get install -y yum
    mkdir /etc/yum.repos.d/
    pkg_mgr="yum"
else
    pkg_mgr="dnf"
fi

if [[ "$@" == "centos" ]]; then
    os_version="8"
    repos_args=('--disablerepo=*' "--enablerepo" "centos_baseos_aarch64" "--enablerepo" "centos_appstream_aarch64")
    cat <<EOF >/etc/yum.repos.d/rock64_fedora.repo
[centos_baseos_aarch64]
name=centos_baseos_aarch64
baseurl=http://mirror.centos.org/centos/8/BaseOS/aarch64/os/
gpgcheck=0
enabled=1

[centos_appstream_aarch64]
name=centos_appstream_aarch64
baseurl=http://mirror.centos.org/centos/8/AppStream/aarch64/os/
gpgcheck=0
enabled=1
EOF
elif [[ "$@" == "fedora" ]]; then
    os_version="31"
    repos_args=('--disablerepo=*' "--enablerepo" "fedora_everything_aarch64")
    cat <<EOF >/etc/yum.repos.d/rock64_fedora.repo
[fedora_everything_aarch64]
name=fedora_everything_aarch64
baseurl=http://download.fedoraproject.org/pub/fedora/linux/releases/31/Everything/aarch64/os/
gpgcheck=0
enabled=1
EOF
else
    echo "Wrong operating system specified. Use: centos or fedora"
fi

# Example: centos-8.0-aarch64-rootfs-0.3.0
fedora_rootfs="$@-${os_version}-aarch64-rootfs-${ROCK64_VERSION}"
# Install the release package first to setup the required modular repoistories.
$pkg_mgr install -y ${repos_args[@]} --releasever $os_version $@-release --installroot=/root/$fedora_rootfs
# The repositories will now load from the chroot and not the host.
mkdir -p /root/${fedora_rootfs}/etc/yum.repos.d/
cp /etc/yum.repos.d/rock64_fedora.repo /root/${fedora_rootfs}/etc/yum.repos.d/
$pkg_mgr install -y ${repos_args[@]} --releasever $os_version \
    dnf e2fsprogs gdisk less openssh-server parted passwd sudo "@Minimal Install" --installroot=/root/$fedora_rootfs
cd /root/
# Reset the unique machine-id
> ${fedora_rootfs}/etc/machine-id
# Clear the large yum cache
rm -rf ${fedora_rootfs}/var/cache/yum/* ${fedora_rootfs}/var/cache/dnf/*
tar -c -f ${fedora_rootfs}.tar $fedora_rootfs
rm -f /etc/yum.repos.d/rock64_fedora.repo /root/${fedora_rootfs}/etc/yum.repos.d/rock64_fedora.repo
