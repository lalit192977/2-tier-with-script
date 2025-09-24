#!/bin/bash


set -e

#=============================sql installation========================
apt install -y mysql-server
systemctl start mysql
systemctl enable mysql

#========================== sql setup ============================
MYSQL_ROOT_PASSWORD="NewStrongPassword123!"

sudo mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS bookstore;
EOF


echo "MySQL setup completed. Root password changed and 'bookstore' database created."
