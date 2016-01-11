#!/bin/bash

scriptPath=$(cd `dirname $0`; pwd)
"$scriptPath"/mongo-init-db.sh siteUserAdmin "" "oplogger" "" "local" "read"

