#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)

if [ $UID -ne 0 ]
then
	echo "Use \"sudo\" to run this, or switch to root to run this."
	echo "sudo ROOT_PASS=xxxxx $0"
	exit 1
fi

if [ x"$ROOT_PASS" == x ]
then
	ROOT_PASS=hello123
fi

# https://hub.docker.com/_/postgres/
section="# ----- [ Postgres ] ----- #"
echo "$section"
sudo docker pull postgres
sudo docker run --name postgres -e POSTGRES_PASSWORD=$ROOT_PASS -d postgres
sudo docker run -it --link postgres:postgres --rm postgres sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
