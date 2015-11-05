#!/bin/bash

# allow other machine to ssh to this machine
systemsetup -setremotelogin on

# install brew - http://brew.sh/
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# ssh related tools
brew install sshfs ssh-copy-id

# install docker
brew install docker boot2docker docker-compose docker-machine

# install git
brew install git Caskroom/cask/gitx
brew install node npm #node.js

# golang
brew install golang

#brew install mariadb
#sudo apt-get -f install nginx
