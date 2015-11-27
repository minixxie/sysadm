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

if [ x$USE_DOCKER != x -a $USE_DOCKER -eq 1 ] #########################
then

set -e
sudo mkdir -p /var/lib/mongodb  #for db files
echo "dbpath=/data/db" | sudo tee /etc/mongod.conf  #for db config

sudo docker pull mongo:latest
set +e
sudo docker rm -f mongodb
set -e

sudo docker run \
  -d \
  --restart=always \
  --publish=127.0.0.1:27017:27017 \
  --volume=/var/lib/mongodb:/data/db \
  --volume=/etc/mongod.conf:/mongod.conf \
  --name=mongodb \
  mongo mongod -f /mongod.conf
sudo apt-get -q -y install mongodb-clients

else #USE_DOCKER=0 ####################################################

sudo aptitude -q -y install mongodb-org >> /var/log/installserver.log 2>&1
sudo sed -i 's/^#auth.*$/auth = true/' /etc/mongod.conf >> /var/log/installserver.log 2>&1
sudo service mongod restart >> /var/log/installserver.log 2>&1

fi
