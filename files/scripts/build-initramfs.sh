#!/usr/bin/env bash
# Build the initramfs manually since dracut hooks were stubbed; run last
set -euo pipefail

kver="$(dnf5 repoquery --installed --queryformat='%{evr}.%{arch}' kernel)"
depmod -a "$kver"
DRACUT_NO_XATTR=1 dracut --no-hostonly --kver "$kver" --reproducible --zstd --add ostree -f "/usr/lib/modules/$kver/initramfs.img"
chmod 0600 "/usr/lib/modules/$kver/initramfs.img"
