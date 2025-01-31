#!/bin/bash
HOSTNAME=encrypted
MAC_ADDRESS1="34:8a:b1:4b:17:ff"
IP_STATIC_ADDRESS="192.168.0.192"

if [ "$1" == "" ]; then
        if virsh domstate $HOSTNAME >> /dev/null 2>&1 ; then
                        echo "VM is already running"
        else
                virt-install \
                        --connect qemu:///system --virt-type kvm  \
                        --name $HOSTNAME \
                        --memory 4096 \
                        --vcpus 2 \
                        --network bridge=br0,mac=$MAC_ADDRESS1 \
                        --cdrom $PWD/image/SL-Micro.x86_64-6.0.0.install.iso \
                        --disk bus=scsi,pool=images-nvme3,size=50,sparse=true \
			--graphics vnc \
                        --osinfo slem6.0 \
                        --check path_in_use=off \
			--boot loader=/usr/share/qemu/ovmf-x86_64-smm-suse-code.bin,loader.readonly=yes,loader.type=pflash,loader.secure=yes,nvram.template=/usr/share/qemu/ovmf-x86_64-smm-suse-vars.bin \
                        --sysinfo system.serial=12345BFF
        fi
fi

if [ "$1" == "rm" ]; then
        ssh-keygen -R $HOSTNAME >> /dev/null 2>&1
        ssh-keygen -R $IP_STATIC_ADDRESS >> /dev/null 2>&1

        virsh destroy $HOSTNAME
        virsh undefine $HOSTNAME --nvram
        rm /srv/kvm/images-nvme3/$HOSTNAME.qcow2

        #spacecmd clear_caches && spacecmd --yes -- system_delete -c NO_CLEANUP $HOSTNAME
fi

exit
                        --boot firmware=efi,firmware.feature0.name=secure-boot,firmware.feature0.enabled=yes \
