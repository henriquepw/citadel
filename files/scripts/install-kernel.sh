#!/usr/bin/env bash
# Swap the stock kernel for Bazzite's ogc kernel (mirrors bazzite's install-kernel-akmods)
set -euo pipefail

# Stub kernel-install hooks so dracut/rpm-ostree don't run
pushd /usr/lib/kernel/install.d
mv 05-rpmostree.install 05-rpmostree.install.bak
mv 50-dracut.install 50-dracut.install.bak
printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install
printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install
chmod +x 05-rpmostree.install 50-dracut.install
popd

for pkg in kernel kernel{-core,-modules,-modules-core,-modules-extra,-tools-libs,-tools}; do
  rpm --erase "${pkg}" --nodeps || true
done
rm -rf /usr/lib/modules

dnf5 -y install \
  /tmp/kernel-rpms/kernel-[0-9]*.rpm \
  /tmp/kernel-rpms/kernel-core-*.rpm \
  /tmp/kernel-rpms/kernel-modules-*.rpm \
  /tmp/kernel-rpms/kernel-devel-*.rpm

dnf5 versionlock add kernel kernel-devel kernel-devel-matched kernel-core kernel-modules

# kmods via dnf5; the akmods module's rpm-ostree install breaks the transaction
dnf5 -y install /tmp/akmods-rpms/ublue-os/ublue-os-akmods-addons-*.rpm
if ! rpm -q rpmfusion-free-release &>/dev/null; then
  dnf5 -y install "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
fi
# Local common rpms match the kmods; repo ones pull akmod-*, which can't build here
dnf5 -y install --enablerepo='copr:copr.fedorainfracloud.org:ublue-os:akmods' \
  /tmp/akmods-rpms/common/v4l2loopback-*.rpm \
  /tmp/akmods-rpms/common/xone-kmod-common-*.rpm \
  /tmp/akmods-rpms/common/xpadneo-kmod-common-*.rpm \
  /tmp/akmods-rpms/kmods/kmod-v4l2loopback-*.rpm \
  /tmp/akmods-rpms/kmods/kmod-xone-*.rpm \
  /tmp/akmods-rpms/kmods/kmod-xpadneo-*.rpm

pushd /usr/lib/kernel/install.d
mv -f 05-rpmostree.install.bak 05-rpmostree.install
mv -f 50-dracut.install.bak 50-dracut.install
popd

# initramfs is built after the kmods (build-initramfs.sh)

rm -rf /tmp/kernel-rpms /tmp/akmods-rpms
