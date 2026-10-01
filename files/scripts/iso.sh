#!/usr/bin/env bash
set -e

sudo bluebuild build \
	--build-driver podman \
	--build-chunked-oci \
	--archive "$PWD/.bb-tmp" \
	recipes/recipe.yml \
	-v

sudo podman run --rm --privileged \
	-v "$PWD":/build-container-installer/build \
	-v dnf-cache:/cache/dnf \
	-v "$PWD/.bb-tmp":/img_src \
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
	IMAGE_SRC=oci-archive:/img_src/citadel.gz \
	VERSION=44
