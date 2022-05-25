# Домашнее задание: работа с mdadm
### Задание:
> * добавить в Vagrantfile еще дисков
> * собрать R0/R5/R10 на выбор
> * прописать собранный рейд в конф, чтобы рейд собирался при загрузке
> * сломать/починить raid
> * создать GPT раздел и 5 партиций и смонтировать их на диск.
> 
> В качестве проверки принимается - измененный Vagrantfile, скрипт для создания рейда, конф для автосборки рейда при загрузке.
> 
> • Доп. задание - Vagrantfile, которяй сразу собирает систему с подключенным рейдом.

### Решение:
### Установка Vagrant
```
[topper@fedora ~]$ vagrant -v
Vagrant 2.2.19
```

### Добавить в Vagrantfile еще дисков

Добавляем в Vagrantfile в блок с дисками описание нового диска
```
[topper@fedora ~]$ sudo nano Vagrantfile
```
Запускаем ВМ через vagrant
```
[topper@fedora ~]$ vagrant up
[topper@fedora ~]$vagrant ssh
```

### Собрать RAID0/1/5/10 - на выбор
Смотрим какие блочные устройства (диски) есть в системе. Сделать это можно несколькими способами:
* fdisk -l
* lsblk
* lshw
* lsscsi
```
[vagrant@otuslinux ~]$ sudo lshw -short | grep disk
/0/100/d/0 /dev/sdb disk 1048MB VBOX HARDDISK
/0/100/d/1 /dev/sdc disk 262MB VBOX HARDDISK
/0/100/d/2 /dev/sdd disk 262MB VBOX HARDDISK
/0/100/d/3 /dev/sde disk 262MB VBOX HARDDISK
/0/100/d/0.0.0 /dev/sdf disk 262MB VBOX HARDDISK
```
Занулим суперблоки
```
[vagrant@otuslinux ~]$ sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
```
Если мы получили ответ:
```
mdadm: Unrecognised md component device — /dev/sdb
mdadm: Unrecognised md component device — /dev/sdc
```
то значит, что диски не использовались ранее для RAID. Просто продолжаем настройку.

Создаем raid
```
[vagrant@otuslinux ~]$ sudo mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f}
mdadm: layout defaults to left-symmetric
mdadm: layout defaults to left-symmetric
mdadm: chunk size defaults to 512K
mdadm: size set to 253952K
mdadm: largest drive (/dev/sdb) exceeds size (253952K) by more than 1%
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
```
Проверим что RAID собрался нормально:
```
[vagrant@otuslinux ~]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid6 sde[5] sdf[4] sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]      
unused devices: <none>
```
### Создание конфигурационного файла mdadm.conf

В файле mdadm.conf находится информация о RAID-массивах и компонентах, которые в них входят. Если не создать config-файл, то после перезагрузки не будет RAID-a

Создаем каталог для config-файла
```
[vagrant@otuslinux ~]$ sudo mkdir /etc/mdadm
```
Довавляем права
```
[vagrant@otuslinux ~]$ sudo chmod 777 -R /etc/mdadm
```
Убедимся, что информация верна:
```
[vagrant@otuslinux ~]$ sudo mdadm --detail --scan --verbose
ARRAY /dev/md0 level=raid6 num-devices=5 metadata=1.2 name=mdadm:0
UUID=11fc7859:98d4e7d3:48b30582:b2630265
devices=/dev/sdb,/dev/sdc,/dev/sdd,/dev/sde,/dev/sdf
```
Затем cоздадим файл mdadm.conf
```
[vagrant@otuslinux ~]$ sudo echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
[vagrant@otuslinux ~]$ sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
```

### Сломать/починить RAID

Помечаем "мертвый" диск для удаления

```
[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --fail /dev/sde
mdadm: set /dev/sde faulty in /dev/md0
```

Проверяем, что диск помечен

```
[vagrant@otuslinux ~]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid6 sdf[4] sde[3](F) sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/4] [UUU_U]      
unused devices: <none>

[vagrant@otuslinux ~]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Sun May  8 15:23:29 2022
        Raid Level : raid6
        Array Size : 761856 (744.00 MiB 780.14 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Sun May  8 15:45:16 2022
             State : clean, degraded 
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 1
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : 2acda3f4:1e4a3094:8959f01e:e8df4b6a
            Events : 19

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       -       0        0        3      removed
       4       8       80        4      active sync   /dev/sdf

       3       8       64        -      faulty   /dev/sde
```

Удалим “сломаннsй” диск из массива:

```
[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --remove /dev/sde
mdadm: hot removed /dev/sde from /dev/md0
```

Добавляем новый диск

```
[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --add /dev/sde
mdadm: added /dev/sde

[vagrant@otuslinux ~]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid6 sde[5] sdf[4] sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]      
unused devices: <none>

[vagrant@otuslinux ~]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Sun May  8 15:23:29 2022
        Raid Level : raid6
        Array Size : 761856 (744.00 MiB 780.14 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Sun May  8 15:47:07 2022
             State : clean 
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : 2acda3f4:1e4a3094:8959f01e:e8df4b6a
            Events : 39

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       5       8       64        3      active sync   /dev/sde
       4       8       80        4      active sync   /dev/sdf
```
### Создать GPT раздел, пять партиций и смонтировать их на диск

Создаем раздел GPT на RAID
```
[vagrant@otuslinux ~]$ sudo parted -s /dev/md0 mklabel gpt
```

Создаем партиwии
```
[vagrant@otuslinux ~]$ sudo parted /dev/md0 mkpart primary ext4 0% 20%
Information: You may need to update /etc/fstab
[vagrant@otuslinux ~]$ sudo parted /dev/md0 mkpart primary ext4 20% 40%
Information: You may need to update /etc/fstab.
[vagrant@otuslinux ~]$ sudo parted /dev/md0 mkpart primary ext4 40% 60%
Information: You may need to update /etc/fstab.
[vagrant@otuslinux ~]$ sudo parted /dev/md0 mkpart primary ext4 60% 80%
Information: You may need to update /etc/fstab.
[vagrant@otuslinux ~]$ sudo parted /dev/md0 mkpart primary ext4 80% 100%
Information: You may need to update /etc/fstab.
```

Далее создаём на этих партициях ФС
```
[vagrant@otuslinux ~]$ for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
37696 inodes, 150528 blocks
7526 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
1984 inodes per group
Superblock backups stored on blocks: 
        8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information:  done 

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
38152 inodes, 152064 blocks
7603 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
2008 inodes per group
Superblock backups stored on blocks: 
        8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information:  done 

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
38456 inodes, 153600 blocks
7680 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
2024 inodes per group
Superblock backups stored on blocks: 
        8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information:  done 

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
38152 inodes, 152064 blocks
7603 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
2008 inodes per group
Superblock backups stored on blocks: 
        8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information:  done 

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
37696 inodes, 150528 blocks
7526 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
1984 inodes per group
Superblock backups stored on blocks: 
        8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information:  done
```

Монтируем их по каталогам
```
[vagrant@otuslinux ~]$ sudo mkdir -p /raid/part{1,2,3,4,5}
[vagrant@otuslinux ~]$ for i in $(seq 1 5); do sudo mount /dev/md0p$i /raid/part$i; done
```
