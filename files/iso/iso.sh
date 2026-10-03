#!/usr/bin/env bash
# Usage: iso.sh [--remote]  (--remote uses the CI image from ghcr instead of building locally)
set -e

IMAGE=localhost/citadel:latest_linux_amd64

if [[ "$1" == "--remote" ]]; then
	# Empty IMAGE_SRC makes the installer pull IMAGE_REPO/IMAGE_NAME:IMAGE_TAG
	IMAGE_SRC=""
else
	# No chunking: the installed system rebases to the CI-built image anyway
	# Squash: podman commits every module layer otherwise, which is slow
	time sudo bluebuild build \
		recipes/recipe.yml \
		--squash \
		-v
	IMAGE_SRC="containers-storage:$IMAGE"
fi

# Read the image straight from host storage instead of exporting a tarball
time sudo podman run --rm --privileged \
	-v "$PWD":/build-container-installer/build \
	-v dnf-cache:/cache/dnf \
	-v /var/lib/containers/storage:/var/lib/containers/storage \
	ghcr.io/jasonn3/build-container-installer:v1.4.0 \
	VARIANT=server \
	ISO_NAME=build/citadel.iso \
	DNF_CACHE=/cache/dnf \
	IMAGE_REPO=ghcr.io/henriquepw \
	IMAGE_NAME=citadel \
	IMAGE_TAG=latest \
	SECURE_BOOT_KEY_URL=https://github.com/ublue-os/akmods/raw/main/certs/public_key.der \
	ENROLLMENT_PASSWORD=universalblue \
	WEB_UI=false \
	ADDITIONAL_TEMPLATES=/build-container-installer/build/files/iso/anaconda-storage.tmpl \
	IMAGE_SRC="$IMAGE_SRC" \
	VERSION=44
