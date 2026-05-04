#!/bin/bash

scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
cd $scriptDir


dir="opennms-nocf"

echo "Assembling project in $dir with ./compile.pl..."
cd $dir


# --- FIX: Calculate the Host Path ---
# 1. Get the path relative to the container root (/artifact)
#    Inside container: /artifact/opsc/opennms
#    We want: opsc/opennms
REL_PATH=$(realpath --relative-to="/artifact" "$(pwd)")

# 2. Combine Host Root + Relative Path
export DB_MOUNT_PATH="$HOST_PROJECT_ROOT/$REL_PATH"

echo "Host Project Root: $HOST_PROJECT_ROOT"
echo "Relative Path: $REL_PATH"
echo "Mounting Host Path: $DB_MOUNT_PATH"


docker compose up -d --wait
./compile.pl -DskipTests=true --projects :opennms-webapp -am install
docker compose down