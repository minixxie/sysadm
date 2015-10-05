#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
        echo "Use \"sudo\" to run this, or switch to root to run this."
        exit 1
fi

section="# ----- [ C++ DEV ] ----- #"
echo "$section"

sudo aptitude -q -y install libtntnet-dev >> /var/log/installserver.log 2>&1
sudo aptitude -q -y install libgearman-dev >> /var/log/installserver.log 2>&1
sudo aptitude -q -y install libboost1.55-all-dev >> /var/log/installserver.log 2>&1

sudo aptitude -q -y install gitk >> /var/log/installserver.log 2>&1
exit 0



sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test >> /var/log/installserver.log 2>&1
sudo apt-get -f update >> /var/log/installserver.log 2>&1
sudo apt-get -q -y install gcc-4.7 g++-4.7 >> /var/log/installserver.log 2>&1
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.6 40 --slave /usr/bin/g++ g++ /usr/bin/g++-4.6 
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.7 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.7 
sudo update-alternatives --auto gcc
#sudo update-alternatives --config gcc

#Qt5
sudo add-apt-repository -y ppa:canonical-qt5-edgers/qt5-proper
sudo add-apt-repository -y ppa:ubuntu-sdk-team/ppa
sudo apt-get -f update
#sudo apt-get -q -y install qttools5-dev-tools
sudo apt-get install qt5-default qtbase5-dev libqt5sql5-mysql

# for Qt5.3 (Android/iOS) development
sudo apt-get -q -y install mesa-common-dev

# libraries
sudo apt-get -q -y install \
	libpoco-dev \
	libboost-system1.48-dev \
	libev-dev \
	libjsoncpp-dev \
	libmosquittopp0-dev \
	gnustep \
	>> /var/log/installserver.log 2>&1

#code blocks
sudo apt-get -q -y install libfontconfig1


section="# ----- [ Node.js DEV env ] ----- #"
echo "$section"
sudo add-apt-repository -y ppa:richarvey/nodejs >> /var/log/installserver.log 2>&1
sudo aptitude -f update >> /var/log/installserver.log 2>&1
sudo aptitude -q -y install nodejs npm nodejs-dev >> /var/log/installserver.log 2>&1
sudo npm install -g mqtt
sudo npm install -g socket.io



