#!/bin/bash

set -e

systemctl stop mysql

apt purge -y  mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-*

rm -rf /etc/mysql /var/lib/mysql /var/log/mysql

apt autoremove -y
apt autoclean -y

echo "sql deleted successfully..................................."

