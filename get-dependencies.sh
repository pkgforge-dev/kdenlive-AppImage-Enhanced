#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	fuse3           \
	kdenlive        \
	kio-extras      \
	pipewire-audio  \
	pipewire-jack   \
	qt6ct

if [ "$ARCH" = 'x86_64' ]; then
		pacman -Syu --noconfirm libva-intel-driver
fi

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common intel-media-driver-mini

# don't let qt6-webengine be bundled
pacman -Rsndd --noconfirm qt6-webengine

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here
