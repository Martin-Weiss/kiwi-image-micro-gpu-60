#
# spec file for package nvidia-jetson-userspace
#
# Copyright (c) 2024 SUSE LLC
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.opensuse.org/
#

%define ver 36.4.0-20240912212859

Name:           nvidia-jetson-userspace
Version:        36.4.0_20240912212859
Release:        0
Summary:        Minimal Userspace for nVidia Jetson Orin
License:        MIT
Group:          System/X11/Utilities
URL:            https://partners.nvidia.com
Source0:        Jetson_Linux_R36.4.0_aarch64.tbz2
Source1:        %{name}-rpmlintrc
Patch0:         nv_repackager-no-sudo-use-bzip2.patch
BuildRequires:  fdupes
BuildRequires:  unzip
BuildRequires:  zstd
Provides:       libcuda.so()(64bit)
ExclusiveArch:  aarch64

%description
Minimal Userspace for nVidia Jetson Orin

%package igpu
Summary:        Full Graphics Userspace for nVidia Jetson Orin Internal GPU
Group:          System/X11/Utilities
Conflicts:      nvidia-gl-G06
Requires:       %{name} = %version

%description igpu
Full Graphics Userspace for nVidia Jetson Orin Internal GPU. This can't be
installed and used on IGX Orin with separate graphics card (dGPU system).

%prep
%setup -q -n Linux_for_Tegra
%patch -P 0 -p1

%build
./nv_tools/scripts/nv_repackager.sh -o ./nv_tegra/l4t_tar_packages --convert-all
pushd nv_tegra/l4t_tar_packages
# needed options of etc/modprobe.d/nvidia-display.conf already set in KMP modprobe.d file
rm nvidia-l4t-display-kernel_*-tegra-%{ver}_arm64.tbz2
# repackage  nvidia-l4t-init_ package
cat >  nvidia-l4t-init_%{ver}.txt << EOF
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
tar xf  nvidia-l4t-init_%{ver}_arm64.tbz2
rm      nvidia-l4t-init_%{ver}_arm64.tbz2
tar cjf nvidia-l4t-init_%{ver}_arm64.tbz2 $(cat nvidia-l4t-init_%{ver}.txt)
popd

%install
pushd nv_tegra/l4t_tar_packages
for i in \
nvidia-l4t-core_%{ver}_arm64.tbz2 \
nvidia-l4t-3d-core_%{ver}_arm64.tbz2 \
nvidia-l4t-cuda_%{ver}_arm64.tbz2 \
nvidia-l4t-gbm_%{ver}_arm64.tbz2 \
nvidia-l4t-multimedia-utils_%{ver}_arm64.tbz2 \
nvidia-l4t-multimedia_%{ver}_arm64.tbz2 \
nvidia-l4t-nvfancontrol_%{ver}_arm64.tbz2 \
nvidia-l4t-nvpmodel_%{ver}_arm64.tbz2 \
nvidia-l4t-tools_%{ver}_arm64.tbz2 \
nvidia-l4t-x11_%{ver}_arm64.tbz2 \
nvidia-l4t-nvsci_%{ver}_arm64.tbz2 \
nvidia-l4t-pva_%{ver}_arm64.tbz2 \
nvidia-l4t-wayland_%{ver}_arm64.tbz2 \
nvidia-l4t-camera_%{ver}_arm64.tbz2 \
nvidia-l4t-vulkan-sc-sdk_%{ver}_arm64.tbz2 \
nvidia-l4t-nvml_%{ver}_arm64.tbz2 \
nvidia-l4t-init_%{ver}_arm64.tbz2; do
  tar xjf $i -C $RPM_BUILD_ROOT/
done
popd
mkdir -p $RPM_BUILD_ROOT/usr/lib64/xorg/modules/drivers \
         $RPM_BUILD_ROOT/usr/lib64/xorg/modules/extensions
mv $RPM_BUILD_ROOT/usr/lib/xorg/modules/drivers/nvidia_drv.so \
   $RPM_BUILD_ROOT/usr/lib64/xorg/modules/drivers/
mv $RPM_BUILD_ROOT/usr/lib/xorg/modules/extensions/libglxserver_nvidia.so \
   $RPM_BUILD_ROOT/usr/lib64/xorg/modules/extensions/
rm -rf $RPM_BUILD_ROOT/usr/lib/xorg
echo /usr/lib/aarch64-linux-gnu >> $RPM_BUILD_ROOT/etc/ld.so.conf.d/nvidia-tegra.conf
echo /usr/lib/aarch64-linux-gnu/tegra-egl >> $RPM_BUILD_ROOT/etc/ld.so.conf.d/nvidia-tegra.conf

rm $RPM_BUILD_ROOT/usr/sbin/wpa_supplicant

%fdupes $RPM_BUILD_ROOT

%post   -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%dir /etc/X11/xorg.conf.d
%dir /etc/dpkg
%dir /etc/dpkg/dpkg.cfg.d
%dir /etc/udev
%dir /etc/udev/rules.d
%dir /opt/nvidia
%dir /opt/nvidia/camera
%dir /usr/lib/python3
%dir /usr/lib/python3/dist-packages
%dir /usr/lib/python3/dist-packages/pylibjetsonpower
%dir /var/nvidia
/etc/X11/xorg.conf
/etc/X11/xorg.conf.d/tegra-drm-outputclass.conf
#/etc/X11/xorg.conf.t194_ref
/etc/asound.conf.*
/etc/dpkg/dpkg.cfg.d/include-docs
/etc/ld.so.conf.d/nvidia-tegra.conf
/etc/nv_tegra_release
/etc/nvidia-container-runtime/
/etc/nvpmodel/
/etc/nvpower/
/etc/nvsciipc.cfg
/etc/sysctl.d/60-nvsciipc.conf
/etc/systemd/
/etc/udev/rules.d/99-tegra-devices.rules
/etc/vulkansc/
/opt/nvidia/camera/nvcapture-status-decoder
/usr/bin/*
%exclude /usr/bin/nvidia-xconfig
/usr/lib/aarch64-linux-gnu/
/usr/lib/python3/dist-packages/pylibjetsonpower/__init__.py
/usr/sbin/*
/usr/share/alsa/
/usr/share/doc/
/usr/share/egl/
/usr/src/nvidia/
/var/nvidia/nvcam/

%files igpu
%dir /etc/vulkan
%dir /etc/vulkan/icd.d
%dir /usr/lib64/xorg
%dir /usr/lib64/xorg/modules
%dir /usr/lib64/xorg/modules/drivers
%dir /usr/lib64/xorg/modules/extensions
/etc/vulkan/icd.d/nvidia_icd.json
/usr/bin/nvidia-xconfig
/usr/lib64/xorg/modules/drivers/nvidia_drv.so
/usr/lib64/xorg/modules/extensions/libglxserver_nvidia.so
/usr/share/glvnd/

#%changelog`

