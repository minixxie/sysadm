#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi


sudo touch /var/log/installserver.log
sudo chmod 666 /var/log/installserver.log

section="# ----- [ Ansible ] ----- #"
echo "$section"
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update
sudo apt-get install -y ansible
