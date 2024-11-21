#!/bin/bash

echo "root" >.gitignore
echo "image" >.gitignore
echo "image-bundle" >>.gitignore

# set variables
TARGET_DIR=.
#PROFILE="aarch64-self_install"
#PROFILE="aarch64-self_install-gpu"
PROFILE="aarch64-self_install-gpu-encrypted"
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

podman run --privileged \
-v /var/lib/ca-certificates:/var/lib/ca-certificates \
-v /var/lib/Kiwi/repo:/var/lib/Kiwi/repo \
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
--add-bootstrap-package rhn-org-trusted-ssl-cert-osimage \
--add-repo https://susemanager.weiss.ddnss.de/pub/isos/slmicro60a64 \
--add-repo https://susemanager.weiss.ddnss.de/ks/dist/slmicro60a64-test,repo-md,SL-Micro-6.0-Test-Pool \
--add-repo https://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro60a64-test-sndirsch-sidecar-slmicro60-a64/slmicro60a64-test,repo-md,sndirsch-sidecar-slmicro60-a64 \
--add-repo https://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro60a64-test-libnvidia-container-a64/slmicro60a64-test,repo-md,libnvidia-container-a64 \
--add-repo https://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro60a64-test-sl-micro-extras-6.0-pool-aarch64/slmicro60a64-test \
--add-repo https://susemanager.weiss.ddnss.de/ks/dist/child/sl-micro-6.0-pool-aarch64-clone/slmicro60a64-test
exit
--debug \

# not required for iso building.. 
rm -rf $TARGET_DIR/image-bundle
mkdir -p $TARGET_DIR/image-bundle
podman run --privileged -v $TARGET_DIR:/image:Z registry.suse.com/bci/kiwi:10.1.10 kiwi-ng result bundle --target-dir /image/image --bundle-dir=/image/image-bundle --id=0
