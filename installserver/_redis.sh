#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi


sudo touch /var/log/installserver.log
sudo chmod 666 /var/log/installserver.log

section="# ----- [ Redis ] ----- #"
echo "$section"
sudo add-apt-repository -y ppa:rwky/redis
sudo apt-get update
sudo apt-get -q -y install redis-server redis-tools
