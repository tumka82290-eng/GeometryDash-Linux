#!/usr/bin/env bash

########################################################################
##
## Project name: Wine launch wrapper
## Version: 1.3.11
## Author: Kron4ek
## Contact emails: kron4ek@protonmail.com, kron4ek@gmail.com
## My GitHub profile: https://github.com/Kron4ek
##
## Links to the latest version and documentation:
##
## Google Drive: https://drive.google.com/open?id=1fTfJQhQSzlEkY-j3g0H6p4lwmQayUNSR
## MEGA: https://mega.nz/folder/oY01CKzD#5VaFPNvaUDT0j39FUqwrdQ
##
## This is a script for creating and running portable Wine applications.
## It should work on all Linux distributions that have the bash shell and
## the standard GNU utilities. And wget is (optionally) needed for the
## script to be able to download winetricks.
##
########################################################################

## Exit if the script is running with root rights
## If you really need this for some reason and you absolutely know what you
## are doing, then just remove this if block

if [ "$EUID" = 0 ]; then
  echo "Please do not run this script as root!"
  exit 1
fi

## Show available arguments

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
	clear
	echo -e "Available arguments:\n"
	echo -e "--cfg\t\t\t\tRun winecfg"
	echo -e "--reg\t\t\t\tRun regedit"
	echo -e "--fm\t\t\t\tRun Wine file manager"
	echo -e "--kill\t\t\t\tKill all processes running in the prefix"
	echo -e "--tricks\t\t\tRun winetricks with the specified arguments"
	echo -e "\t\t\t\t(for example, ./start.sh --tricks vcrun2015)"
	echo -e "--debug\t\t\t\tShow more information when running Wine"
	echo -e "--shortcuts\t\t\tAdd shortcuts to launch the script on"
	echo -e "\t\t\t\tthe desktop and the applications menu"
	echo -e "\t\t\t\tIf the shortcuts already exist, they will be"
	echo -e "\t\t\t\tremoved."
	echo -e "--clear\t\t\t\tRemove all files and directories"
	echo -e "\t\t\t\t(except the settings_* and winetricks)"
	echo -e "\t\t\t\tcreated by the script."
	echo -e "\t\t\t\tThis will likely remove all game settings and"
	echo -e "\t\t\t\tsaves. Use with caution!"
	echo -e "\nAll other arguments that don't match any of the above"
	echo "will be passed to the game itself."

	exit
fi

export script="$(readlink -f "${BASH_SOURCE[0]}")"
export scriptdir="$(dirname "$script")"

cd "${scriptdir}" || exit 1

## Set path to Wine binaries

export WINE="${scriptdir}"/wine/bin/wine
export WINE64="${scriptdir}"/wine/bin/wine64
export WINESERVER="${scriptdir}"/wine/bin/wineserver
export USE_SYSTEM_WINE=0

## Set path to Wine prefix

export WINEPREFIX="${scriptdir}"/prefix

## By default, when the script recreates the prefix, it renames the old
## prefix to WINEPREFIX_old_DATE. This is useful because the old prefix may
## contain important information that you might want to move to the new
## prefix manually.
##
## Enable this variable to just remove old prefixes instead of
## renaming them.

export REMOVE_OLD_PREFIXES=0

## Set the path to the documents directory
## This directory will be used to store games saves and settings
## Except when the game stores its saves in its own directory

export DOCUMENTS_DIR="${scriptdir}"/documents

## Set the path to the directory with temporary files used by the script

export TEMPFILES_DIR="${scriptdir}"/temp_files

## Set prefix architecture
## win64 for 64-bit apps, win32 for 32-bit apps
## Even though win64 can run 32-bit apps too, the script expects that
## you will use win32 for 32-bit apps

export WINEARCH=win32

## Disable Wine debug

export WINEDEBUG="-all"

## Set Windows version
## Available values: winxp, win7, win8, win10, default.
## This only has effect during the prefix (re)creation

export WINDOWS_VERSION=default

## Enable this only if Wine hangs when creating prefix
## You need to remove the prefix directory after enabling this
## Workaround for the bug: https://bugs.winehq.org/show_bug.cgi?id=51086

export PREFIX_HANG_FIX=1

## Enable ESYNC/FSYNC
## It's safe to enable both of them simultaneously
## Wine will prefer FSYNC if it's supported by kernel, otherwise it will
## use ESYNC
##
## FUTEX2 depends on FSYNC. If you disable FSYNC, then FUTEX2 won't work too
## FUTEX2 may cause issues in some games

export WINEESYNC=0
export WINEFSYNC=0
export WINEFSYNC_FUTEX2=0

#export WINE_SIMULATE_ASYNC_READ=1
#export WINE_FSYNC_SIMULATE_SCHED_QUANTUM=1
#export WINE_ALERT_SIMULATE_SCHED_QUANTUM=1
#export WINE_FSYNC_YIELD_TO_WAITERS=1
#export WINE_SIMULATE_WRITECOPY=1
#export WINE_KERNEL_STACK_SIZE=64
#export WINE_DISABLE_KERNEL_WRITEWATCH=1

## Limit the amount of CPU cores for Wine applications
## Some games do not work when there are many CPU threads

#export WINE_CPU_TOPOLOGY=12:0,1,2,3,4,5,6,7,8,9,10,11
#export WINE_LOGICAL_CPUS_AS_CORES=1

## Enable LARGE_ADDRESS_AWARE
## Useful for 32-bit games hitting address space limitations

export WINE_LARGE_ADDRESS_AWARE=1

## FShack and FSR (AMD FidelityFX Super Resolution) variables

export WINE_FULLSCREEN_FSR=1
export WINE_FULLSCREEN_FSR_STRENGTH=2
#export WINE_FULLSCREEN_FSR_MODE="ultra"
#export WINE_FULLSCREEN_FSR_CUSTOM_MODE="2560x1440"
#export WINE_ADDITIONAL_DISPLAY_MODES=0
#export WINE_FULLSCREEN_INTEGER_SCALING=1
#export WINE_DISABLE_FULLSCREEN_HACK=1
#export WINE_DISABLE_VK_CHILD_WINDOW_RENDERING_HACK=1

## Disable pesky winemenubuilder which pollutes application menus

export WINEDLLOVERRIDES="winemenubuilder.exe="

## Set the cache directory

export XDG_CACHE_HOME="${scriptdir}"/cache

## Nvidia-related variables

export __GL_SHADER_DISK_CACHE_SIZE=2147483648
export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
export __GL_SHADER_DISK_CACHE_PATH="${XDG_CACHE_HOME}"/nvidia
#export __GL_THREADED_OPTIMIZATIONS=1
#export WINE_HIDE_NVIDIA_GPU=1
#export WINE_GL_HIDE_NVIDIA=1

## Enable DLSS and raytracing support in games on RTX Nvidia GPUs
## Note that simply enabling this variable is not enough for DLSS to work
## You will also need to put nvapi64.dll (from dxvk-nvapi) into game_info/dlls
## And you will probably need to use Wine-Proton instead of regular Wine
## And, of course, also latest DXVK and vkd3d-proton and not very old
## videodrivers

export ENABLE_RT_DLSS=0

## DXVK variables

export DXVK_LOG_PATH="${XDG_CACHE_HOME}"/dxvk
export DXVK_STATE_CACHE_PATH="${XDG_CACHE_HOME}"/dxvk
export DXVK_CONFIG_FILE="${scriptdir}"/dxvk.conf
export DXVK_LOG_LEVEL=none
export DXVK_HUD=0
export DISABLE_DXVK=0
#export DXVK_STATE_CACHE=0
#export DXVK_FRAME_RATE=60
#export DXVK_FILTER_DEVICE_NAME="AMD"

## This variable works only with DXVK with the async patch applied

export DXVK_ASYNC=1

## VKD3D variables

export USE_BUILTIN_VKD3D=0
export VKD3D_DEBUG=none
export VKD3D_SHADER_DEBUG=none
export VKD3D_SHADER_CACHE_PATH="K:\\cache"
export VKD3D_SHADER_MODEL=6_7
#export VKD3D_FEATURE_LEVEL=12_2
#export VKD3D_FILTER_DEVICE_NAME="AMD"

## Wine-Staging variables

#export STAGING_SHARED_MEMORY=1
#export STAGING_WRITECOPY=1

## Set realtime priority for the wineserver
## This usually improves performance
## 99 is the highest, but is not recommended.
##
## This requires the ability to set realtime priorities for processes
## This ability can be configured in /etc/security/limits.conf

#export STAGING_RT_PRIORITY_SERVER=90

## If this is enabled, the script will store the Wine prefix and the documents
## directory in /home/username/.local/share/games/GAMENAME
##
## Enable this if you are using NTFS filesystem and encounter problems
## starting the game.

export NTFS_MODE=0

## File descriptors limit for Esync
## Values lower than 1 million are not recommended
## ESYNC will be automatically disabled by the script if ulimit
## fails to set the required limit
##
## This requires the ability to increase file descriptors limit
## This ability can be configured in /etc/security/limits.conf

export ULIMIT_SIZE=1000000

## Enable Wine virtual desktop

export VIRTUAL_DESKTOP=0
export VIRTUAL_DESKTOP_SIZE="1280x720"

## Restore screen resolution after Wine terminates

export RESTORE_RESOLUTION=0

## Set the locale. This is useful for games that set their language
## depending on the system locale being used.

#export LANG=ru_RU.UTF-8

## Useful when a game doesn't work

export ENABLE_DEBUG=0

## Disable dlls. Comma separated list.

#export DISABLE_DLLS="winegstreamer,d3d12"

## May be useful for games with native OpenGL renderer on AMD/Intel GPUs

#export mesa_glthread=true

## Enable MangoHud for Vulkan applications if it's installed

#export MANGOHUD=1

## Make Wine binaries executable

if [ -f "${WINE}" ] && [ ! -x "${WINE}" ]; then
	chmod +x "${WINE}"
fi

if [ -f "${WINE64}" ] && [ ! -x "${WINE64}" ]; then
	chmod +x "${WINE64}"
fi

if [ -f "${WINESERVER}" ] && [ ! -x "${WINESERVER}" ]; then
	chmod +x "${WINESERVER}"
fi

## If a Wine build is fully 64-bit, make a symlink from wine64 to wine

if [ ! -f "${WINE}" ] && [ -f "${WINE64}" ]; then
	cp "${WINE64}" "${WINE}"
fi

script_name="$(basename "${script}" | cut -d. -f1)"
settings_file=settings_"${script_name}"

## Generate settings file

if [ ! -f "${settings_file}" ]; then
	cat <<EOF > "${settings_file}"
export USE_SYSTEM_WINE=${USE_SYSTEM_WINE}
export RESTORE_RESOLUTION=${RESTORE_RESOLUTION}
export VIRTUAL_DESKTOP=${VIRTUAL_DESKTOP}
export VIRTUAL_DESKTOP_SIZE="${VIRTUAL_DESKTOP_SIZE}"
export DISABLE_DXVK=${DISABLE_DXVK}
export DXVK_HUD=${DXVK_HUD}
export DXVK_ASYNC=${DXVK_ASYNC}
export USE_BUILTIN_VKD3D=${USE_BUILTIN_VKD3D}
export ENABLE_DEBUG=${ENABLE_DEBUG}
export ENABLE_RT_DLSS=${ENABLE_RT_DLSS}
export NTFS_MODE=${NTFS_MODE}
export WINEESYNC=${WINEESYNC}
export WINEFSYNC=${WINEFSYNC}
export WINEFSYNC_FUTEX2=${WINEFSYNC_FUTEX2}
export WINE_LARGE_ADDRESS_AWARE=${WINE_LARGE_ADDRESS_AWARE}
export WINE_FULLSCREEN_FSR=${WINE_FULLSCREEN_FSR}
export WINE_FULLSCREEN_FSR_STRENGTH=${WINE_FULLSCREEN_FSR_STRENGTH}
export PREFIX_HANG_FIX=${PREFIX_HANG_FIX}
export ULIMIT_SIZE=${ULIMIT_SIZE}
export WINEARCH=${WINEARCH}
export WINDOWS_VERSION=${WINDOWS_VERSION}
export REMOVE_OLD_PREFIXES=${REMOVE_OLD_PREFIXES}
export VKD3D_SHADER_MODEL=${VKD3D_SHADER_MODEL}

#export DXVK_STATE_CACHE=0
#export DXVK_FRAME_RATE=60
#export DXVK_FILTER_DEVICE_NAME="AMD"
#export VKD3D_FILTER_DEVICE_NAME="AMD"
#export VKD3D_FEATURE_LEVEL=12_2
#export STAGING_SHARED_MEMORY=1
#export STAGING_WRITECOPY=1
#export STAGING_RT_PRIORITY_SERVER=90
#export LANG=ru_RU.UTF-8
#export DISABLE_DLLS="winegstreamer,d3d12"
#export WINE_HIDE_NVIDIA_GPU=1
#export WINE_GL_HIDE_NVIDIA=1
#export WINE_FULLSCREEN_FSR_MODE="ultra"
#export WINE_FULLSCREEN_FSR_CUSTOM_MODE="2560x1440"
#export WINE_ADDITIONAL_DISPLAY_MODES=0
#export WINE_FULLSCREEN_INTEGER_SCALING=1
#export WINE_DISABLE_FULLSCREEN_HACK=1
#export WINE_DISABLE_VK_CHILD_WINDOW_RENDERING_HACK=1
#export WINE_CPU_TOPOLOGY=12:0,1,2,3,4,5,6,7,8,9,10,11
#export WINE_LOGICAL_CPUS_AS_CORES=1
#export WINE_SIMULATE_ASYNC_READ=1
#export WINE_FSYNC_SIMULATE_SCHED_QUANTUM=1
#export WINE_ALERT_SIMULATE_SCHED_QUANTUM=1
#export WINE_FSYNC_YIELD_TO_WAITERS=1
#export WINE_SIMULATE_WRITECOPY=1
#export WINE_KERNEL_STACK_SIZE=64
#export WINE_DISABLE_KERNEL_WRITEWATCH=1
#export mesa_glthread=true
#export __GL_THREADED_OPTIMIZATIONS=1
#export MANGOHUD=1

## You can also put any custom environment variables in this file
EOF
fi

source "${settings_file}"

if [ -n "${DISABLE_DLLS}" ]; then
	export WINEDLLOVERRIDES="${DISABLE_DLLS}=;${WINEDLLOVERRIDES}"
fi

## Use system Wine if needed

if [ ! -f "${WINE}" ] || [ "${USE_SYSTEM_WINE}" = 1 ]; then
	export WINE=wine
	export WINE64=wine64
	export WINESERVER=wineserver

	USE_SYSTEM_WINE=1
fi

## Check if the Wine binary works at all

if ! "${WINE}" --version &>/dev/null; then
	"${WINE}" --version
	echo "There is a problem running Wine binary!"
	exit 1
fi

## Disable ESYNC if ulimit fails to set the minimum required limit

ulimit_hardlimit="$(ulimit -Hn)"
if [ "${ulimit_hardlimit}" -ge ${ULIMIT_SIZE} ]; then
	ulimit -n "${ulimit_hardlimit}" 2>/dev/null
else
	export WINEESYNC=0
fi

## Disable restoring screen resolution if there is no xrandr

if ! command -v xrandr 1>/dev/null; then
	export RESTORE_RESOLUTION=0
fi

## Check if sed is installed

if ! command -v sed 1>/dev/null; then
	echo "Please install sed and run the script again."
	exit 1
fi

## Use the game_info_SCRIPTNAME.txt file if it exists
## Otherwise use the game_info.txt file

if [ -f "${scriptdir}"/game_info/game_info_"${script_name}".txt ]; then
	GAME_INFO="$(cat "${scriptdir}"/game_info/game_info_"${script_name}".txt)"
else
	GAME_INFO="$(cat "${scriptdir}"/game_info/game_info.txt)"
fi

if [ -z "${GAME_INFO}" ]; then
	clear
	echo "There is no game_info.txt file!"
	exit 1
fi

VERSION="$(echo "${GAME_INFO}" | sed -n 2p)"
EXE="$(echo "${GAME_INFO}" | sed -n 3p)"
ARGS="$(echo "${GAME_INFO}" | sed -n 4p)"
ADDITIONAL_PATH="$(echo "${GAME_INFO}" | sed -n 5p)"
GAME="$(echo "${GAME_INFO}" | sed -n 6p)"

ntfs_mode () {
	mkdir -p "${HOME}"/.local/share/games/"${GAME}"

	export XDG_CACHE_HOME="${HOME}"/.local/share/games/"${GAME}"/cache
	export WINEPREFIX="${HOME}"/.local/share/games/"${GAME}"/prefix
	export DOCUMENTS_DIR="${HOME}"/.local/share/games/"${GAME}"/documents
	export TEMPFILES_DIR="${HOME}"/.local/share/games/"${GAME}"/temp_files
}

if [ "${NTFS_MODE}" = 1 ] || \
   [ -f "${HOME}"/.local/share/games/"${GAME}"/temp_files/force_ntfs_mode ] || \
   ! touch "${scriptdir}"/write_test &>/dev/null; then
		export NTFS_MODE=1
		ntfs_mode
fi
rm -f "${scriptdir}"/write_test

GAME_PATH="${WINEPREFIX}"/drive_c/"$(echo "${GAME_INFO}" | sed -n 1p)"

## Function for retreiving a list of files of the game_info directory
## When the list of files changes, the WINEPREFIX is recreated

list_game_info_content() {
	for dir in game_info/*/; do
		if [ "${dir}" != "game_info/data/" ]; then
			GAME_INFO_CONTENT="$(LC_ALL=C ls "${dir}" 2>/dev/null) ${GAME_INFO_CONTENT}"
		fi
	done
}

## A function to download winetricks
## It's only used if the winetricks_list.txt file exists
## Or if the script is launched with the --tricks argument

download_winetricks() {
	unset missing_deps
	winetricks_deps="wget cabextract"

	for i in ${winetricks_deps}; do
		if ! command -v ${i} 1>/dev/null; then
			missing_deps="${i} ${missing_deps}"
		fi
	done

	if [ -n "${missing_deps}" ]; then
		echo "Please install these packages: ${missing_deps}"
		echo "After that run the script again"
		return 1
	fi

	if [ ! -s winetricks ]; then
		rm -f winetricks

		echo "Downloading winetricks..."
		wget -q -O winetricks "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks"
	fi

	if [ -s winetricks ]; then
		if [ ! -x winetricks ]; then
			chmod +x winetricks
		fi

		if [ ! -L "${XDG_CACHE_HOME}"/winetricks ]; then
			if [ -d "${XDG_CACHE_HOME}"/winetricks ]; then
				rm -rf "${XDG_CACHE_HOME}"/winetricks
			fi

			mkdir -p "${XDG_CACHE_HOME}"
			mkdir -p winetricks_cache
			ln -sr winetricks_cache "${XDG_CACHE_HOME}"/winetricks
		fi

		return 0
	else
		echo "winetricks is missing"
		echo "Perhaps you have no internet connection"
		return 1
	fi
}

prefix_init_error() {
		clear
		echo "There is a problem initializing the Wine prefix!"
		echo "Check ${TEMPFILES_DIR}/wineboot.log for more information."

		rm -rf "${WINEPREFIX}"
		exit 1
}

get_system_info() {
	rm -f "${TEMPFILES_DIR}"/sysinfo

	ldd --version &>>"${TEMPFILES_DIR}"/sysinfo
	echo >>"${TEMPFILES_DIR}"/sysinfo

	if command -v inxi 1>/dev/null; then
		inxi -b &>>"${TEMPFILES_DIR}"/sysinfo
		echo >>"${TEMPFILES_DIR}"/sysinfo
	else
		uname -a &>>"${TEMPFILES_DIR}"/sysinfo
		echo >>"${TEMPFILES_DIR}"/sysinfo

		if command -v lspci 1>/dev/null; then
			lspci | grep VGA &>>"${TEMPFILES_DIR}"/sysinfo
			echo >>"${TEMPFILES_DIR}"/sysinfo
		fi

		if [ -f /etc/os-release ]; then
			cat /etc/os-release >>"${TEMPFILES_DIR}"/sysinfo
			echo >>"${TEMPFILES_DIR}"/sysinfo
		fi

		if [ -f /etc/lsb-release ]; then
			cat /etc/lsb-release >>"${TEMPFILES_DIR}"/sysinfo
			echo >>"${TEMPFILES_DIR}"/sysinfo
		fi
	fi

	if command -v glxinfo 1>/dev/null; then
		glxinfo -B &>>"${TEMPFILES_DIR}"/sysinfo
		echo >>"${TEMPFILES_DIR}"/sysinfo
	fi

	if command -v vulkaninfo 1>/dev/null; then
		vulkaninfo --summary &>>"${TEMPFILES_DIR}"/sysinfo
		echo >>"${TEMPFILES_DIR}"/sysinfo
	fi
}

## Check the launch arguments

if [ "$1" = "--clear" ]; then
	rm -rf "${XDG_CACHE_HOME}"
	rm -rf "${DOCUMENTS_DIR}"
	rm -rf "${WINEPREFIX}"
	rm -rf "${WINEPREFIX}"_old_*
	rm -rf "${TEMPFILES_DIR}"

	echo "Files have been removed!"
	exit
fi

if [ "$1" = "--shortcuts" ]; then
	if [ -f "${HOME}"/.config/user-dirs.dirs ]; then
		source "${HOME}"/.config/user-dirs.dirs
	fi

	if [ -z "${XDG_DESKTOP_DIR}" ]; then
		XDG_DESKTOP_DIR="${HOME}"/Desktop
	fi

	desktop_icon="${XDG_DESKTOP_DIR}"/"${GAME}".desktop
	menu_icon="${HOME}"/.local/share/applications/"${GAME}".desktop

	if [ -f "${desktop_icon}" ] || [ -f "${menu_icon}" ]; then
		rm -f "${desktop_icon}"
		rm -f "${menu_icon}"

		echo "Shortcuts have been removed!"
	else
		cat <<EOF > game.desktop
[Desktop Entry]
Version=1.0
Name=${GAME}
Type=Application
Terminal=false
Exec="${scriptdir}/start.sh"
Icon=${scriptdir}/game_info/icon
EOF

		mkdir -p "${XDG_DESKTOP_DIR}"
		mkdir -p "${HOME}"/.local/share/applications

		cp game.desktop "${desktop_icon}"
		cp game.desktop "${menu_icon}"
		rm -f game.desktop

		echo "Shortcuts have been added!"
	fi

	exit
fi

WINE_VERSION="$("${WINE}" --version 2>/dev/null)"

list_game_info_content

## If the USER environment variable is empty (which is unlikely),
## get the username using the id command

if [ -z "${USER}" ]; then
	USER="$(id -un)"
fi

## Create or recreate the prefix
## WINEPREFIX will be automatically (re)created in these cases:
##
## If the WINEPREFIX directory doesn't exist
## If the DOCUMENTS_DIR directory doesn't exist
## If the content of the game_info directory has changed since the last launch
## If the username has changed since the last launch
## If the Wine version has changed since the last launch
## If NTFS_MODE is enabled and the path to the script has changed since the last launch

if [ ! -d "${WINEPREFIX}" ] || [ ! -d "${DOCUMENTS_DIR}" ] \
	|| [ "${USER}" != "$(cat "${TEMPFILES_DIR}"/lastuser 2>/dev/null)" ] \
	|| [ "${WINE_VERSION}" != "$(cat "${TEMPFILES_DIR}"/lastwine 2>/dev/null)" ] \
	|| [ "${GAME_INFO_CONTENT}" != "$(cat "${TEMPFILES_DIR}"/last_game_info_files 2>/dev/null)" ] \
	|| ( [ "${NTFS_MODE}" = 1 ] && [ "${scriptdir}" != "$(cat "${TEMPFILES_DIR}"/last_scriptdir 2>/dev/null)" ] ); then

	## Disable WINEESYNC and WINEFSYNC temporarily when creating prefix

	WINEESYNC_VALUE="${WINEESYNC}"
	WINEFSYNC_VALUE="${WINEFSYNC}"
	export WINEESYNC=0
	export WINEFSYNC=0

	mkdir -p "${TEMPFILES_DIR}"

	if [ "${REMOVE_OLD_PREFIXES}" = 1 ]; then
		rm -rf "${WINEPREFIX}"
	else
		mv "${WINEPREFIX}" "${WINEPREFIX}"_old_"$(date '+%d.%m_%H:%M:%S')" 2>/dev/null
	fi

	unset disable_wine_gst
	if [ "${PREFIX_HANG_FIX}" = 1 ]; then
		disable_wine_gst="winegstreamer,"
	fi

	echo "Creating prefix"
	export WINEDEBUG="err+all,fixme+all"
	export WINEDLLOVERRIDES_ORIG="${WINEDLLOVERRIDES}"
	export WINEDLLOVERRIDES="${disable_wine_gst}mscoree,mshtml=;${WINEDLLOVERRIDES}"

	if ! "${WINE}" wineboot &>"${TEMPFILES_DIR}"/wineboot.log; then
		if [ "${NTFS_MODE}" != 1 ] && \
		   grep "$(df -P . | tail -1 | cut -d' ' -f 1)" /proc/mounts 2>/dev/null | grep -i -E 'ntfs|fat|fuseblk' &>/dev/null; then
			rm -rf "${WINEPREFIX}"
			ntfs_mode

			if ! "${WINE}" wineboot &>"${TEMPFILES_DIR}"/wineboot.log; then
				prefix_init_error
			else
				echo > "${TEMPFILES_DIR}"/force_ntfs_mode
			fi
		else
			prefix_init_error
		fi
	fi

	export WINEDEBUG="-all"
	export WINEDLLOVERRIDES="${WINEDLLOVERRIDES_ORIG}"
	"${WINESERVER}" -w

	## Create symlink to the game directory

	mkdir -p "${GAME_PATH}"
	rm -rf "${GAME_PATH}"
	ln -sr "${scriptdir}"/game_info/data "${GAME_PATH}"

	## Valve's Proton always uses steamuser as a username
	## Given this we can determine if Proton is being used instead of
	## regular Wine

	if [ -d "${WINEPREFIX}"/drive_c/users/steamuser ]; then
		USERNAME="steamuser"
	else
		USERNAME="${USER}"
	fi

	## Sandbox the prefix; Partially borrowed from the winetricks script
	## And move the user's directory outside the prefix

	rm -f "${WINEPREFIX}"/dosdevices/*
	ln -sr "${WINEPREFIX}"/drive_c "${WINEPREFIX}"/dosdevices/c:
	ln -sr "${scriptdir}" "${WINEPREFIX}"/dosdevices/k:

	"${WINE}" regedit /D "HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Desktop\\Namespace\\{9D20AAE8-0625-44B0-9CA7-71889C2254D9}" &>/dev/null
	echo disable > "${WINEPREFIX}"/.update-timestamp

	if [ ! -d "${DOCUMENTS_DIR}" ]; then
		if cd "${WINEPREFIX}"/drive_c/users/"${USERNAME}"; then
			## Use one directory (Documents_Multilocale) for all symlinks
			## This is necessary for multilocale compatibility

			mkdir -p Documents_Multilocale

			for x in *; do
				if test -h "${x}" && test -d "${x}"; then
					rm -f "${x}"
					ln -sr Documents_Multilocale "${x}"
				fi
			done
		fi
		cd "${scriptdir}"

		mv "${WINEPREFIX}"/drive_c/users/"${USERNAME}" "${DOCUMENTS_DIR}"
		mv "${WINEPREFIX}"/drive_c/users/Public "${DOCUMENTS_DIR}"/Public
		mv "${WINEPREFIX}"/drive_c/ProgramData "${DOCUMENTS_DIR}"/ProgramData
	fi

	rm -rf "${WINEPREFIX}"/drive_c/users/"${USERNAME}"
	rm -rf "${WINEPREFIX}"/drive_c/users/Public
	rm -rf "${WINEPREFIX}"/drive_c/ProgramData
	ln -sr "${DOCUMENTS_DIR}" "${WINEPREFIX}"/drive_c/users/"${USERNAME}"
	ln -sr "${DOCUMENTS_DIR}"/Public "${WINEPREFIX}"/drive_c/users/Public
	ln -sr "${DOCUMENTS_DIR}"/ProgramData "${WINEPREFIX}"/drive_c/ProgramData

	## Change My Documents directory to Documents_Multilocale via registry
	## This is mostly useful for Proton as it doesn't create symlinks
	## in the user's directory in Wine prefix, so we can't just redirect symlinks.

	"${WINE}" reg add 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' \
	/v "Personal" /t REG_EXPAND_SZ /d "%USERPROFILE%\Documents_Multilocale" /f &>/dev/null

	## Execute winetricks actions from the winetricks_list.txt file

	if [ -f game_info/winetricks_list.txt ]; then
		if download_winetricks; then
			echo "Executing winetricks"

			"${scriptdir}"/winetricks -q $(cat game_info/winetricks_list.txt) &>/dev/null
			"${WINESERVER}" -w
		else
			rm -rf "${WINEPREFIX}"
			exit 1
		fi
	fi

	## Execute files in the game_info/exe directory using Wine

	if [ -d game_info/exe ]; then
		echo "Executing files"

		for file in game_info/exe/*; do
			"${WINE}" start "${file}" &>/dev/null
			"${WINESERVER}" -w
			sleep 0.1
		done
	fi

	## Import reg files

	if [ -d game_info/regs ]; then
		echo "Importing registry files"

		for file in game_info/regs/*; do
			"${WINE}" regedit "${file}" &>/dev/null
			"${WINE64}" regedit "${file}" &>/dev/null
		done
	fi

	## Override dlls

	if [ -d game_info/dlls ]; then
		echo "Overriding dlls"

		for x in game_info/dlls/*; do
			if [ -d "${x}" ]; then
				for i in "${x}"/*; do
					dll_name="$(basename "${i}")"
					dir_name="$(basename "${x}")"
					rm -f "${WINEPREFIX}"/drive_c/windows/"${dir_name}"/"${dll_name}"
					ln -sr "${scriptdir}"/"${i}" "${WINEPREFIX}"/drive_c/windows/"${dir_name}"

					if [[ ! "${dlls_list}" == *"${dll_name}"* ]]; then
						dlls_list="${dll_name} ${dlls_list}"
					fi
				done
			else
				dll_name="$(basename "${x}")"
				rm -f "${WINEPREFIX}"/drive_c/windows/system32/"${dll_name}"
				ln -sr "${scriptdir}"/"${x}" "${WINEPREFIX}"/drive_c/windows/system32
				dlls_list="${dll_name} ${dlls_list}"
			fi
		done

		for x in ${dlls_list}; do
			"${WINE}" reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v \
			"$(basename "${x}" .dll)" /d native /f &>/dev/null

			"${WINE}" regsvr32 "${x}" &>/dev/null
			"${WINE64}" regsvr32 "${x}" &>/dev/null
		done
	fi

	## Copy the content of the additional directory

	if [ -d game_info/additional ]; then
		echo "Copying additional files"

		if [ -d game_info/additional/prefix ]; then
			cp -r game_info/additional/prefix/* "${WINEPREFIX}"
		fi

		if [ -d game_info/additional/documents ]; then
			cp -r game_info/additional/documents/* "${DOCUMENTS_DIR}"
		fi
	fi

	## Set Windows version

	if [ -n "${WINDOWS_VERSION}" ] && [ "${WINDOWS_VERSION}" != "default" ]; then
		if [ "${WINDOWS_VERSION}" = "winxp" ]; then
			"${WINE}" winecfg /v winxp &>/dev/null
			"${WINE}" winecfg /v winxp64 &>/dev/null
		else
			"${WINE}" winecfg /v "${WINDOWS_VERSION}" &>/dev/null
		fi
	fi

	## Enable debug during the first run

	export ENABLE_DEBUG=1

	## Wait for all Wine processes to terminate

	"${WINESERVER}" -w
	sleep 2

	## Save the information about the system, the username, the Wine version and
	## the list of files of the game_info directory
	## This is needed to know when to recreate the prefix

	get_system_info
	echo "${USER}" > "${TEMPFILES_DIR}"/lastuser
	echo "${WINE_VERSION}" > "${TEMPFILES_DIR}"/lastwine
	echo "${GAME_INFO_CONTENT}" > "${TEMPFILES_DIR}"/last_game_info_files
	echo "${scriptdir}" > "${TEMPFILES_DIR}"/last_scriptdir

	export WINEESYNC="${WINEESYNC_VALUE}"
	export WINEFSYNC="${WINEFSYNC_VALUE}"
fi

## Remove Z: drive in case Wine added it again

rm -f "${WINEPREFIX}"/dosdevices/z:

## Check the launch arguments

if [ "$1" = "--cfg" ]; then
	"${WINE}" winecfg
	exit
elif [ "$1" = "--reg" ]; then
	"${WINE}" regedit
	exit
elif [ "$1" = "--fm" ]; then
	"${WINE}" winefile
	exit
elif [ "$1" = "--kill" ]; then
	"${WINESERVER}" -k

	echo "All processes in the prefix have been killed!"
	exit
elif [ "$1" = "--tricks" ]; then
	if download_winetricks; then
		shift
		"${scriptdir}"/winetricks "$@"
		"${WINESERVER}" -w
	fi

	exit
elif [ "$1" = "--debug" ]; then
	export ENABLE_DEBUG=1
	shift
fi

if [ "${ENABLE_RT_DLSS}" = 1 ]; then
	if [ ! -f "${WINEPREFIX}"/drive_c/windows/system32/nvngx.dll ]; then
		nvngx_paths="/usr/lib/x86_64-linux-gnu/nvidia/current/nvidia/wine \
		             /usr/lib64/nvidia/wine \
		             /lib64/nvidia/wine \
		             /usr/lib/nvidia/wine"

		for d in ${nvngx_paths}; do
			if [ -f "${d}"/nvngx.dll ]; then
				cp "${d}"/nvngx.dll "${WINEPREFIX}"/drive_c/windows/system32
				cp "${d}"/_nvngx.dll "${WINEPREFIX}"/drive_c/windows/system32
				break
			fi
		done
	fi

	if [ -f "${WINEPREFIX}"/drive_c/windows/system32/nvngx.dll ] && \
	   ( [ -f game_info/dlls/nvapi64.dll ] || [ -f game_info/dlls/system32/nvapi64.dll ] ); then
		rm -f "${TEMPFILES_DIR}"/dlss_disabled
		export WINEDLLOVERRIDES="nvapi,nvapi64=n;${WINEDLLOVERRIDES}"
		export VKD3D_CONFIG=dxr
		export VKD3D_FEATURE_LEVEL=12_2
		export DXVK_ENABLE_NVAPI=1
		export WINE_HIDE_NVIDIA_GPU=0
	else
		echo > "${TEMPFILES_DIR}"/dlss_disabled
		export ENABLE_RT_DLSS=0
	fi
fi

if [ "${ENABLE_RT_DLSS}" = 0 ]; then
	export WINEDLLOVERRIDES="nvapi,nvapi64=;${WINEDLLOVERRIDES}"
fi

## Disable DXVK if the appropriate variable is enabled

if [ "${DISABLE_DXVK}" = 1 ]; then
	export WINEDLLOVERRIDES="dxgi,d3d8,d3d9,d3d10,d3d10_1,d3d10core,d3d11=b;${WINEDLLOVERRIDES}"
fi

## Use builtin VKD3D instead of external VKD3D-proton if the appropriate
## variable is enabled

if [ "${USE_BUILTIN_VKD3D}" = 1 ]; then
	export WINEDLLOVERRIDES="dxgi,d3d12,d3d12core=b;${WINEDLLOVERRIDES}"
fi

## Enable virtual desktop if the appropriate variable is enabled

if [ "${VIRTUAL_DESKTOP}" = 1 ]; then
	VDESKTOP="explorer /desktop=Wine,${VIRTUAL_DESKTOP_SIZE}"
fi

if [ -f "${TEMPFILES_DIR}"/enable_debug ]; then
	rm -f "${TEMPFILES_DIR}"/enable_debug
	ENABLE_DEBUG=1
fi

## Enable debug if the appropriate variable is enabled

if [ "${ENABLE_DEBUG}" = 1 ]; then
	export WINEDEBUG="err+all,fixme+all"
	unset DXVK_LOG_LEVEL
	unset VKD3D_DEBUG
	unset VKD3D_SHADER_DEBUG

	if command -v lscpu 1>/dev/null && \
	   command -v grep 1>/dev/null && \
	   command -v awk 1>/dev/null && \
	   command -v glxinfo 1>/dev/null; then
		CPU_MODEL=$(LC_ALL=C lscpu | grep "Model name:" | sed -r 's/Model name:\s{1,}//g')
		RAM_TOTAL=$(awk '/MemTotal/ { printf "%.3f \n", $2/1000/1024 }' /proc/meminfo)
		GLIBC_VERSION=$(LC_ALL=C ldd --version | awk '/ldd/{print $NF}')
		GPU_MODEL=$(LC_ALL=C glxinfo | grep Device | tail -c +13)
		LIBVULKAN1_VERSION=$((ldconfig -v | grep libvulkan | grep -s -Po '\.so\.\K([0-9]+\.)*[0-9]+' | sed '/^1./!d' ) 2>/dev/null | sed '$ d')
		KERNEL_VERSION=$(uname -mr)

		NVIDIA_DRIVER_VERSION=$(cat /sys/module/nvidia/version 2>/dev/null)
		if [ -n "${NVIDIA_DRIVER_VERSION}" ]; then
			GPU_DRIVER_VERSION="${NVIDIA_DRIVER_VERSION}"
		else
			GPU_DRIVER_VERSION=$(LC_ALL=C glxinfo -B | grep "OpenGL version string" | grep "Mesa" | sed 's/^.*Mesa/Mesa/')
		fi
	fi
fi

## Get screen resolution if the appropriate variable is enabled

if [ "${RESTORE_RESOLUTION}" = 1 ]; then
	## If there are multiple monitors connected, get resolution of primary monitor

	SCREEN_RESOLUTION="$(xrandr -q | sed -n -e 's/.* connected primary \([^ +]*\).*/\1/p')"
	SCREEN_OUTPUT="$(xrandr -q | sed -n -e 's/\([^ ]*\) connected primary.*/\1/p')"

	## If there is only one monitor, then xrandr doesn't mark it as "primary"
	## So it's necessary to handle its output slightly differently

    if [ -z "${SCREEN_RESOLUTION}" ] || [ -z "${SCREEN_OUTPUT}" ]; then
		SCREEN_RESOLUTION="$(xrandr -q | sed -n -e 's/.* connected \([^ +]*\).*/\1/p')"
		SCREEN_OUTPUT="$(xrandr -q | sed -n -e 's/\([^ ]*\) connected.*/\1/p')"
	fi
fi

## Unset SDL_AUDIODRIVER and SDL_VIDEODRIVER, because they cause issues
## for Windows games when set to a driver not available on Windows
## (alsa, pulse, x11, wayland)

unset SDL_AUDIODRIVER SDL_VIDEODRIVER

check_dxvk () {
	dlls_dirs="game_info/dlls game_info/dlls/system32 game_info/dlls/syswow64"
	dlls_names="d3d8.dll d3d9.dll d3d11.dll"

	for d in ${dlls_dirs}; do
		if [ -d "${d}" ]; then
			for i in ${dlls_names}; do
				if [ -f "${d}"/"${i}" ]; then
					return 0
				fi
			done
		fi
	done

	return 1
}

check_vkd3d () {
	dlls_dirs="game_info/dlls game_info/dlls/system32 game_info/dlls/syswow64"
	dlls_names="d3d12.dll d3d12core.dll"

	for d in ${dlls_dirs}; do
		if [ -d "${d}" ]; then
			for i in ${dlls_names}; do
				if [ -f "${d}"/"${i}" ]; then
					return 0
				fi
			done
		fi
	done

	return 1
}

## Show some info

clear
echo "========================================================================"
echo "Game: ${GAME}"
echo "Version: ${VERSION}"
echo -n "Wine: ${WINE_VERSION}"

if [ "${USE_SYSTEM_WINE}" = 1 ]; then
	echo -n " (using system Wine)"
fi
echo

if [ -n "${ARGS}" ] || [ -n "$1" ]; then
	echo "Launch arguments: $@ ${ARGS}"
fi

if check_dxvk; then
	if [ "${DISABLE_DXVK}" != 1 ]; then
		echo "DXVK: enabled"
	else
		echo "DXVK: disabled"
	fi
fi

if check_vkd3d; then
	if [ "${USE_BUILTIN_VKD3D}" != 1 ]; then
		echo "VKD3D: external (vkd3d-proton)"
	else
		echo "VKD3D: builtin"
	fi
fi

if [ "${ENABLE_RT_DLSS}" = 1 ]; then
	echo "DLSS and RT support enabled"
fi

if [ "${NTFS_MODE}" = 1 ]; then
	echo "NTFS mode is enabled"
fi

if [ -n "${DISABLE_DLLS}" ]; then
	echo "Disabled DLLs: ${DISABLE_DLLS}"
fi

if [ "${ENABLE_DEBUG}" = 1 ]; then
	echo
	echo "CPU model: ${CPU_MODEL}"
	echo "GPU model: ${GPU_MODEL}"
	echo "Videodriver version: ${GPU_DRIVER_VERSION}"
	echo "RAM amount: ${RAM_TOTAL}"
	echo "GLIBC version: ${GLIBC_VERSION}"
	echo "Vulkan-Loader version: ${LIBVULKAN1_VERSION}"
	echo "Kernel version: ${KERNEL_VERSION}"
fi

echo "========================================================================"
echo

## Launch the game

cd "${scriptdir}"/game_info/data/"${ADDITIONAL_PATH}" || exit 1

"${WINE}" ${VDESKTOP} start "${EXE}" ${ARGS} "$@"

## If the game or Wine fails, enable debug for the next launch

if [ $? -ne 0 ]; then
    echo > "${TEMPFILES_DIR}"/enable_debug
fi

"${WINESERVER}" -w

## Restore screen resolution

if [ "${RESTORE_RESOLUTION}" = 1 ]; then
	xrandr --output "${SCREEN_OUTPUT}" --mode "${SCREEN_RESOLUTION}" &>/dev/null
	xgamma -gamma 1.0 &>/dev/null
fi
