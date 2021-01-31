#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2020-present Fewtarius
# Copyright (C) 2020-present Cebion

# Load functions needed to send messages to the console
. /etc/profile

unset MYARCH
MYARCH="aarch64"
LINK="https://github.com/Cebion/packages/raw/main/misc/drastic.tar.gz"
SHASUM="561fd70cf5c45c55892b9bdef4c376b0c7a1572e7bfa49c32adcc39eeb225a4e"

INSTALL_PATH="/storage/drastic"
BINARY="drastic"
LINKDEST="${INSTALL_PATH}/${MYARCH}/drastic.tar.gz"
CFG="/storage/.emulationstation/es_systems.cfg"
START_SCRIPT="$BINARY.sh"

mkdir -p "${INSTALL_PATH}/${MYARCH}/"

curl -Lo $LINKDEST $LINK
CHECKSUM=$(sha256sum $LINKDEST | awk '{print $1}')
if [ ! "${SHASUM}" == "${CHECKSUM}" ]
then
  rm "${LINKDEST}"
  exit 1
fi

tar xvf $LINKDEST -C "${INSTALL_PATH}/${MYARCH}/"
rm $LINKDEST

if grep -q '<name>nds</name>' "$CFG"
then
	xmlstarlet ed -L -P -d "/systemList/system[name='nds']" $CFG
fi

	echo 'Adding Drastic to systems list'
	xmlstarlet ed --omit-decl --inplace \
		-s '//systemList' -t elem -n 'system' \
		-s '//systemList/system[last()]' -t elem -n 'name' -v 'nds'\
		-s '//systemList/system[last()]' -t elem -n 'fullname' -v 'Nintendo DS'\
		-s '//systemList/system[last()]' -t elem -n 'path' -v '/storage/roms/nds'\
		-s '//systemList/system[last()]' -t elem -n 'manufacturer' -v 'Nintendo'\
		-s '//systemList/system[last()]' -t elem -n 'release' -v '2005'\
		-s '//systemList/system[last()]' -t elem -n 'hardware' -v 'portable'\
		-s '//systemList/system[last()]' -t elem -n 'extension' -v '.nds .zip .NDS .ZIP'\
		-s '//systemList/system[last()]' -t elem -n 'command' -v "/emuelec/scripts/$START_SCRIPT %ROM%"\
		-s '//systemList/system[last()]' -t elem -n 'platform' -v 'nds'\
		-s '//systemList/system[last()]' -t elem -n 'theme' -v 'nds'\
		$CFG

read -d '' content <<EOF
#!/bin/sh
source /etc/profile
BINPATH="/usr/bin"
EMUELECLOG="/tmp/logs/emuelec.log"

cd ${INSTALL_PATH}/${MYARCH}/drastic/
maxperf
./drastic "\$1" >> \$EMUELECLOG 2>&1
normperf
EOF
echo "$content" > ${INSTALL_PATH}/${START_SCRIPT}
chmod +x ${INSTALL_PATH}/${START_SCRIPT}
if [ -f /storage/.config/emulationstation/scripts/drastic.sh ]
then
  rm -f /storage/.config/emulationstation/scripts/drastic.sh
fi
mkdir ${INSTALL_PATH}/${MYARCH}/drastic/config
cp drastic/drastic.cfg ${INSTALL_PATH}/${MYARCH}/drastic/config 2>/dev/null ||:
ln -sf ${INSTALL_PATH}/${START_SCRIPT} /storage/.config/emuelec/scripts/drastic.sh
