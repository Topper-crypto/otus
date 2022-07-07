# Домашнее задание

### Описание/Пошаговая инструкция выполнения домашнего задания:

> 1. Запустить nginx на нестандартном порту 3-мя разными способами:
> 
> * переключатели setsebool;
> * добавление нестандартного порта в имеющийся тип;
> * формирование и установка модуля SELinux. 
> 
> К сдаче: 
> * README с описанием каждого решения (скриншоты и демонстрация приветствуются).
>  
> 2. Обеспечить работоспособность приложения при включенном selinux.
> * развернуть приложенный стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems;
> * выяснить причину неработоспособности механизма обновления зоны (см. README);
> * предложить решение (или решения) для данной проблемы;
> * выбрать одно из решений для реализации, предварительно обосновав выбор;
> * реализовать выбранное решение и продемонстрировать его работоспособность. 
> 
> К сдаче:
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

Причина неработоспособности механизма обновления заключается в том что Selinux блокировал доступ к обновлению файлов динамического обновления для DNS сервера, а также к некоторым файлам ОС, к которым DNS сервер обращается во время своей работы.

Варианты решения данной проблемы:
1. Выключить Selinux совсем (не рекомендуется)
2. Удалить файл с расширением .jnl (или прописать контекст безопасности), куда записываются динамические обновления зоны. Так как прежде чем данные попадают в .jnl файл, они сначала записываются во временный файл tmp, для которого может срабатывать блокировка, поэтому tmp файлы также рекомендуется или удалить или прописать им контекст безопасности. Изменить контекст тех файлов, к которым DNS серверу затруднен доступ командам `semanage fcontext -a -t FILE_TYPE named.ddns.lab.view1.jnl`, где назначить файлам один из следующих типов контекста безопасности `dnssec_trigger_var_run_t, ipa_var_lib_t, krb5_host_rcache_t, krb5_keytab_t`, `named_cache_t, named_log_t`, `named_tmp_t, named_var_run_t`, `named_zone_t`, и затем выполнить запись контекста в ядро `restorecon -v named.ddns.lab.view1.jnl`.

3. Использовать изменения контекста безопасности для файлов SELINUX (просмотр контекста на файлах и директориях `ls -lZ`), к которым обращается `BIND`.

Вариант 3
```
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
update failed: SERVFAIL
> quit
```
Изменения внести не получилось. С помошью утилиты audit2why просмотрим логи SELinux на `client`.  Ошибок не обнаружено.

Подключимся к серверу ns01 и проверим логи SELinux

В логах мы видим, что ошибка в контексте безопасности. Вместо типа named_t используется тип etc_t.
```
[root@ns01 ~]# cat /var/log/audit/audit.log | audit2why
type=AVC msg=audit(1657222066.221:1871): avc:  denied  { create } for  pid=5018 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0

        Was caused by:
                Missing type enforcement (TE) allow rule.

                You can use audit2allow to generate a loadable module to allow this access.
```

B каталоге `/etc/named` также видим, что контекст безопасности неправильный. 
```
[root@ns01 ~]# ls -laZ /etc/named
drw-rwx---. root named system_u:object_r:etc_t:s0       .
drwxr-xr-x. root root  system_u:object_r:etc_t:s0       ..
drw-rwx---. root named unconfined_u:object_r:etc_t:s0   dynamic
-rw-rw----. root named system_u:object_r:etc_t:s0       named.50.168.192.rev
-rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab
-rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab.view1
-rw-rw----. root named system_u:object_r:etc_t:s0       named.newdns.lab
```
Проблема заключается в том, что конфигурационные файлы лежат в другом каталоге. Посмотреть в каком каталоги должны лежать, файлы, чтобы на них распространялись правильные политики SELinux
```
[root@ns01 ~]#  sudo semanage fcontext -l | grep named
/etc/rndc.*                                        regular file       system_u:object_r:named_conf_t:s0
/var/named(/.*)?                                   all files          system_u:object_r:named_zone_t:s0 
```
Изменим тип контекста безопасности для каталога /etc/named
```
[root@ns01 ~]# sudo chcon -R -t named_zone_t /etc/named
```
```
[root@ns01 ~]# ls -laZ /etc/named
drw-rwx---. root named system_u:object_r:named_zone_t:s0 .
drwxr-xr-x. root root  system_u:object_r:etc_t:s0       ..
drw-rwx---. root named unconfined_u:object_r:named_zone_t:s0 dynamic
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.50.168.192.rev
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab.view1
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.newdns.lab
```
Проведем проверку на `client`
```
[root@client ~]# nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
> quit
```
```
[root@client ~]# dig www.ddns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.9 <<>> www.ddns.lab
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 24289
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.ddns.lab.                  IN      A

;; ANSWER SECTION:
www.ddns.lab.           60      IN      A       192.168.50.15

;; AUTHORITY SECTION:
ddns.lab.               3600    IN      NS      ns01.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.           3600    IN      A       192.168.50.10

;; Query time: 1 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Thu Jul 07 19:53:18 UTC 2022
;; MSG SIZE  rcvd: 96
```
Изменения применились. Перезагружаем хосты и делаем запрос
```
[root@client ~]# dig @192.168.50.10 www.ddns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.9 <<>> @192.168.50.10 www.ddns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 1518
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.ddns.lab.                  IN      A

;; ANSWER SECTION:
www.ddns.lab.           60      IN      A       192.168.50.15

;; AUTHORITY SECTION:
ddns.lab.               3600    IN      NS      ns01.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.           3600    IN      A       192.168.50.10

;; Query time: 0 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Thu Jul 07 19:56:40 UTC 2022
;; MSG SIZE  rcvd: 96
```
Всё правильно. После перезагрузки настройки сохранились.
