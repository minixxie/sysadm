#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi


sudo touch /var/log/installserver.log
sudo chmod 666 /var/log/installserver.log

section="# ----- [ NodeJS ] ----- #"
echo "$section"
# https://nodesource.com/blog/nodejs-v012-iojs-and-the-nodesource-linux-repositories
curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash - >> /var/log/installserver.log 2>&1
sudo aptitude -q -y install nodejs npm >> /var/log/installserver.log 2>&1
sudo npm install pm2 -g >> /var/log/installserver.log 2>&1
sudo aptitude -q -y install libkrb5-dev >> /var/log/installserver.log 2>&1  #for npm to install kerberos
