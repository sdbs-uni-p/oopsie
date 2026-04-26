#!/bin/bash

# Parse command line arguments
OPSLOGDIR="opslog"  # Default value
while [[ $# -gt 0 ]]; do
    case $1 in
        --opslogdir)
            OPSLOGDIR="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--opslogdir <directory>]"
            exit 1
            ;;
    esac
done

scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
cd $scriptDir

cd opennms
git switch repro/opsc-annotated

# --- FIX: Calculate the Host Path ---
# 1. Get the path relative to the container root (/artifact)
#    Inside container: /artifact/opsc/opennms
#    We want: opsc/opennms
REL_PATH=$(realpath --relative-to="/artifact" "$(pwd)")

# 2. Combine Host Root + Relative Path + db
export DB_MOUNT_PATH="$HOST_PROJECT_ROOT/$REL_PATH"

echo "Host Project Root: $HOST_PROJECT_ROOT"
echo "Relative Path: $REL_PATH"
echo "Mounting Host Path: $DB_MOUNT_PATH"
# ------------------------------------

# In build.gradle.kts, replace {{{opslogdir}}} with --opslogdir option
sed -i "s|{{{opslogdir}}}|$OPSLOGDIR|g" opennms-webapp/pom.xml

echo "Running docker-compose up..."
docker compose up -d --wait

echo "Running mvn clean..."
mvn clean > /dev/null

echo "Starting compilation..."
# measure time
startTime=$(date +%s%3N)

mvn compile -pl opennms-webapp

# measure end time
endTime=$(date +%s%3N)
elapsedTime=$((endTime - startTime))

git restore opennms-webapp/pom.xml

docker compose down

echo "Elapsed time (compilation): $((elapsedTime)) milliseconds"

