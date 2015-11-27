#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)
. "$scriptPath"/../lib/uri_parser #import uri_parser function

if [ x"$1" == x -o x"$MONGO_URL" == x ]
then
	>&2 echo "usage: MONGO_URL=mongo://user:pass@host:port/db [SSH_TUNNEL=ssh://user:pass@host:port] $0 /path/to/output/folder/"
	exit 1
fi


moment=$(date -u +"%Y%m%d-%H%M%S+0000")

uri_parser $MONGO_URL || { >&2 echo "Malformed MONGO_URL"; exit 1; }

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

#echo "mongoSchema: $mongoSchema"
#echo "mongoUser: $mongoUser"
#echo "mongoPass: $mongoPass"
#echo "mongoHost: $mongoHost"
#echo "mongoPort: $mongoPort"
#echo "mongoPath: $mongoPath"

outputFolder=$moment.$mongoPath.mongodump
mongodumpCommand="mongodump --username $mongoUser --password $mongoPass --db $mongoPath"

if [ x"$SSH_TUNNEL" != x ]
then

uri_parser $SSH_TUNNEL || { >&2 echo "Malformed SSH_TUNNEL"; exit 1; }

sshSchema="$uri_schema"
sshUser="$uri_user"
#sshPass="$uri_password"
sshHost="$uri_host"
sshPort=${uri_port:-22}
sshPath=$(basename $uri_path)

#echo "sshSchema: $sshSchema"
#echo "sshUser: $sshUser"
#echo "sshPass: $sshPass"
#echo "sshHost: $sshHost"
#echo "sshPort: $sshPort"
#echo "sshPath: $sshPath"

sshCommand="ssh $sshUser@$sshHost -p $sshPort"
scpCommand="scp -P $sshPort $sshUser@$sshHost"

$sshCommand -t "$mongodumpCommand --out /tmp/$outputFolder && cd /tmp/ && tar czf $outputFolder.tar.gz $outputFolder"
if [ $? -eq 0 ] #dump successful
then
	$scpCommand:/tmp/$outputFolder.tar.gz "$1"
	if [ $? -eq 0 ] #scp successful
	then
		$sshCommand -t "rm -f /tmp/$outputFolder.tar.gz && rm -rf /tmp/$outputFolder"
		>&2 echo "$1/$outputFolder.tar.gz is ready"
		echo "$1/$outputFolder.tar.gz"
	fi
fi

else

pushd . >/dev/null
$mongodumpCommand --out "$1"/"$outputFolder" && cd "$1" && tar czf $outputFolder.tar.gz $outputFolder
rm -rf $outputFolder
popd >/dev/null
>&2 echo "$1/$outputFolder.tar.gz is ready"
echo "$1/$outputFolder.tar.gz"

fi

