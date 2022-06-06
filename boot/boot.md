# Домашнее задание Работа с загрузчиком

### Описание/Пошаговая инструкция выполнения домашнего задания:
1. Попасть в систему без пароля несколькими способами.
2. Установить систему с LVM, после чего переименовать VG.
3. Добавить модуль в initrd. 
4. Сконфигурировать систему без отдельного раздела с /boot, 
а только с LVM Репозиторий с пропатченым grub: https://yum.rumyantsev.com/centos/7/x86_64/ PV 
необходимо инициализировать с параметром --bootloaderareasize 1m

### Решение:
### Задание 1.

Попасть в систему без пароля способ первый:
1. Перед началом загрузки CentOS нажимаем на клашиву ```e``` для входа в grub меню.
2. В строке ```linux16``` убираем ```console=tty0 console=ttyS0,115200n8``` и добавляем ```rd.break enforcing=0```, далее нажимаем ```Ctrl+X```.
3. Произойдет загрузка системы в аварийном режиме.
4. Далее выполняем команду перемонтирования корня для чтения и записи - ```mount -o remount,rw /sysroot```, далее ```chroot /sysroot```.
5. Выполняем команду ```passwd``` и меняем пароль для пользователя ```root```.
6. После смены пароля необходимо скрытый файл выполнив команду ```touch /.autorelabel```. Этот файл нужен, для того чтобы выполнить ```relabel``` файлов в системе, 
если ```selinux``` включен и находиться в режиме ```Enforcing```. Без этого вы не сможете залогиниться в систему после ее загрузки.
7. Перезагружаем систему, заходим под ```root```, введя измененный пароль.
8. Далее выполняем команду ```fixfiles -f relabel```, происходит ```relabeling``` файлов, ```selinux``` перечитывает файлы системы и начинаем им доверять.
9. После чего заходим в ```/etc/selinux/config``` и приводим строку к виду ```SELINUX=Enforcing```.
10. Далее можем перезагружаться и попробовать войти в систему.

Попасть в систему без пароля способ второй:
1. Перед началом загрузки CentOS нажимаем на клашиву ```e``` для входа в grub меню.
2. В строке ```linux16``` убираем ```console=tty0 console=ttyS0,115200n8``` и добавляем ```init=/bin/sh```, далее нажимаем ```Ctrl+X```.
3. Далее выполняем команду перемонтирования корня ```mount -o remount,rw /sysroot```.
4. Выполняем команду ```passwd``` и меняем пароль.
5. После чего заходим в ```/etc/selinux/config``` если ```SELINUX=Enforcing```, то меняем на ```Permissive``` или ```Disabled```.
6. после перезагрузки, если ```SELINUX``` включен, то делаем ```fixfilex -f relabel```

### Задание 2.
* После установки системы с LVM смотрим какие Volume Group у нас есть выполнив команду ```vgs```.
* переименовываем VG:
  * ```vgrename centos centos1```
* Чтобы в дальнейшем смогли загрузиться меняем старое название на новое в файлах:
  *  ```/etc/fstab```;
  *  ```/etc/default/grub``` и в строке ```GRUB_CMDLINE_LINUX``` в значениях ```rd.lvm.lv```;
  *  ```/boot/grub2/grub.cfg``` в строке ```linux16```.
* Далее пересоздаем ```initrd image``` чтобы в файлах поменялся путь монтирования. Выполняем ```mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)```.
* Перезагружаем систему. Теперь система загружается с новым названием VG ```centos1```.

### Задание 3.
*  Создаем папку в каталоге ```mkdir /usr/lib/dracut/modules.d/01test```
*  Далее в папке ```01test``` создаем там 2 скрипта ```module-setup.sh``` и ```test.sh```
*  Делаем их исполняемыми ```chmod +x module-setup.sh``` и ```chmod +x test.sh```
*  Выполняем команду ```mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)```
*  Перезагружаем систему

![](https://github.com/Topper-crypto/otus/blob/main/boot/dracut.png)

### Задание 4.

[root@localhost ~]# parted
(parted) select /dev/sdb
Using /dev/sdb
(parted) mklabel msdos
(parted) mkpart                                                           
Partition type?  primary/extended? p                                      
File system type?  [ext2]? ext4                                           
Start? 1                                                                  
End? -1  
[root@localhost ~]# pvcreate /dev/sdb1 --bootloaderareasize 1M
  Physical volume "/dev/sdb1" successfully created.
[root@localhost ~]# vgcreate new-root /dev/sdb1
  Volume group "new-root" successfully created
[root@localhost ~]# lvcreate -n root -l 100%FREE new-root
  Logical volume "root" created.
[root@localhost ~]# pvs
  PV         VG       Fmt  Attr PSize   PFree
  /dev/sda2  centos   lvm2 a--   22.58g 4.00m
  /dev/sdb1  new-root lvm2 a--  <42.36g    0 
[root@localhost ~]# vgs
  VG       #PV #LV #SN Attr   VSize   VFree
  centos     1   2   0 wz--n-  22.58g 4.00m
  new-root   1   1   0 wz--n- <42.36g    0   
 [root@localhost ~]# lvs
  LV   VG       Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root centos   -wi-ao---- <20.58g                                                    
  swap centos   -wi-ao----   2.00g                                                    
  root new-root -wi-a----- <42.36g    
[root@localhost ~]# mkfs.ext4 /dev/mapper/new--root-root 
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
2777088 inodes, 11103232 blocks
555161 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=2160066560
339 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
        4096000, 7962624

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done  
[root@localhost ~]# mkdir /mnt/root
[root@localhost ~]# mount /dev/mapper/new--root-root /mnt/root
[root@localhost ~]# rsync -avx / /mnt/root
...
sent 1,565,579,066 bytes  received 636,750 bytes  101,046,181.68 bytes/sec
total size is 1,563,007,575  speedup is 1.00

[root@localhost ~]# rsync -avx /boot /mnt/root
...
sent 168,076,798 bytes  received 6,202 bytes  112,055,333.33 bytes/sec
total size is 168,014,538  speedup is 1.00
[root@localhost ~]# mount --rbind /dev/ /mnt/root/dev
[root@localhost ~]# mount --rbind /proc /mnt/root/proc
[root@localhost ~]# mount --rbind /sys /mnt/root/sys
[root@localhost ~]# mount --rbind /run /mnt/root/run
[root@localhost ~]# chroot /mnt/root
[root@localhost /]# cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Fri Jun  3 18:26:48 2022
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/new--root-root /                       ext4     defaults        0 0
#UUID=916149ff-1339-4c08-8e76-a64ddcc3f2aa /boot                   xfs     defaults        0 0
/dev/mapper/centos-swap swap                    swap    defaults        0 0
[root@localhost /]# nano /etc/default/grub 
# меняем в GRUB_CMDLINE_LINUX значение rd.lvm.lv на rd.lvm.lv=new--root/root
[root@localhost /]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-1160.66.1.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-1160.66.1.el7.x86_64.img
Found linux image: /boot/vmlinuz-3.10.0-1160.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-1160.el7.x86_64.img
Found linux image: /boot/vmlinuz-0-rescue-64b35b4797508c48905f111062ded685
Found initrd image: /boot/initramfs-0-rescue-64b35b4797508c48905f111062ded685.img
done
[root@localhost /]# dracut -f -v /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img
...
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***
[root@localhost /]# grub2-install /dev/sdb
Installing for i386-pc platform.
Installation finished. No error reported.
[root@localhost /]# nano /etc/selinux/config
SELINUX=disabled

выходим и загружаемся с нового диска

[topper@localhost ~]$ lsblk
NAME               MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                  8:0    0 23.6G  0 disk 
└─sdb1               8:17   0 42.4G  0 part 
  └─new--root-root 253:2    0 42.4G  0 lvm  /
