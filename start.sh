#!/usr/bin/env bash

if ! command -v sed 1>/dev/null; then
	echo "Please install sed and run the script again."
	exit 1
fi

scriptdir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

cd "${scriptdir}" || exit 1

if [ ! -d wine ]; then
	if [ "$(getconf LONG_BIT)" = 64 ]; then
		mv wine_x64 wine
		sed -i 's/WINEARCH=win32/WINEARCH=win64/' start-actual.sh
	else
		mv wine_x32 wine
	fi
fi

exec ./start-actual.sh
