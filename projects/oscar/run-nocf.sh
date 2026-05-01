#!/bin/bash

scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
cd $scriptDir

cd oscar-nocf


echo "Running ./gradlew clean and mvn clean..."
./gradlew clean --no-daemon > /dev/null
mvn clean > /dev/null

echo "Starting compilation..."
# measure time
startTime=$(date +%s%3N)

# db subproject
./gradlew assemble --no-daemon
# main subproject
mvn -Dmaven.test.skip=true -Dcheckstyle.skip=true -Dpmd.skip=true package

# measure end time
endTime=$(date +%s%3N)
elapsedTime=$((endTime - startTime))

echo "Elapsed time (compilation): $((elapsedTime)) milliseconds"

