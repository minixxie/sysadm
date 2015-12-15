#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi


sudo touch /var/log/installserver.log
sudo chmod 666 /var/log/installserver.log

section="# ----- [ Misc Packages ] ----- #"
echo "$section"
#aptitude -q -y install language-support-en language-pack-en language-pack-zh \
#	>> /var/log/installserver.log 2>&1
sudo aptitude -q -y install software-properties-common >> /var/log/installserver.log 2>&1
sudo aptitude -q -y install python-software-properties >> /var/log/installserver.log 2>&1
sudo aptitude -q -y --allow-untrusted install debconf debconf-utils >> /var/log/installserver.log 2>&1
sudo aptitude -q -y install imagemagick mysql-client zip unzip tofrodos jhead \
	ethtool expect xmlstarlet subversion cvs nfs-common sshfs traceroute \
	aria2 dialog wget curl tree rar p7zip-rar vim sysvbanner cmake automake texinfo ctorrent exif \
	httperf \
	>> /var/log/installserver.log 2>&1
wget -qO- https://get.docker.com/ | sh #install docker

sudo pip install shyaml #https://github.com/0k/shyaml

#	nodejs 
#	libboost-system1.48.0 \
#	libboost1.48-all-dev libev4 libev-dev libcurl4-gnutls-dev libjsoncpp-dev 

#install prozilla
#NOT SUPPORTED ON 14.04: sudo aptitude -q -y --allow-untrusted -o Dpkg::Options::="--force-overwrite" install prozilla >> /var/log/installserver.log 2>&1

