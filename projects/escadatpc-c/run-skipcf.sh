#!/bin/bash

scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
cd $scriptDir

cd EscadaTPC-C

echo "Running ./gradlew clean..."
./gradlew clean > /dev/null

echo "Starting compilation... (-PskipCheckerFramework)"
# measure time
startTime=$(date +%s%3N)

./gradlew assemble -PskipCheckerFramework

# measure end time
endTime=$(date +%s%3N)
elapsedTime=$((endTime - startTime))

echo "Elapsed time (compilation): $((elapsedTime)) milliseconds"

