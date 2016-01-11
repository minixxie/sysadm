#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi


sudo touch /var/log/installserver.log
sudo chmod 666 /var/log/installserver.log

section="# ----- [ MongoDB ] ----- #"
echo "$section"

# ref: http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 >> /var/log/installserver.log 2>&1
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
sudo aptitude update >> /var/log/installserver.log 2>&1
sudo aptitude -q -y install mongodb-org-shell mongodb-org-tools mongodb-org-mongos


set -e
sudo mkdir -p /opt/mongodb-single/data
echo "dbpath=/data/db" | sudo tee /opt/mongodb-single/mongod.conf  #for db config

sudo docker pull mongo:latest
set +e
sudo docker rm -f mongodb-single
set -e

sudo docker run \
  -d \
  --restart=always \
  --publish=127.0.0.1:27018:27017 \
  --volume=/opt/mongodb-single/data:/data/db \
  --volume=/opt/mongodb-single/mongod.conf:/mongod.conf \
  --name=mongodb-single \
  mongo mongod -f /mongod.conf 
