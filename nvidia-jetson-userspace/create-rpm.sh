#!/bin/bash
zypper -n in rpmdevtools rpmlint
rpmdev-setuptree

cp nv_repackager-no-sudo-use-bzip2.patch $HOME/rpmbuild/SOURCES/
cp nvidia-jetson-userspace.spec $HOME/rpmbuild/SPECS/

pushd $HOME/rpmbuild/SOURCES/
wget -N https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v4.0/release/Jetson_Linux_R36.4.0_aarch64.tbz2 
popd
rpmbuild -bb /root/rpmbuild/SPECS/nvidia-jetson-userspace.spec --target=aarch64

cp -av $HOME/rpmbuild/RPMS/aarch64/nvidia-jetson-userspace-*.rpm .

