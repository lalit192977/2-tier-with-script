#!/bin/bash

set -e

MYSQL_ROOT_PASSWORD="NewStrongPassword123!"
CONFIG_FILE="config/config.json"
MYSQL_USER="root"
MYSQL_PASS="NewStrongPassword123!"
MYSQL_DB="bookstore"
MYSQL_HOST="127.0.0.1"


#check user is root
if [[ $UID -ne 0 ]]
then
	echo "user is not root"
	exit 1
fi

#========================= functions ================================
#package installation
function installPackage(){
	local pkg=${1}

	apt install -y ${pkg}
	if [[ ! $? -eq 0 ]]
	then
		echo "failed in installing ${pkg}"
		exit 1
	fi
}

#=======================
#installing packages
installPackage git
installPackage nodejs
installPackage npm

#mysql setup
source ./sqlsetup.sh

#==========================================================
#cloning the repo
git clone https://github.com/pravinmishraaws/theepicbook.git

cd theepicbook
npm install

mysql -u root -p"${MYSQL_ROOT_PASSWORD}" bookstore < db/BuyTheBook_Schema.sql
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" bookstore < db/author_seed.sql
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" bookstore < db/books_seed.sql

# replace values in config.json
sed -i "s/\"username\": \".*\"/\"username\": \"${MYSQL_USER}\"/" $CONFIG_FILE
sed -i "s/\"password\": \".*\"/\"password\": \"${MYSQL_PASS}\"/" $CONFIG_FILE
sed -i "s/\"database\": \".*\"/\"database\": \"${MYSQL_DB}\"/" $CONFIG_FILE
sed -i "s/\"host\": \".*\"/\"host\": \"${MYSQL_HOST}\"/" $CONFIG_FILE

nohup node server.js > server.log 2>&1 &


echo "..........your application running properly........................"
