#!/bin/bash

echo "Downloading Checker Framework..."
cd /artifact/src
git clone https://github.com/eisop/checker-framework.git
cd checker-framework
git checkout 323f434a07169d967c1a14579b7849f714aebdd5
echo "Publishing Checker Framework (3.49.5-eisop1) to local Maven cache..."
./gradlew publishToMavenLocal

echo "Publishing OPSC to local Maven cache..."
cd /artifact/src/opsc
./gradlew publishToMavenLocal

cd /artifact/src/opsc-java8
./gradlew publishToMavenLocal