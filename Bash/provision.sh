#!/bin/bash
yum update -y
yum install -y mailx flock
chmod +x /vagrant/pars.sh

cat >> /var/tmp/parstime.log << EOF
2019-01-01T00:00:00
EOF

crontab -l | { cat; echo "0 */1 * * * /usr/bin/flock -xn /var/lock/pars.lock -c 'sh /vagrant/pars.sh'"; } | crontab - 
