#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Fewtarius

INSTALLPATH="/storage/roms/ports"
PKG_NAME="opentyrian"
PKG_VERSION="1.0.0"
PKG_URL="http://camanis.net/tyrian"
PKG_FILE="tyrian21.zip"
PKG_SHASUM="7790d09a2a3addcd33c66ef063d5900eb81cc9c342f4807eb8356364dd1d9277"

cd ${INSTALLPATH}

curl -Lo ${PKG_FILE} ${PKG_URL}/${PKG_FILE}
BINSUM=$(sha256sum ${PKG_FILE} | awk '{print $1}')
if [ ! "${PKG_SHASUM}" == "${BINSUM}" ]
then
  echo "Checksum mismatch, please update the package."
  exit 1
fi

unzip -o "${PKG_FILE}"
mv tyrian21/* .
rmdir tyrian21
rm -f "${PKG_FILE}"

### This package is just to fetch data, so nothing else to do.
