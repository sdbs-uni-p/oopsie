#!/bin/bash

scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
cd $scriptDir

for dir in opennms-noannos opennms-annos opennms-value; do
    (
    echo "Assembling project in $dir with ./compile.pl..."
    cd $dir
    docker compose up -d
    ./compile.pl -DskipTests=true -PskipCheckerFramework --projects :opennms-webapp -am install
    docker compose down
    )
done

for dir in opennms-nocf; do
    (
    echo "Assembling project in $dir with ./compile.pl..."
    cd $dir
    docker compose up -d
    ./compile.pl -DskipTests=true --projects :opennms-webapp -am install
    docker compose down
    )
done