#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)
. "$scriptPath"/../lib/uri_parser #import uri_parser function

if [ x"$MONGO_URL" == x ]
then
        >&2 echo "usage: MONGO_URL=mongo://user:pass@host:port/db [SSH_TUNNEL=ssh://user:pass@host:port] $0"
        exit 1
fi


moment=$(date -u +"%Y%m%d-%H%M%S+0000")

echo "MONGO_URL=$MONGO_URL"
uri_parser "$MONGO_URL" || { >&2 echo "Malformed MONGO_URL"; exit 1; }

mongoSchema="$uri_schema"
mongoUser="$uri_user"
mongoPass="$uri_password"
mongoHost="$uri_host"
mongoPort=${uri_port:-27017}
mongoPath=$(basename "$uri_path")
if [ x"$mongoPath" == x"/" ]
then
        mongoPath=""
fi

if [ x"$SSH_TUNNEL" != x ]
then

uri_parser $SSH_TUNNEL || { >&2 echo "Malformed SSH_TUNNEL"; exit 1; }

sshSchema="$uri_schema"
sshUser="$uri_user"
#sshPass="$uri_password"
sshHost="$uri_host"
sshPort=${uri_port:-22}
sshPath=$(basename "$uri_path")

ssh $sshUser@$sshHost -p $sshPort -t "mongo -u $mongoUser -p$mongoPass $mongoHost:$mongoPort/$mongoPath"

else
	mongo -u $mongoUser -p$mongoPass $mongoHost:$mongoPort/$mongoPath
fi
