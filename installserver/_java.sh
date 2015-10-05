#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi


sudo touch /var/log/installserver.log
sudo chmod 666 /var/log/installserver.log

section="# ----- [ Java ] ----- #"
echo "$section"

sudo add-apt-repository -y ppa:webupd8team/java  >> /var/log/installserver.log 2>&1
sudo aptitude update >> /var/log/installserver.log 2>&1
sudo aptitude -q -y install oracle-java8-installer 

#sudo aptitude -q -y remove openjdk-6-jre openjdk-6-jre-headless >> /var/log/installserver.log 2>&1
#sudo aptitude -q -y install openjdk-7-jdk ant >> /var/log/installserver.log 2>&1

# apt-add-repository ppa:webupd8team/java
# apt-get update
# apt-get install oracle-java7-installer
