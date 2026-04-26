#!/bin/bash

set -e

cd "$(dirname "$0")/../projects"

# ==========================================
# EscadaTPC-C
# ==========================================
echo "Setting up EscadaTPC-C repository..."
cd escadatpc-c

if [ ! -d "EscadaTPC-C" ]; then
    echo "Downloading EscadaTPC-C..."
    git clone https://github.com/rmpvilaca/EscadaTPC-C.git
    cd EscadaTPC-C
    git checkout ff15fbf99b39c81725937e11b8eb9665834bfefb
else
    echo "EscadaTPC-C already exists. Resetting to clean state..."
    cd EscadaTPC-C
    git reset --hard HEAD
    git clean -fdx
    git checkout ff15fbf99b39c81725937e11b8eb9665834bfefb
fi

echo "Applying patch..."
git apply --whitespace=nowarn ../escada-opsc.patch
cd ../..


# ==========================================
# Java Design Patterns
# ==========================================
echo "Setting up java-design-patterns repository..."
cd java-design-patterns

# --- No Annotations ---
if [ ! -d "java-design-patterns-noannos" ]; then
    echo "Downloading java-design-patterns (no annotations)..."
    git clone https://github.com/iluwatar/java-design-patterns.git java-design-patterns-noannos
    cd java-design-patterns-noannos
    git checkout 163c3017bb356937d876cd9a05905c012f3b0af6
else
    echo "java-design-patterns-noannos already exists. Resetting..."
    cd java-design-patterns-noannos
    git reset --hard HEAD
    git clean -fdx
    git checkout 163c3017bb356937d876cd9a05905c012f3b0af6
fi
echo "Applying patch (no annotations)..."
git apply --whitespace=nowarn ../java-design-patterns-opsc.patch
cd ..

# --- Annotations ---
if [ ! -d "java-design-patterns-annos" ]; then
    echo "Downloading java-design-patterns (annotations)..."
    git clone https://github.com/iluwatar/java-design-patterns.git java-design-patterns-annos
    cd java-design-patterns-annos
    git checkout 163c3017bb356937d876cd9a05905c012f3b0af6
else
    echo "java-design-patterns-annos already exists. Resetting..."
    cd java-design-patterns-annos
    git reset --hard HEAD
    git clean -fdx
    git checkout 163c3017bb356937d876cd9a05905c012f3b0af6
fi
echo "Applying patch (annotations)..."
git apply --whitespace=nowarn ../java-design-patterns-annotated.patch
cd ../..


# ==========================================
# JDBC-Course
# ==========================================
echo "Setting up JDBC-Course repository..."
cd jdbc-course

if [ ! -d "JDBC-Course" ]; then
    echo "Downloading JDBC-Course..."
    git clone https://github.com/sayedabdul-aziz/JDBC-Course.git
    cd JDBC-Course
    git checkout 04ed1613c612f8d9ae53ef7629c3cb254d6cad40
else
    echo "JDBC-Course already exists. Resetting to clean state..."
    cd JDBC-Course
    git reset --hard HEAD
    git clean -fdx
    git checkout 04ed1613c612f8d9ae53ef7629c3cb254d6cad40
fi

echo "Applying patch..."
git apply --whitespace=nowarn ../jdbc-course-opsc.patch
cd ../..


# ==========================================
# OpenNMS
# ==========================================
echo "Setting up OpenNMS repository..."
cd opennms

# Set up the baseline clean repository
if [ ! -d "opennms-nocf" ]; then
    echo "Downloading OpenNMS..."
    git clone https://github.com/OpenNMS/opennms.git opennms-nocf
    cd opennms-nocf
    git checkout dcafd6dcd0c4f5e2d5219091cb74f5190d56f309
    cd ..
else
    echo "opennms-nocf already exists. Resetting..."
    cd opennms-nocf
    git reset --hard HEAD
    git clean -fdx
    git checkout dcafd6dcd0c4f5e2d5219091cb74f5190d56f309
    cd ..
fi

# Set up the derivative repositories securely
for variant in opennms-value opennms-noannos opennms-annos; do
    if [ ! -d "$variant" ]; then
        echo "Copying base repository to $variant..."
        cp -r opennms-nocf "$variant"
    else
        echo "$variant already exists. Resetting..."
        cd "$variant"
        git reset --hard HEAD
        git clean -fdx
        cd ..
    fi
done

# Apply patches to the derivatives
cd opennms-value
echo "Applying patch (Value Checker)..."
git apply --whitespace=nowarn ../opennms-valuechecker.patch
cd ..

cd opennms-noannos
echo "Applying patch (no annotations)..."
git apply --whitespace=nowarn ../opennms-opsc.patch
cd ..

cd opennms-annos
echo "Applying patch (annotations)..."
git apply --whitespace=nowarn ../opennms-opsc-annotated.patch
cd ../..


# ==========================================
# OSCAR
# ==========================================
echo "Setting up OSCAR repository..."
cd oscar

# Set up the baseline clean repository
if [ ! -d "oscar-base" ]; then
    echo "Downloading OSCAR baseline..."
    git clone https://bitbucket.org/oscaremr/oscar.git oscar-base
    cd oscar-base
    git checkout cca70ec9a265370992a8f55d5bcb82d011c4b6ac
    cd ..
else
    echo "oscar-base already exists. Resetting..."
    cd oscar-base
    git reset --hard HEAD
    git clean -fdx
    git checkout cca70ec9a265370992a8f55d5bcb82d011c4b6ac
    cd ..
fi

# Set up the derivative repositories securely
for variant in oscar-noannos oscar-annos; do
    if [ ! -d "$variant" ]; then
        echo "Copying base repository to $variant..."
        cp -r oscar-base "$variant"
    else
        echo "$variant already exists. Resetting..."
        cd "$variant"
        git reset --hard HEAD
        git clean -fdx
        cd ..
    fi
done

# Apply patches to the derivatives
cd oscar-noannos
echo "Applying patch (no annotations)..."
git apply --whitespace=nowarn ../oscar-opsc.patch
cd ..

cd oscar-annos
echo "Applying patch (annotations)..."
git apply --whitespace=nowarn ../oscar-annotated.patch
cd ../..

echo "All projects downloaded and patched successfully."