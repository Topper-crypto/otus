# Домашнее задание

### PAM

### Описание/Пошаговая инструкция выполнения домашнего задания:

Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников

* дать конкретному пользователю права работать с докером и возможность рестартить докер сервис

### Решение:

Для установки запрета на вход по SSH либо через физическую консоль пользователю необходимо внести изменения в фийлы конфигурации `sshd` и `login`:
```bash
$ sudo nano /etc/pam.d/sshd
```
```bash
#%PAM-1.0
auth       required     pam_sepermit.so
auth       substack     password-auth
auth       include      postlogin
# Used with polkit to reauthorize users in remote sessions
-auth      optional     pam_reauthorize.so prepare
account required pam_access.so # Модуль, который контролирует доступ по группам (разрешение/запрев входа). Не имеет функционала обеспечиваюций доступ по расписанию
account required pam_time.so # Модуль, который контролирует поступ по пользователям (разрешение/запрев входа)
account    required     pam_nologin.so
account    include      password-auth
password   include      password-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open env_params
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    include      password-auth
session    include      postlogin
# Used with polkit to reauthorize users in remote sessions
-session   optional     pam_reauthorize.so prepare
```
```bash
$ sudo nano /etc/pam.d/login
```
```bash
#%PAM-1.0
auth [user_unknown=ignore success=ok ignore=ignore default=bad] pam_securetty.so
auth       substack     system-auth
auth       include      postlogin
account required pam_access.so # Модуль, который контролирует доступ по группам (разрешение/запрев входа). Не имеет функционала обеспечиваюций доступ по расписанию
account   required   pam_time.so # Модуль, который контролирует поступ по пользователям (разрешение/запрев входа)
account    required     pam_nologin.so
account    include      system-auth
password   include      system-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
session    optional     pam_console.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    include      system-auth
session    include      postlogin
-session   optional     pam_ck_connector.so
```

В конце файла `/etc/security/time.conf` добавляем строку `;;docker;!Tu`

Создаем пользователя `useradd docker` и задаем пароль `passwd docker`.

Пытаемся зайти в тот день, когда работает правило:

```bash
$ ssh docker@localhost
docker@localhost's password:
Authentication failed.
```

Для установки запрета на вход по группам необходимо провести следующие настройки:

1. Создаем группу `groupadd admin`
2. Добавляем в созданную группу пользователя `usermod -aG admin docker`
3. Устанавливаем компонент, с помощью которого мы сможем описывать правила входа в виде обычного bash скрипта `yum install pam_script -y`
4. С помощью команды `rpm -ql pam_script` посмотреть какие файлы использует этот компонент

```bash
[vagrant@otuslinux ~]$ rpm -ql pam_script
```
```bash
/etc/pam-script.d
/etc/pam_script
/etc/pam_script_acct
/etc/pam_script_auth
/etc/pam_script_passwd
/etc/pam_script_ses_close
/etc/pam_script_ses_open
/lib64/security/pam_script.so
/usr/share/doc/pam_script-1.1.8
/usr/share/doc/pam_script-1.1.8/AUTHORS
/usr/share/doc/pam_script-1.1.8/COPYING
/usr/share/doc/pam_script-1.1.8/ChangeLog
/usr/share/doc/pam_script-1.1.8/NEWS
/usr/share/doc/pam_script-1.1.8/README
/usr/share/doc/pam_script-1.1.8/README.pam_script
/usr/share/man/man7/pam-script.7.gz
```

5. Приводим файл `/etc/pam.d/sshd` к следующему виду:

```bash
#%PAM-1.0
auth       required     pam_script.so # Необходимо добавить данную строку
auth       required     pam_sepermit.so
auth       substack     password-auth
auth       include      postlogin
# Used with polkit to reauthorize users in remote sessions
-auth      optional     pam_reauthorize.so prepare
account required pam_access.so
account required pam_time.so
account    required     pam_nologin.so
account    include      password-auth
password   include      password-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open env_params
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    include      password-auth
session    include      postlogin
# Used with polkit to reauthorize users in remote sessions
-session   optional     pam_reauthorize.so prepare
```

6. Приводим файл `/etc/pam_script` к следующему виду:

```bash
#!/bin/bash

if [[ `grep $PAM_USER /etc/group | grep 'admin'` ]]
then
exit 0
fi
if [[ `date +%u` > 5 ]]
then
exit 1
fi
```

7. Даем файлу права на исполнение

Данный скрипт проверяет состоит ли пользователь в группе admin. 

Если да, разрешаем вход. 

Если он не состоит в группе admin, срабатывает проверка на то, какой сейчас день недели, если он больше 5 (выходные дни), то вход запрещен.

## Дополнительное задание

### Способ 1.

Проводим поиск пользователя, которому необходимо дать права root:

```bash
$ grep docker /etc/passwd
```
```bash
docker:x:1001:1001::/home/docker:/bin/bash
```

Далее меняем два значения `1001` на `0` (значения `uid` и `gid root`).

Теперь когда пользователь будет заходить по своему логину, у него будут права root

Также для того чтобы работать с файлами root, неоходимо добавить пользователя в группу `root`:

```bash
$ usermod -a -G root docker
```

###  Способ 2.

Дать пользователю право выполнять команду от имени `root`, добавив пользователя в `sudoers`.

```bash
$ usermod -aG wheel docker
```

Проделоное действие позволит пользователя выполнять команды с приставкой sudo.

