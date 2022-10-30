# Домашнее задание
репликация postgres

## Описание/Пошаговая инструкция выполнения домашнего задания:
* настроить hot_standby репликацию с использованием слотов
* настроить правильное резервное копирование

Для сдачи работы присылаем ссылку на репозиторий, в котором должны обязательно быть

* Vagranfile (2 машины)
* плейбук Ansible
* конфигурационные файлы postgresql.conf, pg_hba.conf и recovery.conf,
* конфиг barman, либо скрипт резервного копирования.

Команда "vagrant up" должна поднимать машины с настроенной репликацией и резервным копированием.

Рекомендуется в README.md файл вложить результаты (текст или скриншоты) проверки работы репликации и резервного копирования.

## Решение:
1. Запуск
```
vagrant up
```
2. Проверка работы
* Master



* Slave



* Backup
```yaml
[vagrant@backup ~]$ sudo su
[root@backup vagrant]# barman switch-xlog --force --archive master
The WAL file 000000010000000000000003 has been closed on server 'master'
Waiting for the WAL file 000000010000000000000003 from server 'master' (max: 30 seconds)
Processing xlog segments from file archival for master
	000000010000000000000003
[root@backup vagrant]# barman check master
Server master:
	PostgreSQL: OK
	superuser or standard user with backup privileges: OK
	PostgreSQL streaming: OK
	wal_level: OK
	replication slot: OK
	directories: OK
	retention policy settings: OK
	backup maximum age: OK (no last_backup_maximum_age provided)
	compression settings: OK
	failed backups: OK (there are 0 failed backups)
	minimum redundancy requirements: OK (have 0 backups, expected at least 0)
	pg_basebackup: OK
	pg_basebackup compatible: OK
	pg_basebackup supports tablespaces mapping: OK
	systemid coherence: OK (no system Id stored on disk)
	pg_receivexlog: OK
	pg_receivexlog compatible: OK
	receive-wal running: OK
	archive_mode: OK
	archive_command: OK
	continuous archiving: OK
	archiver errors: OK
[root@backup vagrant]# barman backup master
Starting backup using postgres method for server master in /var/lib/barman/master/base/20221030T161833
Backup start at LSN: 0/4000060 (000000010000000000000004, 00000060)
Starting backup copy via pg_basebackup for 20221030T161833
Copy done (time: 2 seconds)
Finalising the backup.
This is the first backup for server master
WAL segments preceding the current backup have been found:
	000000010000000000000001 from server master has been removed
	000000010000000000000002 from server master has been removed
	000000010000000000000002.00000060.backup from server master has been removed
	000000010000000000000003 from server master has been removed
Backup size: 30.1 MiB
Backup end at LSN: 0/6000000 (000000010000000000000005, 00000000)
Backup completed (start time: 2022-10-30 16:18:33.649025, elapsed time: 2 seconds)
Processing xlog segments from streaming for master
	000000010000000000000004
Processing xlog segments from file archival for master
	000000010000000000000004
	000000010000000000000005
	000000010000000000000005.00000028.backup
[root@backup vagrant]# barman check master
Server master:
	PostgreSQL: OK
	superuser or standard user with backup privileges: OK
	PostgreSQL streaming: OK
	wal_level: OK
	replication slot: OK
	directories: OK
	retention policy settings: OK
	backup maximum age: OK (no last_backup_maximum_age provided)
	compression settings: OK
	failed backups: OK (there are 0 failed backups)
	minimum redundancy requirements: OK (have 1 backups, expected at least 0)
	pg_basebackup: OK
	pg_basebackup compatible: OK
	pg_basebackup supports tablespaces mapping: OK
	systemid coherence: OK
	pg_receivexlog: OK
	pg_receivexlog compatible: OK
	receive-wal running: OK
	archive_mode: OK
	archive_command: OK
	continuous archiving: OK
	archiver errors: OK
[root@backup vagrant]# barman status master
Server master:
	Description: PostgreSQL Backup
	Active: True
	Disabled: False
	PostgreSQL version: 11.8
	Cluster state: in production
	pgespresso extension: Not available
	Current data size: 30.4 MiB
	PostgreSQL Data directory: /var/lib/pgsql/11/data
	Current WAL segment: 000000010000000000000006
	PostgreSQL 'archive_command' setting: barman-wal-archive backup master %p
	Last archived WAL: 000000010000000000000005.00000028.backup, at Sun Oct 30 16:24:04 2022
	Failures of WAL archiver: 9 (000000010000000000000001 at Sun Aug 30 16:18:33 2022)
	Server WAL archiving rate: 55.59/hour
	Passive node: False
	Retention policies: not enforced
	No. of available backups: 1
	First available backup: 20221030T161833
	Last available backup: 20221030T161833
	Minimum redundancy requirements: satisfied (1/0)
[root@backup vagrant]# barman backup master
Starting backup using postgres method for server master in /var/lib/barman/master/base/20221030T161941
Backup start at LSN: 0/60000C8 (000000010000000000000006, 000000C8)
Starting backup copy via pg_basebackup for 20221030T161941
Copy done (time: 3 seconds)
Finalising the backup.
Backup size: 30.1 MiB
Backup end at LSN: 0/8000000 (000000010000000000000007, 00000000)
Backup completed (start time: 2022-10-30 161:19:41.099352, elapsed time: 3 seconds)
Processing xlog segments from streaming for master
	000000010000000000000006
Processing xlog segments from file archival for master
	000000010000000000000006
	000000010000000000000007
	000000010000000000000007.00000028.backup
[root@backup vagrant]# barman replication-status master
Status of streaming clients for server 'master':
  Current LSN on master: 0/80000C8
  Number of streaming clients: 2

  1. Async standby
     Application name: walreceiver
     Sync stage      : 5/5 Hot standby (max)
     Communication   : TCP/IP
     IP Address      : 192.168.1.20 / Port: 54334 / Host: -
     User name       : streaming_user
     Current state   : streaming (async)
     Replication slot: standby_slot
     WAL sender PID  : 7178
     Started at      : 2022-10-30 16:22:27.577549+00:00
     Sent LSN   : 0/80000C8 (diff: 0 B)
     Write LSN  : 0/80000C8 (diff: 0 B)
     Flush LSN  : 0/80000C8 (diff: 0 B)
     Replay LSN : 0/80000C8 (diff: 0 B)

  2. Async WAL streamer
     Application name: barman_receive_wal
     Sync stage      : 3/3 Remote write
     Communication   : TCP/IP
     IP Address      : 192.168.1.30 / Port: 44788 / Host: -
     User name       : barman_streaming_user
     Current state   : streaming (async)
     Replication slot: barman
     WAL sender PID  : 7365
     Started at      : 2022-10-30 16:24:04.542353+00:00
     Sent LSN   : 0/80000C8 (diff: 0 B)
     Write LSN  : 0/80000C8 (diff: 0 B)
     Flush LSN  : 0/8000000 (diff: -200 B)
```
