#!/bin/bash
yum install -y epel-release ansible
yum update -y
cp /vagrant/ansible.cfg /etc/ansible/ansible.cfg
ansible-playbook /vagrant/playbook/epel.yml
