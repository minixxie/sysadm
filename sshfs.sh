#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ `pwd` != $HOME ]
then
	cp -pf $0 ~/
fi

mkdir -p ~/host >& /dev/null
mount host >& /dev/null
touch ~/host/NOT_MOUNTED >& /dev/null
sshfs -o nonempty $USER@192.168.56.1:~/ ~/host
