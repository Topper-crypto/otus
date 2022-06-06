#Домашнее задание

Выполнить следующие задания и подготовить развёртывание результата выполнения с использованием Vagrant и Vagrant shell provisioner (или Ansible, на Ваше усмотрение):

1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig).
2. Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).
3. Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами. 
4. Скачать демо-версию Atlassian Jira и переписать основной скрипт запуска на unit-файл.

### Задача 1
```
[topper@fedora ~]$ sudo nano /etc/sysconfig/watchlog
```
```
# Configuration file for my watchdog service
# Place it to /etc/sysconfig
# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log
```
```
[topper@fedora ~]$ sudo nano /var/log/watchlog.log
```
```
ALERT
```
```
[topper@fedora ~]$ sudo nano /opt/watchlog.sh
```

### Задача 2
### Решение:

### Задача 3
### Решение:

### Задача 4
### Решение:
