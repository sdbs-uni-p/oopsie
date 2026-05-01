#!/bin/bash

scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
cd $scriptDir

# for dir in opennms-noannos opennms-nocf opennms-annos opennms-value; do
for dir in opennms-noannos; do
    (
    echo "Assembling project in $dir with ./compile.pl..."
    cd $dir
    docker compose up -d
    ./compile.pl -DskipTests=true -PskipCheckerFramework --projects :opennms-webapp -am install
    docker compose down
    )
done
