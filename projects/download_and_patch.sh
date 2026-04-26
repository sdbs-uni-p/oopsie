#!/bin/bash

echo "Downloading EscadaTPC-C repository"
cd escadatpc-c
git clone https://github.com/rmpvilaca/EscadaTPC-C.git
cd EscadaTPC-C
git checkout ff15fbf99b39c81725937e11b8eb9665834bfefb
echo "Applying patch"
git apply --whitespace=nowarn ../escada-opsc.patch
cd ../..

echo "Downloading java-design-patterns repository (no annotations)"
cd java-design-patterns
git clone https://github.com/iluwatar/java-design-patterns.git java-design-patterns-noannos
cd java-design-patterns-noannos
git checkout 163c3017bb356937d876cd9a05905c012f3b0af6
echo "Applying patch (no annotations)"
git apply --whitespace=nowarn ../java-design-patterns-opsc.patch
cd ..
echo "Downloading java-design-patterns repository (annotations)"
git clone https://github.com/iluwatar/java-design-patterns.git java-design-patterns-annos
cd java-design-patterns-annos
git checkout 163c3017bb356937d876cd9a05905c012f3b0af6
echo "Applying patch (annotations)"
git apply --whitespace=nowarn ../java-design-patterns-annotated.patch
cd ../..

echo "Downloading jdbc-course repository"
cd jdbc-course
git clone https://github.com/sayedabdul-aziz/JDBC-Course.git
cd JDBC-Course
git checkout 04ed1613c612f8d9ae53ef7629c3cb254d6cad40
echo "Applying patch"
git apply --whitespace=nowarn ../jdbc-course-opsc.patch
cd ../..

echo "Downloading OpenNMS repository"
cd opennms
git clone https://github.com/OpenNMS/opennms.git
cd opennms
git checkout dcafd6dcd0c4f5e2d5219091cb74f5190d56f309
echo "Applying patch"
git apply --whitespace=nowarn ../opennms-opsc-annotated.patch
cd ../..

echo "Downloading OSCAR repository (no annotations)"
cd oscar
git clone https://bitbucket.org/oscaremr/oscar.git oscar-noannos
cd oscar-noannos
git checkout cca70ec9a265370992a8f55d5bcb82d011c4b6ac
echo "Applying patch (no annotations)"
git apply --whitespace=nowarn ../oscar-opsc.patch
cd ..
echo "Downloading OSCAR repository (annotations)"
git clone https://bitbucket.org/oscaremr/oscar.git oscar-annos
cd oscar-annos
git checkout cca70ec9a265370992a8f55d5bcb82d011c4b6ac
echo "Applying patch (annotations)"
git apply --whitespace=nowarn ../oscar-annotated.patch
cd ../..