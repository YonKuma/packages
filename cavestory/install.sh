#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Fewtarius

INSTALLPATH="/storage/roms/ports"
PKG_NAME="cavestory"
PKG_VERSION="1.0.0"
PKG_URL="https://www.cavestory.org/downloads/"
PKG_FILE="cavestoryen.zip"
PKG_SHASUM="aa87fa30bee9b4980640c7e104791354e0f1f6411ee0d45a70af70046aa0685f"

cd ${INSTALLPATH}

curl -Lo ${PKG_FILE} ${PKG_URL}/${PKG_FILE}
BINSUM=$(sha256sum ${PKG_FILE} | awk '{print $1}')
if [ ! "${PKG_SHASUM}" == "${BINSUM}" ]
then
  echo "Checksum mismatch, please update the package."
  exit 1
fi

unzip -o "${PKG_FILE}"
rm -f "${PKG_FILE}"

### This package is just to fetch data, so nothing else to do.
