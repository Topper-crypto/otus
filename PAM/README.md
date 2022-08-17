# Домашнее задание

### PAM

### Описание/Пошаговая инструкция выполнения домашнего задания:

Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников

* дать конкретному пользователю права работать с докером и возможность рестартить докер сервис

### Решение:

Для установки запрета на вход по SSH либо через физическую консоль пользователю необходимо внести изменения в фийлы конфигурации `sshd` и `login`:
```yaml
$ sudo nano /etc/pam.d/sshd
```
```yaml
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
```yaml
$ sudo nano /etc/pam.d/login
```
```yaml
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

```yaml
$ ssh docker@localhost
docker@localhost's password:
Authentication failed.
```
