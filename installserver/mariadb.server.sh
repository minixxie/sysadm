#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi

mysqlRootPass=hello123
if [ x"$MYSQL_ROOT_PASS" != x ]
then
	mysqlRootPass="$MYSQL_ROOT_PASS"
fi
if [ x"$CONTAINER_NAME" != x ]
then
	CONTAINER_NAME="mariadb"
fi


section="# ----- [ MariaDB ] ----- #"
echo "$section"
sudo docker pull mariadb
sudo docker run --name $CONTAINER_NAME -e MYSQL_ROOT_PASSWORD=$mysqlRootPass -p 3306:3306 -d mariadb:latest
sudo apt-get -q -y install mariadb-client-core-5.5 mariadb-client-5.5
echo "use: \"mysql -h 127.0.0.1 -u root -p\" to force TCP/IP connection rather than UNIX domain socket"
