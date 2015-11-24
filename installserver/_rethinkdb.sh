#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi


sudo touch /var/log/installserver.log
sudo chmod 666 /var/log/installserver.log

section="# ----- [ RethinkDB ] ----- #"
echo "$section"

# https://hub.docker.com/_/rethinkdb/
sudo docker pull rethinkdb
sudo mkdir -p /data/rethinkdb
sudo docker run --name rethink01 -v "/data/rethinkdb:/data" -p 28015:28015 -d rethinkdb
sudo npm install -g recli
