# Домашнее задание
репликация mysql

## Описание/Пошаговая инструкция выполнения домашнего задания:
1. В материалах приложены ссылки на вагрант для репликации и дамп базы bet.dmp
2. Базу развернуть на мастере и настроить так, чтобы реплицировались таблицы:

| bookmaker |
| competition |
| market |
| odds |
| outcome

3. Настроить GTID репликацию

Варианты которые принимаются к сдаче
* рабочий вагрантафайл
* скрины или логи SHOW TABLES
* конфиги
* пример в логе изменения строки и появления строки на реплике

## Решение:

* master
```yaml
yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm -y
yum install Percona-Server-server-57 -y
cp /vagrant/conf/conf.d/* /etc/my.cnf.d/
systemctl start mysql
cat /var/log/mysqld.log | grep 'root@localhost:' | awk '{print $11}'
mysql -uroot -p'o4u!iEOYi9Im'
CREATE DATABASE bet;
CREATE USER 'repl'@'%' IDENTIFIED BY '!OtusLinux2018';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY '!OtusLinux2018';
mysql -uroot -p -D bet < /vagrant/bet.dmp
mount.cifs //192.168.11.1/smb /mnt -o user=******
mysqldump --all-databases --triggers --routines --master-data --ignore-table=bet.events_on_demand --ignore-table=bet.v_same_event -uroot -p > /mnt/master.sql
mysql -uroot -p'o4u!iEOYi9Im'
INSERT INTO bookmaker (id,bookmaker_name) VALUES(1,'1xbet');
USE bet;
```
* slave
```yaml
yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm -y
yum install Percona-Server-server-57 -y
cp /vagrant/conf/conf.d/* /etc/my.cnf.d/
vi /etc/my.cnf.d/01-base.cnf  id = 2
vi /etc/my.cnf.d/05-binlog.cnf раскоментировал строки
mount.cifs //192.168.11.1/smb /mnt -o user=******
mysql -uroot -p'Pfkegf@123
SOURCE /vagrant/master.sql
CHANGE MASTER TO MASTER_HOST = "192.168.11.150", MASTER_PORT = 3306, MASTER_USER = "repl", MASTER_PASSWORD = "!OtusLinux2018", MASTER_AUTO_POSITION = 1;
START SLAVE;
```
* результат

![img](./img/mysql.png)
