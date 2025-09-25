#!/bin/bash
# ==========================================
# MySQL setup script
# Author: Lalit Kumar
# ==========================================

set -e

# ------------------ variables --------------------
MYSQL_ROOT_PASSWORD="NewStrongPassword123!"
DB_NAME="bookstore"

echo "============================================"
echo "MySQL setup started"
echo "============================================"

if [[ $UID -ne 0 ]]
then
    echo "This script must be run as root"
    exit 1
fi

# ----------------------- Install MySQL is not present ----------------------
if ! dpkg -l | grep -q mysql-server
then
    echo "installing MySQL Server ............."
    apt install -y mysql-server
else
    echo "Installed Already"
fi

# ----------------------- Secure MySQL setup ---------------------------------
echo "Configuring MySQL root user and database"

mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
-- set strong password for root
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';

-- remove anonymous users
DELETE FROM mysql.user WHERE user='';

-- apply changes
FLUSH PRIVILEGES;

-- create application database
CREATE DATABASE IF NOT EXISTS ${DB_NAME};

EOF

# ------------------------ starting MySQL server is not running -----------------------
if ! systemctl is-active --quite mysql
then
    systemctl start mysql
fi
# -----------------------------  sql final output ---------------------
echo "======================================="
echo "MySQL setup completed Successfully."
echo "======================================="