#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi


sudo touch /var/log/installserver.log
sudo chmod 666 /var/log/installserver.log

section="# ----- [ NFS (Network File System) ] ----- #"
echo "$section"
sudo aptitude -q -y install nfs-common >> /var/log/installserver.log 2>&1
#echo "nas01.simon.net:/users_homes  /home  nfs  rw.sync  0  0" >> /etc/fstab
#mount /home >> /var/log/installserver.log 2>&1

