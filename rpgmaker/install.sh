#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Fewtarius

INSTALLPATH="/storage/roms/bios"
SOURCEPATH="$(pwd)"
PKG_NAME="rpgmaker"
PKG_VERSION="1.0.0"
PKG_URL="https://dl.degica.com/rpgmakerweb/run-time-packages"

install_bios() {
  BIOS="$1"
  BIOSPATH="$2"
  if [ -d "${INSTALLPATH}/${BIOSPATH}" ]
  then
    rm -rf "${INSTALLPATH}/${BIOSPATH}"
  fi
  mkdir -p "${INSTALLPATH}/${BIOSPATH}"
  cd "${INSTALLPATH}/${BIOSPATH}"
  curl -Lo "${BIOS}" "${PKG_URL}/${BIOS}"
  BINSUM=$(sha256sum "${BIOS}" | awk '{print $1}')
  SHASUM=$(cat ${SOURCEPATH}/${PKG_NAME}/SHA256SUMS | awk '/'${BIOS}'/ {print $1}')
  if [ ! "${SHASUM}" == "${BINSUM}" ]
  then
    echo "Checksum mismatch, please update the package."
    exit 1
  fi
  if [[ "${BIOS}" =~ .zip$ ]]
  then
    /usr/bin/7z x "${BIOS}"
    rm "${BIOS}"
    BIOS="$(echo ${BIOS} | sed "s#.zip#.exe#")"
  fi
  /usr/bin/7z x "${BIOS}"
  rm "${BIOS}"
  cd ${SOURCEPATH}
}

install_bios rpg2000_rtp_installer.exe rtp/2000
install_bios rpg2003_rtp_installer.zip rtp/2003

### This package is just to fetch data, so nothing else to do.
