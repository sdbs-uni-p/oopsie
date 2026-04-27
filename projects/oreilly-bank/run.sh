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

cd oreilly-bank

# --- Calculate the Host Path ---
# Get the path relative to the container root (/artifact)
REL_PATH=$(realpath --relative-to="/artifact" "$(pwd)")

# Combine Host Root + Relative Path + DB
export DB_MOUNT_PATH="$HOST_PROJECT_ROOT/$REL_PATH/db"

echo "Mounting Host Path: $DB_MOUNT_PATH"
# ------------------------------------

# In build.gradle.kts, replace {{{opslogdir}}} with --opslogdir option
sed -i "s|{{{opslogdir}}}|$OPSLOGDIR|g" build.gradle.kts


echo "Running docker-compose up..."
docker compose up -d --wait

echo "Running ./gradlew clean..."
./gradlew clean > /dev/null

echo "Starting compilation..."
# measure time
startTime=$(date +%s%3N)

./gradlew assemble

# measure end time
endTime=$(date +%s%3N)
elapsedTime=$((endTime - startTime))

docker compose down

echo "Elapsed time (compilation): $((elapsedTime)) milliseconds"

