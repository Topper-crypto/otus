#!/bin/bash
sudo -i
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
yum update -y
yum install -y yum-utils
yum install -y https://zfsonlinux.org/epel/zfs-release.el8_5.noarch.rpm
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
yum install -y epel-release kernel-devel zfs
yum-config-manager --disable zfs
yum-config-manager --enable zfs-kmod
yum install -y zfs
modprobe zfs
yum install -y wget
