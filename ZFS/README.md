# Стенд с Vagrant c ZFS
> 1. Определить алгоритм с наилучшим сжатием
> 
> * Определить какие алгоритмы сжатия поддерживает zfs (gzip, zle, lzjb, lz4);
> * Создать 4 файловых системы на каждой применить свой алгоритм  сжатия;
> * Для сжатия использовать либо текстовый файл, либо группу файлов:
> 2. Определить настройки пула
> 
> С помощью команды zfs import собрать pool ZFS;
> 
> Командами zfs определить настройки:
> * размер хранилища;
> * тип pool;
> * значение recordsize;
> * какое сжатие используется;
> * какая контрольная сумма используется.
> 
> 3. Работа со снапшотами
> * скопировать файл из удаленной директории.
> 
> https://drive.google.com/file/d/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG/view?usp=sharing
> 
> * восстановить файл локально. zfs receive
> * найти зашифрованное сообщение в файле secret_message

### Решение
1. Определение алгоритма с наилучшим сжатием

```
[root@zfs ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   40G  0 disk 
└─sda1   8:1    0   40G  0 part /
sdb      8:16   0  512M  0 disk 
sdc      8:32   0  512M  0 disk 
sdd      8:48   0  512M  0 disk 
sde      8:64   0  512M  0 disk 
sdf      8:80   0  512M  0 disk 
sdg      8:96   0  512M  0 disk 
sdh      8:112  0  512M  0 disk 
sdi      8:128  0  512M  0 disk 
```
```
[root@zfs ~]# zpool list
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus1   480M   100K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus2   480M   100K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus3   480M   100K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus4   480M   100K   480M        -         -     0%     0%  1.00x    ONLINE  -
```
```
[root@zfs ~]# zpool status
  pool: otus1
 state: ONLINE
config:
        NAME        STATE     READ WRITE CKSUM
        otus1       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdb     ONLINE       0     0     0
            sdc     ONLINE       0     0     0
errors: No known data errors

  pool: otus2
 state: ONLINE
config:
        NAME        STATE     READ WRITE CKSUM
        otus2       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdd     ONLINE       0     0     0
            sde     ONLINE       0     0     0
errors: No known data errors

  pool: otus3
 state: ONLINE
config:
        NAME        STATE     READ WRITE CKSUM
        otus3       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdf     ONLINE       0     0     0
            sdg     ONLINE       0     0     0
errors: No known data errors

  pool: otus4
 state: ONLINE
config:
        NAME        STATE     READ WRITE CKSUM
        otus4       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdh     ONLINE       0     0     0
            sdi     ONLINE       0     0     0
errors: No known data errors
```
```
[root@zfs ~]# zfs get all | grep compression
otus1  compression           lzjb                       local
otus2  compression           lz4                        local
otus3  compression           gzip-9                     local
otus4  compression           zle                        local
```
```
[root@zfs ~]# for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
--2022-05-23 22:26:50--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Распознаётся gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Подключение к gutenberg.org (gutenberg.org)|152.19.134.47|:443... соединение установлено.
HTTP-запрос отправлен. Ожидание ответа... 200 OK
Длина: 40809473 (39M) [text/plain]
Сохранение в: «/otus1/pg2600.converter.log»

100%[============================================================>] 40 809 473  7,10MB/s   за 6,2s
...
```
```
[root@zfs ~]# ls -l /otus1
итого 22020
-rw-r--r--. 1 root root 40809473 май  2 08:01 pg2600.converter.log
[root@zfs ~]# ls -l /otus2
итого 17972
-rw-r--r--. 1 root root 40809473 май  2 08:01 pg2600.converter.log
[root@zfs ~]# ls -l /otus3
итого 10949
-rw-r--r--. 1 root root 40809473 май  2 08:01 pg2600.converter.log
[root@zfs ~]# ls -l /otus4
итого 39881
-rw-r--r--. 1 root root 40809473 май  2 08:01 pg2600.converter.log
```
```
[root@zfs ~]# zfs list
NAME    USED  AVAIL     REFER  MOUNTPOINT
otus1  21.6M   330M     21.5M  /otus1
otus2  17.7M   334M     17.6M  /otus2
otus3  10.8M   341M     10.7M  /otus3
otus4  39.1M   313M     39.0M  /otus4
```
```
[root@zfs ~]# zfs get all | grep compressratio | grep -v ref
otus1  compressratio         1.81x                      -
otus2  compressratio         2.22x                      -
otus3  compressratio         3.64x                      -
otus4  compressratio         1.00x                      -
```
Вывод: алгоритм gzip-9 самый эффективный по сжатию

2. Определение настроек пула
```
[root@zfs ~]# wget -O archive.tar.gz --no-check-certificate 'https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&e
> xport=download'
--2022-05-23 22:37:06--  https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&e%0Axport=download
Распознаётся drive.google.com (drive.google.com)... 64.233.163.194, 2a00:1450:4010:c06::c2
Подключение к drive.google.com (drive.google.com)|64.233.163.194|:443... соединение установлено.
HTTP-запрос отправлен. Ожидание ответа... 302 Found
Адрес: https://drive.google.com/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&e%0Axport=download [переход]
--2022-05-23 22:37:06--  https://drive.google.com/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&e%0Axport=download
Повторное использование соединения с drive.google.com:443.
HTTP-запрос отправлен. Ожидание ответа... 303 See Other
Адрес: https://doc-0c-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/eooirjv8j2hbdtrrnforfevr3ekjmrvs/1653345375000/16189157874053420687/*/1KRBNW33QWqbvbVHa3hLJivOAt60yukkg [переход]
Предупреждение: в HTTP маски не поддерживаются.
--2022-05-23 22:37:09--  https://doc-0c-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/eooirjv8j2hbdtrrnforfevr3ekjmrvs/1653345375000/16189157874053420687/*/1KRBNW33QWqbvbVHa3hLJivOAt60yukkg
Распознаётся doc-0c-bo-docs.googleusercontent.com (doc-0c-bo-docs.googleusercontent.com)... 173.194.221.132, 2a00:1450:4010:c0a::84
Подключение к doc-0c-bo-docs.googleusercontent.com (doc-0c-bo-docs.googleusercontent.com)|173.194.221.132|:443... соединение установлено.
HTTP-запрос отправлен. Ожидание ответа... 200 OK
Длина: 7275140 (6,9M) [application/x-gzip]
Сохранение в: «archive.tar.gz»

100%[====================================================================================>] 7 275 140   32,5MB/s   за 0,2s   

2022-05-23 22:37:10 (32,5 MB/s) - «archive.tar.gz» сохранён [7275140/7275140]
```
```
[root@zfs ~]# tar -xzvf archive.tar.gz
zpoolexport/
zpoolexport/filea
zpoolexport/fileb
```
```
[root@zfs ~]# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
status: Some supported features are not enabled on the pool.
 action: The pool can be imported using its name or numeric identifier, though
        some features will not be available without an explicit 'zpool upgrade'.
 config:

        otus                         ONLINE
          mirror-0                   ONLINE
            /root/zpoolexport/filea  ONLINE
            /root/zpoolexport/fileb  ONLINE
```
```
[root@zfs ~]# zpool status
  pool: otus
 state: ONLINE
status: Some supported features are not enabled on the pool. The pool can
        still be used, but some features are unavailable.
action: Enable all features using 'zpool upgrade'. Once this is done,
        the pool may no longer be accessible by software that does not support
        the features. See zpool-features(5) for details.
config:

        NAME                         STATE     READ WRITE CKSUM
        otus                         ONLINE       0     0     0
          mirror-0                   ONLINE       0     0     0
            /root/zpoolexport/filea  ONLINE       0     0     0
            /root/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors

  pool: otus1
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus1       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdb     ONLINE       0     0     0
            sdc     ONLINE       0     0     0

errors: No known data errors

  pool: otus2
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus2       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdd     ONLINE       0     0     0
            sde     ONLINE       0     0     0

errors: No known data errors

  pool: otus3
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus3       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdf     ONLINE       0     0     0
            sdg     ONLINE       0     0     0

errors: No known data errors

  pool: otus4
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus4       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdh     ONLINE       0     0     0
            sdi     ONLINE       0     0     0

errors: No known data errors
```
```
[root@zfs ~]# zpool get all otus
NAME  PROPERTY                       VALUE                          SOURCE
otus  size                           480M                           -
otus  capacity                       0%                             -
otus  altroot                        -                              default
otus  health                         ONLINE                         -
otus  guid                           6554193320433390805            -
otus  version                        -                              default
otus  bootfs                         -                              default
otus  delegation                     on                             default
otus  autoreplace                    off                            default
otus  cachefile                      -                              default
otus  failmode                       wait                           default
otus  listsnapshots                  off                            default
otus  autoexpand                     off                            default
otus  dedupratio                     1.00x                          -
otus  free                           478M                           -
otus  allocated                      2.09M                          -
otus  readonly                       off                            -
otus  ashift                         0                              default
otus  comment                        -                              default
otus  expandsize                     -                              -
otus  freeing                        0                              -
otus  fragmentation                  0%                             -
otus  leaked                         0                              -
otus  multihost                      off                            default
otus  checkpoint                     -                              -
otus  load_guid                      12399202586432011524           -
otus  autotrim                       off                            default
otus  feature@async_destroy          enabled                        local
otus  feature@empty_bpobj            active                         local
otus  feature@lz4_compress           active                         local
otus  feature@multi_vdev_crash_dump  enabled                        local
otus  feature@spacemap_histogram     active                         local
otus  feature@enabled_txg            active                         local
otus  feature@hole_birth             active                         local
otus  feature@extensible_dataset     active                         local
otus  feature@embedded_data          active                         local
otus  feature@bookmarks              enabled                        local
otus  feature@filesystem_limits      enabled                        local
otus  feature@large_blocks           enabled                        local
otus  feature@large_dnode            enabled                        local
otus  feature@sha512                 enabled                        local
otus  feature@skein                  enabled                        local
otus  feature@edonr                  enabled                        local
otus  feature@userobj_accounting     active                         local
otus  feature@encryption             enabled                        local
otus  feature@project_quota          active                         local
otus  feature@device_removal         enabled                        local
otus  feature@obsolete_counts        enabled                        local
otus  feature@zpool_checkpoint       enabled                        local
otus  feature@spacemap_v2            active                         local
otus  feature@allocation_classes     enabled                        local
otus  feature@resilver_defer         enabled                        local
otus  feature@bookmark_v2            enabled                        local
otus  feature@redaction_bookmarks    disabled                       local
otus  feature@redacted_datasets      disabled                       local
otus  feature@bookmark_written       disabled                       local
otus  feature@log_spacemap           disabled                       local
otus  feature@livelist               disabled                       local
otus  feature@device_rebuild         disabled                       local
otus  feature@zstd_compress          disabled                       local
```
```
[root@zfs ~]# zfs get available otus
NAME  PROPERTY   VALUE  SOURCE
otus  available  350M   -
```
```
[root@zfs ~]# zfs get readonly otus
NAME  PROPERTY  VALUE   SOURCE
otus  readonly  off     default
```
```
[root@zfs ~]# zfs get recordsize otus
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local
```
```
[root@zfs ~]# zfs get compression otus
NAME  PROPERTY     VALUE           SOURCE
otus  compression  zle             local
```
```
[root@zfs ~]# zfs get checksum otus
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local
```
3. Работа со снапшотом, поиск сообщения от преподавателя
```
[root@zfs ~]# wget -O otus_task2.file --no-check-certificate 'https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&e xport=download'
--2022-05-23 23:06:30--  https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&e%20xport=download
Распознаётся drive.google.com (drive.google.com)... 64.233.163.194, 2a00:1450:4010:c06::c2
Подключение к drive.google.com (drive.google.com)|64.233.163.194|:443... соединение установлено.
HTTP-запрос отправлен. Ожидание ответа... 302 Found
Адрес: https://drive.google.com/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&e+xport=download [переход]
--2022-05-23 23:06:30--  https://drive.google.com/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&e+xport=download
Повторное использование соединения с drive.google.com:443.
HTTP-запрос отправлен. Ожидание ответа... 303 See Other
Адрес: https://doc-00-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/vjjeg6js2nks020r1eqmm7p73gfb1u0c/1653347175000/16189157874053420687/*/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG [переход]
Предупреждение: в HTTP маски не поддерживаются.
--2022-05-23 23:06:34--  https://doc-00-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/vjjeg6js2nks020r1eqmm7p73gfb1u0c/1653347175000/16189157874053420687/*/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG
Распознаётся doc-00-bo-docs.googleusercontent.com (doc-00-bo-docs.googleusercontent.com)... 173.194.221.132, 2a00:1450:4010:c0a::84
Подключение к doc-00-bo-docs.googleusercontent.com (doc-00-bo-docs.googleusercontent.com)|173.194.221.132|:443... соединение установлено.
HTTP-запрос отправлен. Ожидание ответа... 200 OK
Длина: 5432736 (5,2M) [application/octet-stream]
Сохранение в: «otus_task2.file»

100%[=============================================================================================================>] 5 432 736   29,7MB/s   за 0,2s   

2022-05-23 23:06:34 (29,7 MB/s) - «otus_task2.file» сохранён [5432736/5432736]
```
```
[root@zfs ~]# zfs receive otus/test@today < otus_task2.file
```
```
[root@zfs ~]# find /otus/test -name "secret_message"
/otus/test/task1/file_mess/secret_message
```
```
[root@zfs ~]# cat /otus/test/task1/file_mess/secret_message
https://github.com/sindresorhus/awesome
```
