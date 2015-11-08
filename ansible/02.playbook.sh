#!/bin/bash

scriptPath=$(cd `dirname $0`;pwd)

options="-i ./ansible-hosts --sudo --ask-sudo-pass -vvvv"

echo ansible-playbook $options docker-playbook.yml
ansible-playbook $options docker-playbook.yml
