#!/bin/bash
#from https://developer.nvidia.com/embedded/jetson-linux-r3640

wget -N https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v4.0/release/Jetson_Linux_R36.4.0_aarch64.tbz2
tar xf Jetson_Linux_R36.4.0_aarch64.tbz2

pushd Linux_for_Tegra
sed -i -e 's/lbzip2/bzip2/g' -e 's/-I zstd //g' nv_tools/scripts/nv_repackager.sh
./nv_tools/scripts/nv_repackager.sh -o ./nv_tegra/l4t_tar_packages --convert-all
popd

pushd Linux_for_Tegra/nv_tegra/l4t_tar_packages/
cat > nvidia-l4t-init.txt << EOF
etc/asound.conf.tegra-ape
etc/asound.conf.tegra-hda-jetson-agx
etc/asound.conf.tegra-hda-jetson-xnx
etc/nvidia-container-runtime/host-files-for-container.d/devices.csv
etc/nvidia-container-runtime/host-files-for-container.d/drivers.csv
etc/nvsciipc.cfg
etc/sysctl.d/60-nvsciipc.conf
etc/systemd/nv_nvsciipc_init.sh
etc/systemd/nvpower.sh
etc/systemd/nv.sh
etc/systemd/system.conf.d/watchdog.conf
etc/systemd/system/multi-user.target.wants/nv_nvsciipc_init.service
etc/systemd/system/multi-user.target.wants/nvpower.service
etc/systemd/system/multi-user.target.wants/nv.service
etc/systemd/system/nv_nvsciipc_init.service
etc/systemd/system/nvpower.service
etc/systemd/system/nv.service
etc/udev/rules.d/99-tegra-devices.rules
usr/share/alsa/cards/tegra-ape.conf
usr/share/alsa/cards/tegra-hda.conf
usr/share/alsa/init/postinit/00-tegra.conf
usr/share/alsa/init/postinit/01-tegra-rt565x.conf
usr/share/alsa/init/postinit/02-tegra-rt5640.conf
EOF
tar xf nvidia-l4t-init_36.4.0-20240912212859_arm64.tbz2
rm nvidia-l4t-init_36.4.0-20240912212859_arm64.tbz2
tar cjf nvidia-l4t-init_36.4.0-20240912212859_arm64.tbz2 $(cat nvidia-l4t-init.txt)
popd

# repackage nvidia-l4t-x11_ package - if system has dGPU
# -------------------------------------------------------
pushd Linux_for_Tegra/nv_tegra/l4t_tar_packages/
tar tf nvidia-l4t-x11_36.4.0-20240912212859_arm64.tbz2 | grep -v /usr/bin/nvidia-xconfig \
  > nvidia-l4t-x11_36.4.0-20240912212859.txt
tar xf  nvidia-l4t-x11_36.4.0-20240912212859_arm64.tbz2
rm      nvidia-l4t-x11_36.4.0-20240912212859_arm64.tbz2
tar cjf nvidia-l4t-x11_36.4.0-20240912212859_arm64.tbz2 $(cat nvidia-l4t-x11_36.4.0-20240912212859.txt)

# repackage nvidia-l4t-3d-core_ package
tar tf nvidia-l4t-3d-core_36.4.0-20240912212859_arm64.tbz2 | \
  grep -v \
       -e /etc/vulkan/icd.d/nvidia_icd.json \
       -e /usr/lib/xorg/modules/drivers/nvidia_drv.so \
       -e /usr/lib/xorg/modules/extensions/libglxserver_nvidia.so \
       -e /usr/share/glvnd/egl_vendor.d/10_nvidia.json \
       > nvidia-l4t-3d-core_36.4.0-20240912212859.txt
tar xf  nvidia-l4t-3d-core_36.4.0-20240912212859_arm64.tbz2
rm      nvidia-l4t-3d-core_36.4.0-20240912212859_arm64.tbz2
tar cjf nvidia-l4t-3d-core_36.4.0-20240912212859_arm64.tbz2 $(cat nvidia-l4t-3d-core_36.4.0-20240912212859.txt)
popd
# -------------------------------------------------------

#pushd Linux_for_Tegra/nv_tegra/l4t_tar_packages
#for i in \
#nvidia-l4t-core_36.4.0-20240912212859_arm64.tbz2 \
#nvidia-l4t-3d-core_36.4.0-20240912212859_arm64.tbz2 \
#nvidia-l4t-cuda_36.4.0-20240912212859_arm64.tbz2 \
#nvidia-l4t-gbm_36.4.0-20240912212859_arm64.tbz2 \
#nvidia-l4t-multimedia-utils_36.4.0-20240912212859_arm64.tbz2 \
#nvidia-l4t-multimedia_36.4.0-20240912212859_arm64.tbz2 \
#nvidia-l4t-nvfancontrol_36.4.0-20240912212859_arm64.tbz2 \
#nvidia-l4t-nvpmodel_36.4.0-20240912212859_arm64.tbz2 \
#nvidia-l4t-tools_36.4.0-20240912212859_arm64.tbz2 \
#nvidia-l4t-x11_36.4.0-20240912212859_arm64.tbz2 \
#nvidia-l4t-nvsci_36.4.0-20240912212859_arm64.tbz2 \
#nvidia-l4t-pva_36.4.0-20240912212859_arm64.tbz2 \
#nvidia-l4t-wayland_36.4.0-20240912212859_arm64.tbz2 \
#nvidia-l4t-camera_36.4.0-20240912212859_arm64.tbz2 \
#nvidia-l4t-vulkan-sc-sdk_36.4.0-20240912212859_arm64.tbz2 \
#nvidia-l4t-nvml_36.4.0-20240912212859_arm64.tbz2 \
#nvidia-l4t-init_36.4.0-20240912212859_arm64.tbz2; do
#  sudo tar xjf $i -C /
#done
#popd
#
# if system does NOT have a dGPU
# -------------------------------------------------------
#mv /usr/lib/xorg/modules/drivers/nvidia_drv.so \
#          /usr/lib64/xorg/modules/drivers/
#mv /usr/lib/xorg/modules/extensions/libglxserver_nvidia.so \
#          /usr/lib64/xorg/modules/extensions/
#rm -rf /usr/lib/xorg
#
#echo /usr/lib/aarch64-linux-gnu | sudo tee -a /etc/ld.so.conf.d/nvidia-tegra.conf
#echo /usr/lib/aarch64-linux-gnu/tegra-egl | sudo tee -a /etc/ld.so.conf.d/nvidia-tegra.conf
# -------------------------------------------------------
#
#ldconfig
