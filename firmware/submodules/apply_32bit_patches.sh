#/bin/bash

echo "Applying patch based on ruckus commit e78464d"
cp ruckus_32bit.patch ruckus/
pushd ruckus
git apply ruckus_32bit.patch
rm ruckus_32bit.patch
popd

echo "Applying patch based on surf commit 858875dd5"
cp surf_32bit.patch surf/
pushd surf
git apply surf_32bit.patch
rm surf_32bit.patch
popd
