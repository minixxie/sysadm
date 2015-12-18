#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	echo "sudo ROOT_PASS=xxxxx $0"
	exit 1
fi

if [ x"$ROOT_PASS" == x ]
then
	ROOT_PASS=hello123
fi

# https://hub.docker.com/r/mdillon/postgis/
section="# ----- [ Postgres GIS ] ----- #"
echo "$section"
sudo apt-get -q -y install postgresql-client
sudo docker pull mdillon/postgis

sudo mkdir -p /var/lib/postgresql/data
sudo chown 999:999 /var/lib/postgresql/data
sudo chmod 700 /var/lib/postgresql/data
sudo docker run --name postgis -e POSTGRES_PASSWORD=$ROOT_PASS -p 5432:5432 \
	-v /var/lib/postgresql/data:/var/lib/postgresql/data \
	-d mdillon/postgis
