#!/bin/bash

# eth1 as "host only" device
grep eth1 /etc/network/interfaces >/dev/null
if [ $? -eq 1 ]
then
	sudo bash -c 'echo "" >> /etc/network/interfaces'
	sudo bash -c 'echo "auto eth1" >> /etc/network/interfaces'
	sudo bash -c 'echo "iface eth1 inet dhcp" >> /etc/network/interfaces'
	sudo ifup eth1
fi
