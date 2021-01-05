#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Fewtarius

INSTALLPATH="/storage/roms/ports"
PKG_NAME="half-life"
PKG_FILE="Half-Life.zip"
PKG_VERSION="1.0.0"
PKG_SHASUM="9cfa63125469ef7bb3b85722ff6992df06fef61be7a5c8ead16a58eb61ac569a"
SOURCEPATH=$(pwd)

### Test and make the full path if necessary.
if [ ! -d "${INSTALLPATH}/${PKG_NAME}" ]
then
  mkdir -p "${INSTALLPATH}/${PKG_NAME}"
fi

cd ${INSTALLPATH}/${PKG_NAME}

curl -Lo ${PKG_FILE} https://github.com/krishenriksen/Half-Life-rg351p/releases/download/${PKG_VERSION}/${PKG_FILE}
BINSUM=$(sha256sum ${bin} | awk '{print $1}')
if [ ! "${PKG_SHASUM}" == "${BINSUM}" ]
then
  echo "Checksum mismatch, please update the package."
  exit 1
fi

unzip -o ${PKG_NAME}
rm -f Half-Life.sh
mv Half-Life/* .
rmdir Half-Life

unzip -o "Copy Contents into valve folder.zip"
mv 'Copy Contents into valve folder' 'dependencies' 2>/dev/null
rm -f "Copy Contents into valve folder.zip"

### Create the start script
cat <<EOF >${INSTALLPATH}/"Half Life.sh"
export LD_LIBRARY_PATH=${INSTALLPATH}/${PKG_NAME}:/usr/lib

cd ${INSTALLPATH}/${PKG_NAME}

if [ ! -d "valve" ]
then
  mkdir "valve"
  echo "Unable to find game data.  Please copy to ${INSTALLPATH}/${PKG_NAME}/valve" >>/tmp/logs/emuelec.log
  exit 1
else
  rsync -av dependencies/* valve
  ./xash3d -fullscreen -console -sdl_joy_old_api
fi


ret_error=\$?
[[ "\$ret_error" != 0 ]] && (echo "Error executing Half Life.  Please check that you have copied your game data to ${INSTALLPATH}/${PKG_NAME}/valve." >/tmp/logs/emuelec.log)
EOF

### Add Half Life images
if [ ! -d "${INSTALLPATH}/images" ]
then
  mkdir -p "${INSTALLPATH}/images"
fi

for image in system-half-life.png  system-half-life-thumb.png
do
  cp "${SOURCEPATH}/${PKG_NAME}/${image}" "${INSTALLPATH}/images"
done

### Add Half Life to the game list
if [ ! "$(grep -q 'Half Life' ${INSTALLPATH}/gamelist.xml)" ]
then
	### Add to the game list
	xmlstarlet ed --omit-decl --inplace \
		-s '//gameList' -t elem -n 'game' \
		-s '//gameList/game[last()]' -t elem -n 'path'        -v './Half Life.sh'\
		-s '//gameList/game[last()]' -t elem -n 'name'        -v 'Half Life'\
		-s '//gameList/game[last()]' -t elem -n 'desc'        -v 'Half-Life is a series of first-person shooter games developed and published by Valve.'\
		-s '//gameList/game[last()]' -t elem -n 'image'       -v './images/system-half-life.png'\
		-s '//gameList/game[last()]' -t elem -n 'video'       -v './images/system-half-life.mp4'\
		-s '//gameList/game[last()]' -t elem -n 'thumbnail'   -v './images/system-half-life-thumb.png'\
		-s '//gameList/game[last()]' -t elem -n 'rating'      -v '1.0'\
		-s '//gameList/game[last()]' -t elem -n 'releasedate' -v '19981119T000000'\
		-s '//gameList/game[last()]' -t elem -n 'developer'   -v 'Valve'\
		-s '//gameList/game[last()]' -t elem -n 'publisher'   -v 'Valve'\
		${INSTALLPATH}/gamelist.xml
fi
