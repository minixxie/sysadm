#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ `pwd` != $HOME ]
then
	cp -pf $0 ~/
fi

mkdir -p ~/sshfs && touch ~/host/NOT_MOUNTED && sshfs -o nonempty $USER@192.168.56.1:~/ ~/host
