#!/bin/bash

if [ x"$1" == x -o x"$MONGO_URL" == x ]
then
	>&2 echo "usage: MONGO_URL=mongo://user:pass@host:port/db [SSH_TUNNEL=ssh://user:pass@host:port] $0 /path/to/output/folder/"
	exit 1
fi

#
# URI parsing function
#
# The function creates global variables with the parsed results.
# It returns 0 if parsing was successful or non-zero otherwise.
#
# [schema://][user[:password]@]host[:port][/path][?[arg1=val1]...][#fragment]
#
function uri_parser() {
    # uri capture
    uri="$@"

    # safe escaping
    uri="${uri//\`/%60}"
    uri="${uri//\"/%22}"

    # top level parsing
    pattern='^(([a-z]{3,5})://)?((([^:\/]+)(:([^@\/]*))?@)?([^:\/?]+)(:([0-9]+))?)(\/[^?]*)?(\?[^#]*)?(#.*)?$'
    [[ "$uri" =~ $pattern ]] || return 1;

    # component extraction
    uri=${BASH_REMATCH[0]}
    uri_schema=${BASH_REMATCH[2]}
    uri_address=${BASH_REMATCH[3]}
    uri_user=${BASH_REMATCH[5]}
    uri_password=${BASH_REMATCH[7]}
    uri_host=${BASH_REMATCH[8]}
    uri_port=${BASH_REMATCH[10]}
    uri_path=${BASH_REMATCH[11]}
    uri_query=${BASH_REMATCH[12]}
    uri_fragment=${BASH_REMATCH[13]}

    # path parsing
    count=0
    path="$uri_path"
    pattern='^/+([^/]+)'
    while [[ $path =~ $pattern ]]; do
        eval "uri_parts[$count]=\"${BASH_REMATCH[1]}\""
        path="${path:${#BASH_REMATCH[0]}}"
        let count++
    done

    # query parsing
    count=0
    query="$uri_query"
    pattern='^[?&]+([^= ]+)(=([^&]*))?'
    while [[ $query =~ $pattern ]]; do
        eval "uri_args[$count]=\"${BASH_REMATCH[1]}\""
        eval "uri_arg_${BASH_REMATCH[1]}=\"${BASH_REMATCH[3]}\""
        query="${query:${#BASH_REMATCH[0]}}"
        let count++
    done

    # return success
    return 0
}


moment=$(date -u +"%Y%m%d-%H%M%S+0000")

uri_parser $MONGO_URL || { >&2 echo "Malformed MONGO_URL"; exit 1; }

mongoSchema="$uri_schema"
mongoUser="$uri_user"
mongoPass="$uri_password"
mongoHost="$uri_host"
mongoPort=${uri_port:-27017}
mongoPath=$(basename $uri_path)

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

pushd .
$mongodumpCommand --out "$1"/"$outputFolder" && cd "$1" && tar czf $outputFolder.tar.gz $outputFolder
rm -rf $outputFolder
popd
>&2 echo "$1/$outputFolder.tar.gz is ready"
echo "$1/$outputFolder.tar.gz"

fi

