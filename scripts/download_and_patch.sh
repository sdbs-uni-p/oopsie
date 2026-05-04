#!/bin/bash

set -e

# Jump to the projects directory relative to where this script lives
cd "$(dirname "$0")/../projects"

# ==========================================
# EscadaTPC-C
# ==========================================
echo "Setting up EscadaTPC-C repository..."
cd escadatpc-c
git clone https://github.com/rmpvilaca/EscadaTPC-C.git
cd EscadaTPC-C
git checkout ff15fbf99b39c81725937e11b8eb9665834bfefb
echo "Applying patch..."
git apply --whitespace=nowarn ../escada-opsc.patch
cd ../..


# ==========================================
# Java Design Patterns
# ==========================================
echo "Setting up java-design-patterns repository..."
cd java-design-patterns

# --- No Annotations ---
echo "Downloading java-design-patterns (no annotations)..."
git clone https://github.com/iluwatar/java-design-patterns.git java-design-patterns-noannos
cd java-design-patterns-noannos
git checkout 163c3017bb356937d876cd9a05905c012f3b0af6
echo "Applying patch (no annotations)..."
git apply --whitespace=nowarn ../java-design-patterns-opsc.patch
cd ../..

# ==========================================
# JDBC-Course
# ==========================================
echo "Setting up JDBC-Course repository..."
cd jdbc-course
echo "Downloading JDBC-Course..."
git clone https://github.com/sayedabdul-aziz/JDBC-Course.git
cd JDBC-Course
git checkout 04ed1613c612f8d9ae53ef7629c3cb254d6cad40
echo "Applying patch..."
git apply --whitespace=nowarn ../jdbc-course-opsc.patch
cd ../..


# ==========================================
# OpenNMS
# ==========================================
echo "Setting up OpenNMS repository..."
cd opennms

echo "Downloading OpenNMS baseline..."
git clone https://github.com/OpenNMS/opennms.git opennms-nocf

echo "Copying base repository to variants..."
cp -r opennms-nocf opennms-value
cp -r opennms-nocf opennms-noannos
cp -r opennms-nocf opennms-annos

# Base (No CF)
cd opennms-nocf
git checkout dcafd6dcd0c4f5e2d5219091cb74f5190d56f309
cd ..

# Value Checker
cd opennms-value
git checkout dcafd6dcd0c4f5e2d5219091cb74f5190d56f309
echo "Applying patch (Value Checker)..."
git apply --whitespace=nowarn ../opennms-valuechecker.patch
cd ..

# No Annotations
cd opennms-noannos
git checkout dcafd6dcd0c4f5e2d5219091cb74f5190d56f309
echo "Applying patch (no annotations)..."
git apply --whitespace=nowarn ../opennms-opsc.patch
cd ..

# Annotations
cd opennms-annos
git checkout dcafd6dcd0c4f5e2d5219091cb74f5190d56f309
echo "Applying patch (annotations)..."
git apply --whitespace=nowarn ../opennms-opsc-annotated.patch
cd ../..


# ==========================================
# OSCAR
# ==========================================
echo "Setting up OSCAR repository..."
cd oscar

echo "Downloading OSCAR baseline..."
git clone https://bitbucket.org/oscaremr/oscar.git oscar-base

echo "Copying base repository to variants..."
cp -r oscar-base oscar-noannos
cp -r oscar-base oscar-annos
cp -r oscar-base oscar-value
cp -r oscar-base oscar-nocf

# Base checkout
cd oscar-base
git checkout cca70ec9a265370992a8f55d5bcb82d011c4b6ac
cd ..

# No Annotations
cd oscar-noannos
git checkout cca70ec9a265370992a8f55d5bcb82d011c4b6ac
echo "Applying patch (no annotations)..."
git apply --whitespace=nowarn ../oscar-opsc.patch
cd ..

# Annotations
cd oscar-annos
git checkout cca70ec9a265370992a8f55d5bcb82d011c4b6ac
echo "Applying patch (annotations)..."
git apply --whitespace=nowarn ../oscar-annotated.patch
cd ..

# Value Checker
cd oscar-value
git checkout cca70ec9a265370992a8f55d5bcb82d011c4b6ac
echo "Applying patch (Value Checker)..."
git apply --whitespace=nowarn ../oscar-value.patch
cd ..

# No CF
cd oscar-nocf
git checkout cca70ec9a265370992a8f55d5bcb82d011c4b6ac
echo "Applying patch (no CF)..."
git apply --whitespace=nowarn ../oscar-nocf.patch
cd ../..

echo "All projects downloaded and patched natively inside Docker successfully."