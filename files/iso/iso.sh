#!/usr/bin/env bash
set -e

IMAGE=localhost/citadel:latest_linux_amd64

# No chunking: the installed system rebases to the CI-built image anyway
time sudo bluebuild build \
	recipes/recipe.yml \
	-v

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
	IMAGE_SRC=containers-storage:$IMAGE \
	VERSION=44
