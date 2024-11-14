#!/bin/bash

echo "image" >.gitignore
echo "image-bundle" >>.gitignore

# set variables
TARGET_DIR=.

# clean and recreate the build folder
rm -rf $TARGET_DIR/image
mkdir -p $TARGET_DIR/image

# build the image

#kiwi-ng --profile aarch64-self_install-gpu system build --target-dir $TARGET_DIR/image --description $TARGET_DIR \
#--add-repo http://susemanager.weiss.ddnss.de/pub/isos/slmicro60a64 \
#--add-repo http://susemanager.weiss.ddnss.de/ks/dist/slmicro60a64-test,repo-md,SL-Micro-6.0-Test-Pool \
#--add-repo http://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro60a64-test-sndirsch-sidecar-slmicro60-a64/slmicro60a64-test,repo-md,sndirsch-sidecar-slmicro60-a64 \
#--add-repo http://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro60a64-test-libnvidia-container-a64/slmicro60a64-test,repo-md,libnvidia-container-a64 \
#--add-repo http://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro60a64-test-sl-micro-extras-6.0-pool-aarch64/slmicro60a64-test \
#--add-repo http://susemanager.weiss.ddnss.de/ks/dist/child/sl-micro-6.0-pool-aarch64-clone/slmicro60a64-test

#exit

#podman run --privileged -v $TARGET_DIR:/image:Z registry.suse.com/bci/kiwi:9.24.43-10.7 kiwi-ng --profile aarch64-self_install-gpu system build --description /image --target-dir /image/image \
podman run --privileged -v $TARGET_DIR/kiwi.yml:/etc/kiwi.yml  -v $TARGET_DIR:/image:Z registry.suse.com/bci/kiwi:10.1.10 kiwi-ng --profile aarch64-self_install-gpu-encrypted system build --description /image --target-dir /image/image \
--add-repo http://susemanager.weiss.ddnss.de/pub/isos/slmicro60a64 \
--add-repo http://susemanager.weiss.ddnss.de/ks/dist/slmicro60a64-test,repo-md,SL-Micro-6.0-Test-Pool \
--add-repo http://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro60a64-test-sndirsch-sidecar-slmicro60-a64/slmicro60a64-test,repo-md,sndirsch-sidecar-slmicro60-a64 \
--add-repo http://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro60a64-test-libnvidia-container-a64/slmicro60a64-test,repo-md,libnvidia-container-a64 \
--add-repo http://susemanager.weiss.ddnss.de/ks/dist/child/staging-slmicro60a64-test-sl-micro-extras-6.0-pool-aarch64/slmicro60a64-test \
--add-repo http://susemanager.weiss.ddnss.de/ks/dist/child/sl-micro-6.0-pool-aarch64-clone/slmicro60a64-test

exit

# create the bundle - required just for ova build
#rm -rf $TARGET_DIR/image-bundle
#mkdir -p $TARGET_DIR/image-bundle
#kiwi-ng result bundle --target-dir $TARGET_DIR/image --bundle-dir=$TARGET_DIR/image-bundle --id=0

rm -rf $TARGET_DIR/image-bundle
mkdir -p $TARGET_DIR/image-bundle
podman run --privileged -v $TARGET_DIR:/image:Z registry.suse.com/bci/kiwi:10.1.10 kiwi-ng result bundle --target-dir /image/image --bundle-dir=/image/image-bundle --id=0
#!/bin/bash

