Добавляем следующие строки в Vagrantfile в секцию box.vm.provision

```
          box.vm.provision "shell", inline: <<-SHELL
              mkdir -p ~root/.ssh
              cp ~vagrant/.ssh/auth* ~root/.ssh
              yum install -y mdadm smartmontools hdparm gdisk
                  mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
                  mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f}
                  mkdir /etc/mdadm
                  echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
                  mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
                  parted -s /dev/md0 mklabel gpt
                  parted /dev/md0 mkpart primary ext4 0% 20%
                  parted /dev/md0 mkpart primary ext4 20% 40%
                  parted /dev/md0 mkpart primary ext4 40% 60%
                  parted /dev/md0 mkpart primary ext4 60% 80%
                  parted /dev/md0 mkpart primary ext4 80% 100%
                  for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
                  mkdir -p /raid/part{1,2,3,4,5}
                  for i in $(seq 1 5); do sudo mount /dev/md0p$i /raid/part$i; done		  
          SHELL
```
Проверяем 
```
[topper@fedora disk]$ vagrant up
[topper@fedora disk]$ vagrant ssh
[vagrant@otuslinux ~]$ lsblk
NAME      MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda         8:0    0    40G  0 disk  
`-sda1      8:1    0    40G  0 part  /
sdb         8:16   0   250M  0 disk  
`-md0       9:0    0   744M  0 raid6 
  |-md0p1 259:0    0   147M  0 md    /raid/part1
  |-md0p2 259:1    0 148.5M  0 md    /raid/part2
  |-md0p3 259:2    0   150M  0 md    /raid/part3
  |-md0p4 259:3    0 148.5M  0 md    /raid/part4
  `-md0p5 259:4    0   147M  0 md    /raid/part5
sdc         8:32   0   250M  0 disk  
`-md0       9:0    0   744M  0 raid6 
  |-md0p1 259:0    0   147M  0 md    /raid/part1
  |-md0p2 259:1    0 148.5M  0 md    /raid/part2
  |-md0p3 259:2    0   150M  0 md    /raid/part3
  |-md0p4 259:3    0 148.5M  0 md    /raid/part4
  `-md0p5 259:4    0   147M  0 md    /raid/part5
sdd         8:48   0   250M  0 disk  
`-md0       9:0    0   744M  0 raid6 
  |-md0p1 259:0    0   147M  0 md    /raid/part1
  |-md0p2 259:1    0 148.5M  0 md    /raid/part2
  |-md0p3 259:2    0   150M  0 md    /raid/part3
  |-md0p4 259:3    0 148.5M  0 md    /raid/part4
  `-md0p5 259:4    0   147M  0 md    /raid/part5
sde         8:64   0   250M  0 disk  
`-md0       9:0    0   744M  0 raid6 
  |-md0p1 259:0    0   147M  0 md    /raid/part1
  |-md0p2 259:1    0 148.5M  0 md    /raid/part2
  |-md0p3 259:2    0   150M  0 md    /raid/part3
  |-md0p4 259:3    0 148.5M  0 md    /raid/part4
  `-md0p5 259:4    0   147M  0 md    /raid/part5
sdf         8:80   0   250M  0 disk  
`-md0       9:0    0   744M  0 raid6 
  |-md0p1 259:0    0   147M  0 md    /raid/part1
  |-md0p2 259:1    0 148.5M  0 md    /raid/part2
  |-md0p3 259:2    0   150M  0 md    /raid/part3
  |-md0p4 259:3    0 148.5M  0 md    /raid/part4
  `-md0p5 259:4    0   147M  0 md    /raid/part5
  
[vagrant@otuslinux ~]$ cat /proc/mdstat 
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid6 sdf[4] sde[3] sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]
      
unused devices: <none>
```
