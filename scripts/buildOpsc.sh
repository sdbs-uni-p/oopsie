#!/bin/bash

echo "Publishing OPSC to local Maven cache..."
cd /artifact/src/opsc
./gradlew publishToMavenLocal

cd /artifact/src/opsc-java8
./gradlew publishToMavenLocal