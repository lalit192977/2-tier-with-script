#!/bin/bash
# ===========================================
# The-epic-book deployment script
# Author: Lalit Kumar
# ===========================================

set -e

# ----------------------- Variables ------------------------------
MYSQL_ROOT_PASSWORD="NewStrongPassword123!"
CONFIG_FILE="config/config.json"
MYSQL_USER="root"
MYSQL_PASS="NewStrongPassword123!"
MYSQL_DB="bookstore"
MYSQL_HOST="127.0.0.1"
APP_REPO="https://github.com/lalit192977/theepicbook.git"
APP_DIR="theepicbook"


# --------------------- root check --------------------------
if [[ $UID -ne 0 ]]
then
	echo "user is not root"
	exit 1
fi

# -------------------- Package Installation ---------------------
function install_package(){
	local pkg=${1}

	if ! dpkg -l | grep -q "$pkg"
	then
		echo "installing package $pkg"
		apt install -y $pkg
	fi
}

# -------------------- Installing Dependencies --------------------
function install_dependencies(){
	install_package git
	install_package nodejs
	install_package npm
}
# -------------------- Setup Mysql --------------------
function mysql_setup(){
	source ./sqlsetup.sh
}


# -------------------- Clone Repo and Install ------------------------
function cloning_repo(){
	if [[ -d "$APP_DIR" ]]
	then
		echo "directory already exists, pulling latest changes"
		cd $APP_DIR
		git pull
	else
		git clone https://github.com/lalit192977/theepicbook.git
		cd $APP_DIR
	fi

	echo "installing nodejs dependencies............"
	npm install
}

# ------------------------- seed database -------------------
function seed_database (){
	mysql -u root -p"${MYSQL_ROOT_PASSWORD}" bookstore < db/BuyTheBook_Schema.sql
	mysql -u root -p"${MYSQL_ROOT_PASSWORD}" bookstore < db/author_seed.sql
	mysql -u root -p"${MYSQL_ROOT_PASSWORD}" bookstore < db/books_seed.sql
}

# ------------------------- configure app --------------------------
function configure_app(){
	sed -i "s/\"username\": \".*\"/\"username\": \"${MYSQL_USER}\"/" $CONFIG_FILE
	sed -i "s/\"password\": \".*\"/\"password\": \"${MYSQL_PASS}\"/" $CONFIG_FILE
	sed -i "s/\"database\": \".*\"/\"database\": \"${MYSQL_DB}\"/" $CONFIG_FILE
	sed -i "s/\"host\": \".*\"/\"host\": \"${MYSQL_HOST}\"/" $CONFIG_FILE
}

# ------------------------- Main Execution ------------------------
function main (){
    install_dependencies
    mysql_setup
    cloning_repo
    seed_database
    configure_app
	
	nohup node server.js > server.log 2>&1 &

    echo "======================================================="
    echo "✅ Deployment completed successfully!"
    echo "======================================================="
}

# ------------------- Run Script --------------------------
main

