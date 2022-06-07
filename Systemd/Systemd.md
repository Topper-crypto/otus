#Домашнее задание

Выполнить следующие задания и подготовить развёртывание результата выполнения с использованием Vagrant и Vagrant shell provisioner (или Ansible, на Ваше усмотрение):

1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig).
2. Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).
3. Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами. 

4*. Скачать демо-версию Atlassian Jira и переписать основной скрипт запуска на unit-файл.

### Задача 1
```
[root@localhost ~]# nano /etc/sysconfig/watchlog
```
```
[root@localhost ~]# nano /var/log/watchlog.log
```
```
[root@localhost ~]# nano /opt/watchlog.sh
```
```
[root@localhost ~]# chmod +x /opt/watchlog.sh
```
```
[root@localhost ~]# nano /etc/systemd/system/watchlog.service
```
```
[root@localhost ~]# nano /etc/systemd/system/watchlog.timer
```
```
[root@localhost ~]# systemctl enable watchlog.timer
[root@localhost ~]# systemctl enable watchlog.service
```
```
[root@localhost ~]# systemctl daemon-reload
```
```
[root@localhost ~]# systemctl start watchlog.timer
[root@localhost ~]# systemctl start watchlog.service
```
Для теста скрипт запускается каждые 5 сек.
```
[root@localhost ~]# tail -f /var/log/messages
Jun  6 22:10:51 localhost systemd: Reloading.
Jun  6 22:10:51 localhost systemd: Starting My watchlog service...
Jun  6 22:10:51 localhost root: Mon Jun  6 22:10:51 MSK 2022: I found word, Master!
Jun  6 22:10:51 localhost systemd: Started My watchlog service.
Jun  6 22:10:56 localhost systemd: Starting My watchlog service...
Jun  6 22:10:56 localhost root: Mon Jun  6 22:10:56 MSK 2022: I found word, Master!
Jun  6 22:10:56 localhost systemd: Started My watchlog service.
Jun  6 22:10:56 localhost systemd: Starting My watchlog service...
Jun  6 22:10:56 localhost root: Mon Jun  6 22:10:56 MSK 2022: I found word, Master!
Jun  6 22:10:56 localhost systemd: Started My watchlog service.
Jun  6 22:11:24 localhost systemd: Starting My watchlog service...
Jun  6 22:11:24 localhost root: Mon Jun  6 22:11:24 MSK 2022: I found word, Master!
Jun  6 22:11:24 localhost systemd: Started My watchlog service.
```
### Задача 2
```
[root@localhost ~]# yum install epel-release -y && yum install spawn-fcgi php php-climod_fcgid httpd -y
```
```
[root@localhost ~]#  nano /etc/sysconfig/spawn-fcgi
```
```
[root@localhost ~]# nano /etc/systemd/system/spawn-fcgi.service
```
```
[root@localhost ~]# systemctl daemon-reload
```
```
[root@localhost ~]# systemctl start spawn-fcgi
```
```
[root@localhost ~]# systemctl status spawn-fcgi
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2022-06-07 18:41:20 MSK; 8s ago
 Main PID: 1566 (php-cgi)
   CGroup: /system.slice/spawn-fcgi.service
           ├─1566 /usr/bin/php-cgi
           ├─1567 /usr/bin/php-cgi
           ├─1568 /usr/bin/php-cgi
           ├─1569 /usr/bin/php-cgi
           ├─1570 /usr/bin/php-cgi
           ├─1571 /usr/bin/php-cgi
           ├─1572 /usr/bin/php-cgi
           ├─1573 /usr/bin/php-cgi
           ├─1574 /usr/bin/php-cgi
           ├─1575 /usr/bin/php-cgi
           ├─1576 /usr/bin/php-cgi
           ├─1577 /usr/bin/php-cgi
           ├─1578 /usr/bin/php-cgi
           ├─1579 /usr/bin/php-cgi
           ├─1580 /usr/bin/php-cgi
           ├─1581 /usr/bin/php-cgi
           ├─1582 /usr/bin/php-cgi
           ├─1583 /usr/bin/php-cgi
           ├─1584 /usr/bin/php-cgi
           ├─1585 /usr/bin/php-cgi
           ├─1586 /usr/bin/php-cgi
           ├─1587 /usr/bin/php-cgi
           ├─1588 /usr/bin/php-cgi
           ├─1589 /usr/bin/php-cgi
           ├─1590 /usr/bin/php-cgi
           ├─1591 /usr/bin/php-cgi
           ├─1592 /usr/bin/php-cgi
           ├─1593 /usr/bin/php-cgi
           ├─1594 /usr/bin/php-cgi
           ├─1595 /usr/bin/php-cgi
           ├─1596 /usr/bin/php-cgi
           ├─1597 /usr/bin/php-cgi
           └─1598 /usr/bin/php-cgi

Jun 07 18:41:20 localhost.localdomain systemd[1]: Started Spawn-fcgi startup service by Otus.
```
### Задача 3
```
[root@localhost ~]# cp /usr/lib/systemd/system/httpd.service /etc/systemd/system
```
```
[root@localhost ~]# mv /etc/systemd/system/httpd.service /etc/systemd/system/httpd@.service
```
```
[root@localhost ~]# nano /etc/systemd/system/httpd@.service
```
```
[root@localhost ~]# nano /etc/sysconfig/httpd-first
```
```
[root@localhost ~]# nano /etc/sysconfig/httpd-second
```
```
[root@localhost ~]# mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
```
```
[root@localhost ~]# cp /etc/httpd/conf/first.conf /etc/httpd/conf/second.conf
```
```
[root@localhost ~]# sed -i '43iPidFile  \/var\/run\/httpd-second.pid' /etc/httpd/conf/second.conf
[root@localhost ~]# sed -i  '42 s/80/8080/1' /etc/httpd/conf/second.conf
```
```
[root@localhost ~]# systemctl daemon-reload
```
```
[root@localhost ~]# systemctl start httpd@first
[root@localhost ~]# systemctl start httpd@second
```
```
[root@localhost ~]# systemctl status httpd@first.service
● httpd@first.service - The Apache HTTP Server
   Loaded: loaded (/etc/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2022-06-07 19:20:19 MSK; 32s ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 1860 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@first.service
           ├─1860 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─1861 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─1862 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─1863 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─1864 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           └─1865 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND

Jun 07 19:20:19 localhost.localdomain systemd[1]: Starting The Apache HTTP Server...
Jun 07 19:20:19 localhost.localdomain httpd[1860]: AH00558: httpd: Could not reliably determine...geJun 07 19:20:19 localhost.localdomain systemd[1]: Started The Apache HTTP Server.
Hint: Some lines were ellipsized, use -l to show in full.
```
```
[root@localhost ~]# systemctl status httpd@second.service
● httpd@second.service - The Apache HTTP Server
   Loaded: loaded (/etc/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2022-06-07 19:20:24 MSK; 45s ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 1872 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@second.service
           ├─1872 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─1873 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─1874 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─1875 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─1876 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           └─1877 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND

Jun 07 19:20:24 localhost.localdomain systemd[1]: Starting The Apache HTTP Server...
Jun 07 19:20:24 localhost.localdomain httpd[1872]: AH00558: httpd: Could not reliably determine...geJun 07 19:20:24 localhost.localdomain systemd[1]: Started The Apache HTTP Server.
Hint: Some lines were ellipsized, use -l to show in full.
```
```
[root@localhost ~]# netstat -tunap
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp6       0      0 :::8080                 :::*                    LISTEN      1872/httpd          
tcp6       0      0 :::80                   :::*                    LISTEN      1860/httpd          
```
