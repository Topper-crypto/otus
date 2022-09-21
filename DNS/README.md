# DNS - настройка и обслуживание

## Домашнее задание

настраиваем split-dns

### Описание/Пошаговая инструкция выполнения домашнего задания:
* взять стенд https://github.com/erlong15/vagrant-bind
* добавить еще один сервер client2
* завести в зоне dns.lab
* имена
  * web1 - смотрит на клиент1
  * web2 - смотрит на клиент2
* завести еще одну зону newdns.lab
* завести в ней запись
* www - смотрит на обоих клиентов
* настроить split-dns
  * клиент1 - видит обе зоны, но в зоне dns.lab только web1
  * клиент2 видит только dns.lab
* настроить все без выключения selinux

### Решение:

Запустить стенд vagrant up для проверки работоспособности сплит dns проверим, работают ли DNS серверы в соотвествии с исходными данными.

клиент1 - видит обе зоны, но в зоне dns.lab только web1.

```yaml
[vagrant@client ~]$ nslookup web1 
Server:         192.168.50.10
Address:        192.168.50.10#53

Name:   web1.dns.lab
Address: 192.168.50.15
```
```yaml
[vagrant@client1 ~]$ nslookup web2
;; Got SERVFAIL reply from 192.168.50.10, trying next server
Server:         192.168.50.11
Address:        192.168.50.11#53

** server can't find web2: SERVFAIL
```
```yaml
[vagrant@client1 ~]$ nslookup www.newdns.lab
Server:         192.168.50.10
Address:        192.168.50.10#53

Name:   www.newdns.lab
Address: 192.168.50.15
Name:   www.newdns.lab
Address: 192.168.50.16
```

клиент2 видит только dns.lab

```yaml
[vagrant@client2 ~]$ nslookup www.newdns.lab
;; Got SERVFAIL reply from 192.168.50.10, trying next server
Server:         192.168.50.10
Address:        192.168.50.10#53

** server can't find www.newdns.lab: NXDOMAIN
```
```yaml
[vagrant@client2 ~]$ nslookup web1
Server:         192.168.50.10
Address:        192.168.50.10#53

Name:   web1.dns.lab
Address: 192.168.50.15
```
```yaml
[vagrant@client2 ~]$ nslookup web2
Server:         192.168.50.10
Address:        192.168.50.10#53

Name:   web2.dns.lab
Address: 192.168.50.16
```
