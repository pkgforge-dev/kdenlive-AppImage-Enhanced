#!/bin/sh

set -eux

ARCH="$(uname -m)"
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"
VERSION="$(cat ~/version)"

export ADD_HOOKS="self-updater.bg.hook"
export ICON=/usr/share/icons/hicolor/256x256/apps/kdenlive.png
export DESKTOP=/usr/share/applications/org.kde.kdenlive.desktop
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export OUTNAME=kdenlive-"$VERSION"-anylinux-"$ARCH".AppImage
export DEPLOY_OPENGL=1
export DEPLOY_PIPEWIRE=1

# Deploy dependencies
PLUGIN_DIR=/usr/lib/qt6/plugins
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun \
	/usr/bin/kdenlive*                  \
	/usr/bin/melt*                      \
	/usr/bin/ffmpeg                     \
	/usr/bin/ffprobe                    \
	/usr/bin/ffplay                     \
	/usr/lib/pkcs11/*                   \
	/usr/lib/ossl-modules/*             \
	/usr/lib/libQt6QuickControls2Basic* \
	/usr/lib/libbz2.so*                 \
	/usr/lib/kf6/*                      \
	"$PLUGIN_DIR"/kcdm_trash.so         \
	"$PLUGIN_DIR"/kfileaudiopreview.so  \
	"$PLUGIN_DIR"/texttospeech/*        \
	"$PLUGIN_DIR"/kf6/*                 \
	"$PLUGIN_DIR"/kf6/*/*               \
	"$PLUGIN_DIR"/kf6/*/*/*             \
	"$PLUGIN_DIR"/kiconthemes6/*/*      \
	"$PLUGIN_DIR"/qmlls/*

cp -rv /usr/share/kf6                 ./AppDir/share
cp -rv /usr/share/kio_filenamesearch  ./AppDir/share
cp -rv /usr/share/kio_info            ./AppDir/share
cp -rv /usr/share/knotifications6     ./AppDir/share
cp -rv /usr/share/mlt*                ./AppDir/share
cp -rv /usr/share/ffmpeg              ./AppDir/share

echo 'SDL_AUDIODRIVER=pulseaudio'                           >> ./AppDir/.env
echo 'FREI0R_PATH=${SHARUN_DIR}/lib/frei0r-1'               >> ./AppDir/.env
echo 'MLT_PROFILES_PATH=${SHARUN_DIR}/share/mlt-7/profiles' >> ./AppDir/.env
echo 'MLT_PRESETS_PATH=${SHARUN_DIR}/share/mlt-7/presets'   >> ./AppDir/.env
echo 'PACKAGE_TYPE=appimage'                                >> ./AppDir/.env

for lib in $(find ./AppDir/lib/qt6/qml -type f -name '*.so*'); do
	ldd "$lib" | awk -F"[> ]" '{print $4}' | xargs -I {} cp -vn {} ./AppDir/lib || :
done

# MAKE APPIMAGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage

echo "All Done!"
