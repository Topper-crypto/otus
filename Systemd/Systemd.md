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
Created symlink from /etc/systemd/system/multi-user.target.wants/watchlog.timer to /etc/systemd/system/watchlog.timer.
```
```
[root@localhost ~]# systemctl start watchlog.timer
```
```
[topper@fedora ~]$ sudo tail -f /var/log/messages

```
### Задача 2


### Задача 3
### Решение:

### Задача 4
### Решение:
