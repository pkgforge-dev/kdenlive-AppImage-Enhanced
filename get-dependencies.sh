#!/bin/sh

set -eux

ARCH="$(uname -m)"
EXTRA_PACKAGES="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"

pacman -Syu --noconfirm \
	base-devel       \
	curl             \
	fuse3            \
	git              \
	kdenlive         \
	kio-extras       \
	libxcb           \
	libxcursor       \
	libxi            \
	libxkbcommon-x11 \
	libxrandr        \
	libxtst          \
	pipewire-audio   \
	pulseaudio       \
	pulseaudio-alsa  \
	qt6ct            \
	wget             \
	xorg-server-xvfb \
	zsync

if [ "$ARCH" = 'x86_64' ]; then
		pacman -Syu --noconfirm libva-intel-driver
fi

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$EXTRA_PACKAGES" -O ./get-debloated-pkgs.sh
chmod +x ./get-debloated-pkgs.sh
./get-debloated-pkgs.sh --add-common intel-media-driver-mini

# don't let qt6-webengine be bundled
pacman -Rsndd --noconfirm qt6-webengine

pacman -Q kdenlive | awk '{print $2; exit}' > ~/version
