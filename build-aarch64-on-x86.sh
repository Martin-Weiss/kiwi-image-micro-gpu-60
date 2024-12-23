#!/bin/bash

echo "root" >.gitignore
echo "image" >.gitignore
echo "image-bundle" >>.gitignore

# set variables
TARGET_DIR=.
#PROFILE="aarch64-self_install"
PROFILE="aarch64-self_install-gpu"
#PROFILE="aarch64-self_install-gpu-encrypted"
KIWI_IMAGE="registry.suse.com/bci/kiwi:10.1.10"

# clean and recreate the build folder
rm -rf $TARGET_DIR/image
mkdir -p $TARGET_DIR/image

# build the image

#kiwi-ng --profile $PROFILE system build --target-dir $TARGET_DIR/image --description $TARGET_DIR \
#--add-repo https://susemanager.weiss.ddnss.de/pub/isos/slmicro60a64 \
#--add-repo https://susemanager.weiss.ddnss.de/ks/dist/slmicro60a64-test,repo-md,SL-Micro-6.0-Test-Pool \
#--add-repo https://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro60a64-test-sndirsch-sidecar-slmicro60-a64/slmicro60a64-test,repo-md,sndirsch-sidecar-slmicro60-a64 \
#--add-repo https://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro60a64-test-libnvidia-container-a64/slmicro60a64-test,repo-md,libnvidia-container-a64 \
#--add-repo https://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro60a64-test-sl-micro-extras-6.0-pool-aarch64/slmicro60a64-test \
#--add-repo https://susemanager.weiss.ddnss.de/ks/dist/child/sl-micro-6.0-pool-aarch64-clone/slmicro60a64-test
#exit

mkdir -p ./repo
curl -k https://susemanager.weiss.ddnss.de/pub/rhn-org-trusted-ssl-cert-osimage-1.0-1.noarch.rpm -o repo/rhn-org-trusted-ssl-cert-osimage-1.0-1.noarch.rpm

# setup qemu-arm userspace emulation
podman run --rm --privileged docker.io/multiarch/qemu-user-static --reset -p yes

# Hint: clone channel in SUSE Manager for pool -> child
# softwarechannel_clone -s sl-micro-6.0-pool-aarch64 -n staging-slmicro60a64-test-sl-micro-6.0-pool-aarch64-clone -p staging-slmicro60a64-test-sl-micro-6.0-pool-aarch64 -l staging-slmicro60a64-test-sl-micro-6.0-pool-aarch64-clone

podman run --platform=linux/arm64/v8 --privileged \
-v /var/lib/ca-certificates:/var/lib/ca-certificates \
-v ./repo:/var/lib/Kiwi/repo \
-v $TARGET_DIR/kiwi.yml:/etc/kiwi.yml \
-v $TARGET_DIR:/image:Z \
$KIWI_IMAGE kiwi-ng \
--profile $PROFILE \
system build \
--allow-existing-root \
--description /image \
--target-dir /image/image \
--ignore-repos-used-for-build \
--add-repo file:/var/lib/Kiwi/repo,rpm-dir,common_repo,90,false,false \
--add-bootstrap-package findutils \
--add-bootstrap-package rhn-org-trusted-ssl-cert-osimage-1.0-1 \
--add-repo https://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro60a64-test-suse-manager-tools-for-sl-micro-6.0-aarch64/slmicro60a64-test,repo-md,suse-manager-tools-for-sl-micro-6.0-aarch64 \
--add-repo https://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro60a64-test-nvidia-jetson-36_4-sl-micro-60-aarch64/slmicro60a64-test,repo-md,nvidia-jetson-36_4-sl-micro-60-aarch64  \
--add-repo https://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro60a64-test-libnvidia-container-a64/slmicro60a64-test,repo-md,libnvidia-container-a64 \
--add-repo https://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro60a64-test-sl-micro-extras-6.0-pool-aarch64/slmicro60a64-test,sl-micro-extras-6.0-pool-aarch64 \
--add-repo https://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro60a64-test-slmicro60-ptfs/slmicro60a64-test,slmicro60-ptfs \
--add-repo https://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro60a64-test-sl-micro-6.0-pool-aarch64-clone/slmicro60a64-test,sl-micro-6.0-pool-aarch64-clone
exit
--debug \

# not required for iso building.. 
rm -rf $TARGET_DIR/image-bundle
mkdir -p $TARGET_DIR/image-bundle
podman run --privileged -v $TARGET_DIR:/image:Z registry.suse.com/bci/kiwi:10.1.10 kiwi-ng result bundle --target-dir /image/image --bundle-dir=/image/image-bundle --id=0
