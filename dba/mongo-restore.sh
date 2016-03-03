#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)
. "$scriptPath"/../lib/uri_parser #import uri_parser function

if [ x"$1" == x -o x"$MONGO_URL" == x ]
then
	#>&2 echo "usage: MONGO_URL=mongo://user:pass@host:port/db [SSH_TUNNEL=ssh://user:pass@host:port] $0 /path/to/backup.tar.gz"
	>&2 echo "usage: MONGO_URL=mongo://user:pass@host:port/db $0 /path/to/backup.tar.gz"
	exit 1
fi

fullPath=$(cd $(dirname "$1") ; pwd)/$(basename "$1")
filenameNoTarGZ=$(basename "$1"| sed 's/\.tar\.gz//')

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
mongorestoreCommand="mongorestore --host $mongoHost:$mongoPort --username $mongoUser --password $mongoPass --db $mongoPath"

if [ x"$SSH_TUNNEL" != x ]
then

uri_parser $SSH_TUNNEL || { >&2 echo "Malformed SSH_TUNNEL"; exit 1; }

sshSchema="$uri_schema"
sshUser="$uri_user"
#sshPass="$uri_password"
sshHost="$uri_host"
sshPort=${uri_port:-22}
sshPath=$(basename "$uri_path")

#echo "sshSchema: $sshSchema"
#echo "sshUser: $sshUser"
#echo "sshPass: $sshPass"
#echo "sshHost: $sshHost"
#echo "sshPort: $sshPort"
#echo "sshPath: $sshPath"

sshCommand="ssh $sshUser@$sshHost -p $sshPort"
scpCommand="scp -P $sshPort $sshUser@$sshHost"

#backupTmpFolder=$($sshCommand -t "tmp=\$(mktemp -d /tmp/XXXXXX); $mongodumpCommand --out \$tmp/$outputFolder > /dev/null && cd \$tmp/ && tar czf $outputFolder.tar.gz $outputFolder && echo -n \$tmp")

if [ $? -eq 0 ] #dump successful
then
	$scpCommand:$backupTmpFolder/$outputFolder.tar.gz "$1"
	if [ $? -eq 0 ] #scp successful
	then
		$sshCommand -t "rm -rf $backupTmpFolder"
		>&2 echo "$1/$outputFolder.tar.gz is ready"
		echo "$1/$outputFolder.tar.gz"
	fi
fi

else

tmpdir=$(mktemp -d /tmp/XXXXXX)

pushd . >/dev/null
cd "$tmpdir" ; tar xzf "$fullPath"
cd "$filenameNoTarGZ"

dbFolder=$(ls "$tmpdir"/"$filenameNoTarGZ")
echo "dbFolder = $dbFolder"

$mongorestoreCommand  "$dbFolder"
popd >/dev/null

fi

