#!/bin/bash

tmlast=$(tail -n1 /var/tmp/parstime.log )

tmstart=$(date +%F"T"%T)

TT=$(date -d $tmlast +%s)

vagrant/accesscho $tmstart >> /var/tmp/parstime.log 

logpars=$(
cat /vagrant/access.log |
sed 's/\//-/1' |
sed 's/\//-/1' |
sed 's/\:/T/1' |
sed 's/\[//1'  |
awk '{cmd="date -d "$4" +%s"; cmd | getline x; close(cmd);$4=x;print $0}' |
awk -v DD=$TT '$4 > DD {print}')

logmail=$(
echo "Лог с " $tmlast "до" $tmstart
echo "Топ 10 IP"
echo "$logpars" | cut -f 1 -d ' ' | sort | uniq -c | sort -n -r | sed -n "1,10 p" 
echo "Top 10 адрессов"
echo "$logpars" | cut -f 7 -d ' ' | sort | uniq -c | sort -n -r | sed -n "1,10 p" 
echo "Все коды возврата"
echo "$logpars" | cut -f 9 -d ' ' | sort | uniq -c | sort -n -r
echo "все ошибки"
echo "$logpars" | awk '$9 != "200"' )

echo "$logmail" | mailx -vvv -s "Log from $tmstart" -r "test@td-minkom.ru" -S smtp="smtp.yandex.ru" korovin80@ya.ru
