#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Fewtarius

INSTALLPATH="/storage/roms/ports"
PORTNAME="half-life"

rm -rf "${INSTALLPATH}/${PORTNAME}"
rm -f "${INSTALLPATH}/Half Life.sh"

for image in system-half-life.png  system-half-life-thumb.png
do
  rm "${INSTALLPATH}/images/${image}"
done
