#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	exit 1
fi

sudo touch /var/log/installserver.log
sudo chmod 666 /var/log/installserver.log

section="# ----- [ Network ] ----- #"
echo "$section"

# configure eth0 network card on DHCP
# MAC address (mappig to an IP addr) to be reserved in the DHCP server
ifFile=/etc/network/interfaces
for if in $(sudo lshw -class network 2>/dev/null | grep "logical name" | cut -f 2 -d ":")
do
	grep "auto $if" $ifFile > /dev/null
	# not found
	if [ $? -ne 0 ]
	then
		echo "" >> $ifFile
		echo "auto $if" >> $ifFile
		echo "iface $if inet dhcp" >> $ifFile
		sudo service networking restart >> /var/log/installserver.log 2>&1
		sudo ifup $if
	fi
done
