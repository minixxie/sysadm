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

if [ x"$ACCESS_FROM_INTERNET" == x ]
then
	ACCESS_FROM_INTERNET=0
fi

# ref: http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 >> /var/log/installserver.log 2>&1
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
sudo aptitude update >> /var/log/installserver.log 2>&1
sudo aptitude -q -y install mongodb-org-shell mongodb-org-tools mongodb-org-mongos

if [ x$USE_DOCKER != x -a $USE_DOCKER -eq 1 ] #########################
then

sudo mkdir -p /opt/mongo/data/ /opt/mongo/etc/
sudo chown -R 999:999 /opt/mongo/data/

cat <<EOF | sudo tee /opt/mongo/etc/mongod.conf  #for db config
dbpath=/data/db
#auth=true
EOF

sudo docker pull mongo:latest
sudo docker rm -f mongo

bindIP="127.0.0.1"
if [ $ACCESS_FROM_INTERNET -eq 1 ]
then
	bindIP="0.0.0.0"
fi

sudo docker run -d --restart=always --name=mongo \
  --publish=$bindIP:27017:27017 \
  --volume=/opt/mongo/data:/data/db \
  --volume=/opt/mongo/etc/mongod.conf:/mongod.conf \
  mongo mongod -f /mongod.conf --replSet "rs0"

sleep 3s;

sudo mongo <<EOF
rs.initiate();
EOF
# https://github.com/meteor/meteor/wiki/Oplog-Observe-Driver
echo "Visit https://github.com/meteor/meteor/wiki/Oplog-Observe-Driver to read more about setting up the oplogger mongo account and MONGO_OPLOG_URL for meteor projects."

else #USE_DOCKER=0 ####################################################

sudo aptitude -q -y install mongodb-org >> /var/log/installserver.log 2>&1
sudo sed -i 's/^#auth.*$/auth = true/' /etc/mongod.conf >> /var/log/installserver.log 2>&1
sudo service mongod restart >> /var/log/installserver.log 2>&1

fi
