#### Домашнее задание
> NFS:
> 
> * vagrant up должен поднимать 2 виртуалки: сервер и клиент;
> * на сервер должна быть расшарена директория;
> * на клиента она должна автоматически монтироваться при старте (fstab или autofs);
> * в шаре должна быть папка upload с правами на запись;
> * требования для NFS: NFSv3 по UDP, включенный firewall.
> * Настроить аутентификацию через KERBEROS (NFSv4)

### Решение:
```
[topper@fedora NFS]$ vagrant up
```

На сервере
```
[topper@fedora NFS]$ vagrant ssh nfss
[vagrant@nfss ~]$ cd /srv/share/upload
[vagrant@nfss upload]$ sudo touch check_file
[vagrant@nfss upload]$ ls
check_file
```
На клиенте
```
[topper@fedora NFS]$ vagrant ssh nfsc
[vagrant@nfsc ~]$ cd /mnt/upload
[vagrant@nfsc upload]$ ls
check_file
[vagrant@nfsc upload]$ sudo touch client_file
[vagrant@nfsc upload]$ ls
check_file  client_file
```

На сервере
```
[vagrant@nfss upload]$ ls
check_file  client_file
```

Перезапускаем клиент и проводим проверку
```
[vagrant@nfsc upload]$ sudo reboot
Connection to 127.0.0.1 closed by remote host.
Connection to 127.0.0.1 closed.
[topper@fedora NFS]$ vagrant ssh nfsc
Last login: Thu May 26 19:38:15 2022 from 10.0.2.2
[vagrant@nfsc ~]$ cd /mnt/upload
[vagrant@nfsc upload]$ ls
check_file  client_file
```

Перезапускаем сервер и проводим проверку
```
[vagrant@nfss upload]$ sudo reboot
Connection to 127.0.0.1 closed by remote host.
Connection to 127.0.0.1 closed.
[topper@fedora NFS]$ vagrant ssh nfss
Last login: Thu May 26 19:37:51 2022 from 10.0.2.2
[vagrant@nfss ~]$ cd /srv/share/upload/
[vagrant@nfss upload]$ ls
check_file  client_file
[vagrant@nfss upload]$ sudo systemctl status nfs
● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
  Drop-In: /run/systemd/generator/nfs-server.service.d
           └─order-with-mounts.conf
   Active: active (exited) since Чт 2022-05-26 19:49:44 UTC; 1min 6s ago
  Process: 834 ExecStartPost=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=exited, status=0/SUCCESS)
  Process: 809 ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS (code=exited, status=0/SUCCESS)
  Process: 806 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
 Main PID: 809 (code=exited, status=0/SUCCESS)
   CGroup: /system.slice/nfs-server.service

май 26 19:49:44 nfss systemd[1]: Starting NFS server and services...
май 26 19:49:44 nfss systemd[1]: Started NFS server and services.

[vagrant@nfss upload]$ sudo systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Чт 2022-05-26 19:49:41 UTC; 2min 22s ago
     Docs: man:firewalld(1)
 Main PID: 408 (firewalld)
   CGroup: /system.slice/firewalld.service
           └─408 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid

май 26 19:49:40 nfss systemd[1]: Starting firewalld - dynamic firewall daemon...
май 26 19:49:41 nfss systemd[1]: Started firewalld - dynamic firewall daemon.
май 26 19:49:41 nfss firewalld[408]: WARNING: AllowZoneDrifting is enabled. This is considered an insecure configuration option. It will be removed in a future release. Please consider disabling it now.
[vagrant@nfss upload]$ sudo exportfs -s
/srv/share  192.168.50.11/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
[vagrant@nfss upload]$ sudo showmount -a 192.168.50.10
All mount points on 192.168.50.10:
192.168.50.11:/srv/share
```
Повторно перезапускаем клиент и проводим проверку
```
[vagrant@nfsc upload]$ sudo reboot
Connection to 127.0.0.1 closed by remote host.
Connection to 127.0.0.1 closed.
[topper@fedora NFS]$ vagrant ssh nfsc
Last login: Thu May 26 19:46:06 2022 from 10.0.2.2
sudo showmount -a 192.168.50.10
All mount points on 192.168.50.10:
[vagrant@nfsc ~]$ cd /mnt/upload
[vagrant@nfsc upload]$ sudo mount | grep mnt
systemd-1 on /mnt type autofs (rw,relatime,fd=21,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=11007)
192.168.50.10:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.50.10,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.50.10)
[vagrant@nfsc upload]$ ls
check_file  client_file
[vagrant@nfsc upload]$ sudo touch final_check
[vagrant@nfsc upload]$ ls
check_file  client_file  final_check
```
На сервере
```
[vagrant@nfss upload]$ ls
check_file  client_file  final_check
```
