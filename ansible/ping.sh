#!/bin/bash

ansible all -i ./ansible-hosts -m ping -vvvv
