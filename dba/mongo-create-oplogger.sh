#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)
mongo=$mongo "$scriptPath"/mongo-init-db.sh siteUserAdmin "" "oplogger" "" "local" "read"

