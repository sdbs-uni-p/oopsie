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


echo "Injecting dummy web-assets artifact to bypass 8-minute UI build..."

# 1. Create a valid, empty .jar file
echo "Bypass UI" > dummy.txt
jar cf dummy-web-assets.jar dummy.txt

# 2. Forcefully install it into the local Maven cache as the primary artifact
mvn install:install-file \
  -Dfile=dummy-web-assets.jar \
  -DgroupId=org.opennms.core \
  -DartifactId=org.opennms.core.web-assets \
  -Dversion=34.0.0-SNAPSHOT \
  -Dpackaging=jar \
  -DgeneratePom=true > /dev/null

# 3. Forcefully install it AGAIN, this time as the 'dist' classifier
mvn install:install-file \
  -Dfile=dummy-web-assets.jar \
  -DgroupId=org.opennms.core \
  -DartifactId=org.opennms.core.web-assets \
  -Dversion=34.0.0-SNAPSHOT \
  -Dpackaging=jar \
  -Dclassifier=dist \
  -DgeneratePom=false > /dev/null
  
docker compose up -d --wait
./compile.pl -Dskip.installnodenpm=true -Dskip.npm=true -DskipTests=true --projects :opennms-webapp,!:org.opennms.core.web-assets -am install
docker compose down