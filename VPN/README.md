# Мосты, туннели и VPN

## Домашнее задание

VPN

### Описание/Пошаговая инструкция выполнения домашнего задания:

1. Между двумя виртуалками поднять vpn в режимах
* tun;
* tap;

Прочуствовать разницу.

2. Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку.

3. Самостоятельно изучить, поднять ocserv и подключиться с хоста к виртуалке

### Решение:

TUN и TAP

в папках tun и tap соотвествующие стенды

Основноное отличие это работа на разных уровнях OSI tap - l2, tun -l3. Подходит для объединения сетей. TAP - броадкасты, arp, подходит для бриджа, ethernet фреймы TUN - l3 работает c ip пакетами, поддерживает маршрутизацию . Подходит для подключения client- server

Генерация ключей и сертификатов

gen CA
```
openssl genrsa -out ca.key 4096
openssl req -new -x509 -days 365 -key ca.key -out ca.crt
```
gen srv
```
openssl genrsa -out server.key 4096
openssl req -new -key server.key -out server.csr
openssl x509 -req -days 365  -CA ca.crt -CAkey ca.key -set_serial 01 -extensions req_ext -in server.csr -out server.crt
```
gen client
```
openssl genrsa -out client.key 4096
openssl req -new -key client.key -out client.csr
openssl x509 -req -days 365  -CA ca.crt -CAkey ca.key -set_serial 01 -extensions req_ext -in client.csr -out client.crt
```
Diffie hellman pem
```
openssl dhparam -out dhparams.pem 2048
```
