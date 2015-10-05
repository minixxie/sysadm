#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi


sudo touch /var/log/installserver.log
sudo chmod 666 /var/log/installserver.log

section="# ----- [ C++ Runtimes ] ----- #"
echo "$section"
sudo aptitude -q -y install libqt5core5 libqt5sql5 libqt5sql5-sqlite
