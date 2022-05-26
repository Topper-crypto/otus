#!/bin/bash
vagrant ssh nfsc
yum update -y
yum install nfs-utils -y
systemctl enable firewalld --now
systemctl status firewalld
echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,xsystemd.automount 0 0" >> /etc/fstab
systemctl daemon-reload
systemctl restart remote-fs.target
mount | grep mnt
