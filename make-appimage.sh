#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q kdenlive | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/256x256/apps/kdenlive.png
export DESKTOP=/usr/share/applications/org.kde.kdenlive.desktop
export DEPLOY_OPENGL=1
export DEPLOY_PIPEWIRE=1
export OPTIMIZE_LAUNCH=1
export DEPLOY_P11KIT=1

# Deploy dependencies
quick-sharun \
	/usr/bin/kdenlive*                        \
	/usr/bin/melt*                            \
	/usr/bin/ffmpeg                           \
	/usr/bin/ffprobe                          \
	/usr/bin/ffplay                           \
	/usr/lib/ossl-modules/*                   \
	/usr/lib/libQt6QuickControls2Basic*       \
	/usr/lib/libbz2.so*                       \
	/usr/lib/kf6                              \
	/usr/lib/mlt*                             \
	/usr/lib/qt6/plugins/kcdm_trash.so        \
	/usr/lib/qt6/plugins/kfileaudiopreview.so \
	/usr/lib/qt6/plugins/texttospeech         \
	/usr/lib/qt6/plugins/kf6                  \
	/usr/lib/qt6/plugins/kiconthemes6/*/*     \
	/usr/lib/qt6/plugins/qmlls                \
	/usr/share/kf6                            \
	/usr/share/kio_filenamesearch             \
	/usr/share/kio_info                       \
	/usr/share/knotifications6                \
	/usr/share/mlt*                           \
	/usr/share/ffmpeg

echo 'SDL_AUDIODRIVER=pulseaudio'                           >> ./AppDir/.env
echo 'FREI0R_PATH=${SHARUN_DIR}/lib/frei0r-1'               >> ./AppDir/.env
echo 'MLT_PROFILES_PATH=${SHARUN_DIR}/share/mlt-7/profiles' >> ./AppDir/.env
echo 'MLT_PRESETS_PATH=${SHARUN_DIR}/share/mlt-7/presets'   >> ./AppDir/.env
echo 'PACKAGE_TYPE=appimage'                                >> ./AppDir/.env

for lib in $(find ./AppDir/lib/qt6/qml -type f -name '*.so*'); do
	ldd "$lib" | awk -F"[> ]" '{print $4}' | xargs -I {} cp -vn {} ./AppDir/lib || :
done

# Turn AppDir into AppImage
quick-sharun --make-appimage
