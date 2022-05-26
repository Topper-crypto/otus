#!/bin/bash
vagrant ssh nfsc
yum update -y
yum install nfs-utils -y
systemctl start rpcbind
systemctl enable rpcbind
systemctl enable firewalld --now
systemctl status firewalld
systemctl enable nfs --now
echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab
systemctl daemon-reload
systemctl restart remote-fs.target
mount | grep mnt
