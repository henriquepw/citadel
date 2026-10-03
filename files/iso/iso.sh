#!/usr/bin/env bash
set -e

TMP="$PWD/.bb-tmp"

sudo mkdir -p "$TMP"
sudo rm -f "$TMP"/citadel.gz

sudo bluebuild build \
	--build-chunked-oci \
	recipes/recipe.yml \
	-v

sudo podman save --format oci-archive \
	-o "$TMP/citadel.gz" \
	localhost/citadel:latest_linux_amd64

sudo podman run --rm --privileged \
	-v "$PWD":/build-container-installer/build \
	-v dnf-cache:/cache/dnf \
	-v "$TMP":/img_src \
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

sudo podman rmi localhost/citadel:latest_linux_amd64
