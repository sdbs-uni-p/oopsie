#!/bin/bash

scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
cd $scriptDir

cd opennms-nocf

# # assemble
# echo "Assembling project with ./compile.pl..."
# ./compile.pl -DskipTests=true --projects :opennms-webapp -am install

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

