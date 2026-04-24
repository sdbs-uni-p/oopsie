##!/bin/bash
#
#echo "Downloading OpenNMS repository"
#cd opennms
#git clone https://github.com/OpenNMS/opennms.git
#cd opennms
#git checkout dcafd6dcd0c4f5e2d5219091cb74f5190d56f309
#echo "Applying patch"
#git apply --whitespace=nowarn ../opennms-opsc-annotated.patch
#cd ../..

echo "Downloading EscadaTPC-C repository"
cd EscadaTPC-C
git clone https://github.com/rmpvilaca/EscadaTPC-C.git
cd EscadaTPC-C
git checkout ff15fbf99b39c81725937e11b8eb9665834bfefb
echo "Applying patch"
git apply --whitespace=nowarn ../escada-opsc.patch
cd ../..