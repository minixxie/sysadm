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
sudo docker pull mdillon/postgis
sudo docker run --name postgis -e POSTGRES_PASSWORD=$ROOT_PASS -d mdillon/postgis
