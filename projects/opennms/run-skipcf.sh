#!/bin/bash

scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
cd $scriptDir

cd opennms
git switch repro/no-opsc

echo "Running mvn clean..."
mvn clean > /dev/null


echo "Starting compilation..."
# measure time
startTime=$(date +%s%3N)


mvn compile -pl opennms-webapp

# measure end time
endTime=$(date +%s%3N)
elapsedTime=$((endTime - startTime))


echo "Elapsed time (compilation): $((elapsedTime)) milliseconds"

