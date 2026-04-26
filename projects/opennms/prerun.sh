#!/bin/bash

scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
cd $scriptDir

cd opennms

# assemble
echo "Assembling project with ./compile.pl..."
./compile.pl -DskipTests=true --projects :opennms-webapp -am install