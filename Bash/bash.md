# Домашнее задание

Написать скрипт для крона, который раз в час присылает на заданную почту:

* X IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
* Y запрашиваемых адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
* все ошибки c момента последнего запуска;
* список всех кодов возврата с указанием их кол-ва с момента последнего запуска. В письме должно быть прописан обрабатываемый временной диапазон и должна быть реализована защита от мультизапуска.

### Решение:
1. настройка mailx

```
ln -s /bin/mailx /bin/email
```
```
[root@server .certs]# nano /etc/mail.rc
```
В конце добавляем
```
set smtp=smtps://smtp.yandex.ru:465
set smtp-auth=login
set smtp-auth-user=test@td-minkom.ru
set smtp-auth-password=fujaviolumglqkmq
set ssl-verify=ignore
set nss-config-dir=/etc/pki/nssdb/
```
Проверка корректности настроек
```
echo "This is the body of the email" | mailx -vvv -s "Letter subject" -r "test@td-minkom.ru" -S smtp="smtp.yandex.ru" -a test.txt korovin80@ya.ru
```

