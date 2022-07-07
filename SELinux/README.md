# Домашнее задание

### Описание/Пошаговая инструкция выполнения домашнего задания:

> 1. Запустить nginx на нестандартном порту 3-мя разными способами:
> 
> * переключатели setsebool;
> * добавление нестандартного порта в имеющийся тип;
> * формирование и установка модуля SELinux. 
> 
> К сдаче:> 
> * README с описанием каждого решения (скриншоты и демонстрация приветствуются).
>  
> 2. Обеспечить работоспособность приложения при включенном selinux.
> * развернуть приложенный стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems;
> * выяснить причину неработоспособности механизма обновления зоны (см. README);
> * предложить решение (или решения) для данной проблемы;
> * выбрать одно из решений для реализации, предварительно обосновав выбор;
> * реализовать выбранное решение и продемонстрировать его работоспособность. К сдаче:
> * README с анализом причины неработоспособности, возможными способами решения и обоснованием выбора одного из них;
> * исправленный стенд или демонстрация работоспособной системы скриншотами и описанием.

### Задача 1

В конфиге nginx меняем порт на 8056

Перезапускаем nginx
```
[root@selinux ~]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.
```
Вариант 1

```
[root@selinux ~]# yum install policycoreutils-python setroubleshoot
```
```
[root@selinux ~]# cat /var/log/audit/audit.log |grep src
type=AVC msg=audit(1657214362.961:777): avc:  denied  { name_bind } for  pid=2739 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
```
```
[root@selinux ~]# grep 1657214362.961:777 /var/log/audit/audit.log | audit2why
type=AVC msg=audit(1657214362.961:777): avc:  denied  { name_bind } for  pid=2739 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

        Was caused by:
        The boolean nis_enabled was set incorrectly. 
        Description:
        Allow nis to enabled

        Allow access by executing:
        # setsebool -P nis_enabled 1
```
```
[root@selinux ~]# setsebool -P nis_enabled on
```
```
[root@selinux ~]# systemctl restart nginx
```
```
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2022-07-07 17:43:07 UTC; 8s ago
  Process: 3174 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3172 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 3171 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3176 (nginx)
   CGroup: /system.slice/nginx.service
           ├─3176 nginx: master process /usr/sbin/nginx
           └─3178 nginx: worker process

Jul 07 17:43:07 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jul 07 17:43:07 selinux nginx[3172]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jul 07 17:43:07 selinux nginx[3172]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Jul 07 17:43:07 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
```

Вариант 2

```
[root@selinux ~]# semanage port -l |grep 80
http_port_t                    tcp      4881, 80, 81, 443, 488, 8008, 8009, 8443, 9000
```
```
root@selinux ~]# semanage port -a -t http_port_t -p tcp 8056
```
```
[root@selinux ~]# semanage port -l |grep 8056
http_port_t                    tcp      8056, 4881, 80, 81, 443, 488, 8008, 8009, 8443, 9000
```
```
[root@selinux ~]# systemctl restart nginx
```
```
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2022-07-07 18:20:06 UTC; 5s ago
  Process: 22458 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 22456 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 22454 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 22460 (nginx)
   CGroup: /system.slice/nginx.service
           ├─22460 nginx: master process /usr/sbin/nginx
           └─22462 nginx: worker process

Jul 07 18:20:06 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jul 07 18:20:06 selinux nginx[22456]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jul 07 18:20:06 selinux nginx[22456]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Jul 07 18:20:06 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
```

Вариант 3

```
[root@selinux ~]# grep nginx /var/log/audit/audit.log | audit2allow -M nginx
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i nginx.pp
```
```
[root@selinux ~]# semodule -i nginx.pp
```
```
[root@selinux ~]# systemctl restart nginx
```
```
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2022-07-07 18:39:14 UTC; 12s ago
  Process: 22594 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 22591 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 22590 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 22596 (nginx)
   CGroup: /system.slice/nginx.service
           ├─22596 nginx: master process /usr/sbin/nginx
           └─22597 nginx: worker process

Jul 07 18:39:14 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jul 07 18:39:14 selinux nginx[22591]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jul 07 18:39:14 selinux nginx[22591]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Jul 07 18:39:14 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
```

### Задача 2
