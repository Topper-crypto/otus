#Домашнее задание

Выполнить следующие задания и подготовить развёртывание результата выполнения с использованием Vagrant и Vagrant shell provisioner (или Ansible, на Ваше усмотрение):

1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig).
2. Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).
3. Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами. 
4. Скачать демо-версию Atlassian Jira и переписать основной скрипт запуска на unit-файл.

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


### Задача 3
### Решение:

### Задача 4
### Решение:
