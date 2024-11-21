#!/bin/bash
podman run \
	--rm --privileged \
	-v $PWD/eib:/eib \
	docker.io/dgiebert/edge-image-builder:1.2.0 \
	build --definition-file=eib.yaml
rm -rf root
mkdir -p root/oem
tar xvf eib/combustion.tar.gz -C root/oem ./combustion ./artefacts/
