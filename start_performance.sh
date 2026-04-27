#!/bin/bash

set -e

# Define colors
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
cat << "EOF"
 _______ _______ _______ _______ 
|   _   |   _   |   _   |   _   |
|.  |   |.  |   |   |___|.  |___|
|.  |   |.  ____|____   |.  |___ 
|:  |   |:  |   |:  |   |:  |   |
|::.. . |::.|   |::.. . |::.. . |
`-------`---'   `-------`-------'
                          
EOF
echo -e "${NC}"

echo "Downloading and patching projects..."
bash scripts/download_and_patch.sh

echo "Building the reproducibility environment..."
docker build -t opsc-artifact .

echo "Running experiments"
# Mount the docker socket so the container can spawn sibling containers
docker run --rm \
	--net=host \
	--ulimit nofile=65536:65536 \
	-e HOST_PROJECT_ROOT="$(pwd)" \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v "$(pwd)/logs:/artifact/logs" \
	opsc-artifact \
	python3 scripts/run_experiments.py

#docker run --rm \
#	--net=host \
#	--ulimit nofile=65536:65536 \
#	-e HOST_PROJECT_ROOT="$(pwd)" \
#	-v /var/run/docker.sock:/var/run/docker.sock \
#	-v "$(pwd)/logs:/artifact/logs" \
#	-v "$(pwd)/maven-cache:/root/.m2/repository" \
#	opsc-artifact \
#	python3 scripts/run_experiments.py