#!/usr/bin/env bash
# copyright 2017-2020 (c) by SDRausty, all rights reserved, see LICENSE
# hosting termuxarch.github.io/TermuxArch courtesy pages.github.com
# https://termuxarch.github.io/TermuxArch/CONTRIBUTORS thank you for helping
# command 'setupTermuxArch h[elp]' has information how to use this file
################################################################################
IFS=$'\n\t'
set -Eeuo pipefail
shopt -s nullglob globstar
VERSIONID=2.0.112
## INIT FUNCTIONS ##############################################################
_STRPERROR_() { # run on script error
	local RV="$?"
	printf "\\e[?25h\\n\\e[1;48;5;138m %s\\e[0m\\n" "TermuxArch WARNING:  Generated script signal ${RV:-unknown} near or at line number ${1:-unknown} by '${2:-command}'!"
	if [[ "$RV" = 4 ]]
	then
		printf "\\n\\e[1;48;5;139m %s\\e[0m\\n" "Ensure background data is not restricted.  Check the wireless connection."
	fi
	printf "\\n"
	exit 201
}

_STRPEXIT_() { # run on exit
	local RV="$?"
 	rm -rf "$TAMPDIR"
	sleep 0.04
	if [[ "$RV" = 0 ]]
	then
		printf "\\e[0;32m%s %s \\e[0m$VERSIONID\\e[1;34m: \\e[1;32m%s\\e[0m\\n\\n\\e[0m" "${0##*/}" "$ARGS" "DONE 🏁 "
		printf "\\e]2; %s: %s \\007" "${0##*/} $ARGS" "DONE 🏁 "
	else
		printf "\\e[0;32m%s %s \\e[0m$VERSIONID\\e[1;34m: \\e[1;32m%s %s\\e[0m\\n\\n\\e[0m" "${0##*/}" "$ARGS" "[Exit Signal $RV]" "DONE 🏁 "
		printf "\033]2; %s: %s %s \\007" "${0##*/} $ARGS" "[Exit Signal $RV]" "DONE 🏁 "
	fi
	printf "\\e[?25h\\e[0m"
	set +Eeuo pipefail
	exit
}

_STRPSIGNAL_() { # run on signal
	printf "\\e[?25h\\e[1;7;38;5;0mTermuxArch WARNING:  Signal $? received!\\e[0m\\n"
 	rm -rf "$TAMPDIR"
 	exit 211
}

_STRPQUIT_() { # run on quit
	printf "\\e[?25h\\e[1;7;38;5;0mTermuxArch WARNING:  Quit signal $? received!\\e[0m\\n"
 	exit 221
}

trap '_STRPERROR_ $LINENO $BASH_COMMAND $?' ERR
trap _STRPEXIT_ EXIT
trap _STRPSIGNAL_ HUP INT TERM
trap _STRPQUIT_ QUIT

_ARG2DIR_() {  # argument as ROOTDIR
	ARG2="${@:2:1}"
	if [[ -z "${ARG2:-}" ]]
	then
		ROOTDIR=/arch
		_PREPTERMUXARCH_
	else
		ROOTDIR=/"$ARG2"
		_PREPTERMUXARCH_
	fi
}

_CHK_() {
	if sha512sum -c termuxarchchecksum.sha512 1>/dev/null
	then
		printf "\\n"
		_CHKSELF_
		printf "\\e[0;34m%s \\e[1;34m%s \\e[1;32m%s\\e[0m\\n" " 🕛 > 🕜" "TermuxArch $VERSIONID integrity:" "OK"
		_COREFILESLOAD_
	else
		printf "\\n"
		_PRINTSHA512SYSCHKER_
	fi
}

_CHKDWN_() {
	if sha512sum -c setupTermuxArch.sha512 1>/dev/null
	then
		printf "\\e[0;34m%s\\e[1;34m%s\\e[1;32m%s\\n\\n" " 🕛 > 🕐 " "TermuxArch download: " "OK"
		bsdtar -xpf setupTermuxArch.tar.gz
	else
		_PRINTSHA512SYSCHKER_
	fi
}

_CHKSELF_() {	# compare file setupTermuxArc.bash and the file being used
	if [[ "$(<$TAMPDIR/setupTermuxArch.bash)" != "$(<$WFILE)" ]] # differ
	then	# change directory to where file resides
		cd "${WFILE%/*}" || printf "\\e[1;31m%s\\e[0m%s\\n" "signal received during update :" " please try using an absolute PATH or prepending your PATH to file '${0##*/}' with a tilda ~ for file '$0'."
		# find and unset functions
		unset -f $(grep \_\( "$WFILE"|cut -d"(" -f 1|sort -u|sed ':a;N;$!ba;s/\n/ /g')
		# find variables
		UNVAR="$(grep '="' "$WFILE"|grep -v -e \] -e ARGS -e TAMPDIR -e WFILE|grep -v +|sed 's/declare -a//g'|sed 's/declare//g'|sed 's/export//g'|sed -e "s/[[:space:]]\+//g"|cut -d"=" -f 1|sort -u)"
		# unset variables
		for UNSET in $UNVAR
		do
			unset "$UNSET"
		done
		# update working file
		cp "$TAMPDIR/setupTermuxArch.bash" "$WFILE"
		rm -rf "$TAMPDIR"
		printf "\\e[0;32m%s\\e[1;34m: \\e[1;32mUPDATED\\n\\e[1;32mRESTARTED\\e[1;34m: \\e[0;32m%s %s \\n\\n\\e[0m"  "${0##*/}" "${0##*/}" "$ARGS"
		# restart with published version
		. "$WFILE" "$ARGS"
	fi
	cd "$TAMPDIR"
}

_COREFILES_() {
	[[ -f archlinuxconfig.bash ]] && [[ -f espritfunctions.bash ]] && [[ -f getimagefunctions.bash ]] && [[ -f knownconfigurations.bash ]] && [[ -f maintenanceroutines.bash ]] && [[ -f necessaryfunctions.bash ]] && [[ -f printoutstatements.bash ]] && [[ -f setupTermuxArch.bash ]]
}

_COREFILESDO_() {
	if _COREFILES_
	then
		_COREFILESLOAD_
	else
		cd "$TAMPDIR"
		_DWNL_
		_CHKDWN_
		_CHK_ "$@"
	fi
}

_COREFILESLOAD_() {
	. archlinuxconfig.bash
	. espritfunctions.bash
	. getimagefunctions.bash
	. knownconfigurations.bash
	. maintenanceroutines.bash
	. necessaryfunctions.bash
	. printoutstatements.bash
	if [[ "$OPT" = MANUAL ]]
	then
		_MANUAL_
	fi
	if [[ "$OPT" = BLOOM ]]
	then
		rm -f termuxarchchecksum.sha512
	fi
}

_DEPENDDM_() { # checks and sets download manager
	for PKG in "${!ADM[@]}"
	do
		if [[ -x $(command -v "${ADM[$PKG]}") ]]
		then
 			DM="$PKG"
			printf "\\nFound download tool '%s': Continuing...\\n" "$PKG"
			break
		fi
	done
}

_DEPENDTM_() { # checks and sets tar manager: depreciated
	for PKG in "${!ATM[@]}"
	do
		if [[ -x $(command -v "${ATM[$PKG]}") ]]
		then
 			tm="$PKG"
			printf "\\nFound tar tool '%s': Continuing...\\n" "$PKG"
			break
		fi
	done
}

_DEPENDIFDM_() { # checks if download tool is set and sets install if available
 	for PKG in "${!ADM[@]}" # checks from available toolset and sets one for install if available
	do #	checks for both set DM and if tool exists on device.
 		if [[ "$DM" = "$PKG" ]] && [[ ! -x $(command -v "${ADM[$PKG]}") ]]
		then	#	sets both download tool for install and exception check.
 			APTIN+="$PKG "
			printf "\\nSetting download tool '%s' for install: Continuing...\\n" "$PKG"
 		fi
 	done
}

_DEPENDS_() {	# check for missing commands
	printf "\\e[1;34mChecking prerequisites...\\n\\e[1;32m"
	ADM=([aria2]=aria2c [axel]=axel [curl]=curl [lftp]=lftpget [wget]=wget)
	ATM=([bsdtar]=bsdtar)
	if [[ "$DM" != "" ]]
	then
		_DEPENDIFDM_
	fi
	if [[ "$DM" = "" ]]
	then
		_DEPENDDM_
	fi
	# set and install lftp if nothing else was found
	if [[ "$DM" = "" ]]
	then
		DM=lftp
		APTIN+="lftp "
		printf "Setting download tool 'lftp' for install: Continuing...\\n"
	fi
	for PKG in "${PKGS[@]}"
	do	# check for missing commands
		COMMANDP="$(command -v "$PKG")" || printf "\\e[1;38;5;124mCommand %s not found: Continuing...\\e[0m\\n" "$PKG" # test if command exists
		COMMANDPF="${COMMANDP##*/}"
		if [[ "$COMMANDPF" != "$PKG" ]]
		then
			_INPKGS_
		fi
	done
	printf "\\nUsing %s to manage downloads.\\n" "${DM:-lftp}"
	printf "\\n\\e[0;34m 🕛 > 🕧 \\e[1;34mPrerequisites: \\e[1;32mOK  \\e[1;34mDownloading TermuxArch...\\n\\n\\e[0;32m"
}

_DEPENDSBLOCK_() {
	_DEPENDS_ || printf "%s\\n" "signal received _DEPENDS_ _DEPENDSBLOCK_ ${0##*/}"
	if [[ $DIRLCR == 0 ]]
	then
		cd "${WFILE%/*}" 
		_COREFILESDO_
	else
		_COREFILESDO_
	fi
	unset LD_PRELOAD
}

_DWNL_() { # download TermuxArch from Github
	if [[ "$DFL" = "/gen" ]]
	then	# get development version from:
		FILE[sha]="https://raw.githubusercontent.com/TermuxArch/gensTermuxArch/master/setupTermuxArch.sha512"
		FILE[tar]="https://raw.githubusercontent.com/TermuxArch/gensTermuxArch/master/setupTermuxArch.tar.gz"
	else	# get stable version from:
		FILE[sha]="https://raw.githubusercontent.com/TermuxArch/TermuxArch/master/setupTermuxArch.sha512"
		FILE[tar]="https://raw.githubusercontent.com/TermuxArch/TermuxArch/master/setupTermuxArch.tar.gz"
	fi
	if [[ "$DM" = aria2 ]]
	then	# use https://github.com/aria2/aria2
		"${ADM[aria2]}" -Z "${FILE[sha]}" "${FILE[tar]}"
	elif [[ "$DM" = axel ]]
	then	# use https://github.com/mopp/Axel
		"${ADM[axel]}" -a "${FILE[sha]}"
		"${ADM[axel]}" -a "${FILE[tar]}"
	elif [[ "$DM" = curl ]]
	then	# use https://github.com/curl/curl
		"${ADM[curl]}" "$DMVERBOSE" -O {"${FILE[sha]},${FILE[tar]}"}
	elif [[ "$DM" = wget ]]
	then	# use https://github.com/mirror/wget
		"${ADM[wget]}" "$DMVERBOSE" -N --show-progress "${FILE[sha]}" "${FILE[tar]}"
	else	# use https://github.com/lavv17/lftp
		"${ADM[lftp]}" -c "${FILE[sha]}" "${FILE[tar]}"
	fi
	printf "\\n\\e[1;32m"
}

_INTRO_() {
	printf "\033]2;%s\007" "bash ${0##*/} $ARGS 📲"
	_SETROOT_EXCEPTION_
	if [[ -d "$INSTALLDIR" ]] && [[ -d "$INSTALLDIR"/root/bin ]] && [[ -d "$INSTALLDIR"/var/binds ]] && [[ -f "$INSTALLDIR"/bin/we ]] && [[ -f "$INSTALLDIR"/usr/bin/env ]]
	then
		printf "\\n\\e[0;33m%s\\e[1;33m%s\\e[0;33m.\\e[0m\\n\\n" "TermuxArch WARNING!  " "The root directory structure of ~/${INSTALLDIR##*/} is correct; Cannot continue '${0##*/} install' to install Arch Linux in Termux PRoot!  See '${0##*/} help' and '$STARTBIN help' for more information"
		exit 205
	fi
	printf "\\n\\e[0;34m 🕛 > 🕛 \\e[1;34mＴｅｒｍｕｘＡｒｃｈ %s will attempt to install Linux in \\e[0;32m%s\\e[1;34m.  Arch Linux in Termux PRoot will be available upon successful completion.  To run this BASH script again, use '!!'.  Ensure background data is not restricted.  Check the wireless connection if you do not see one o'clock 🕐 below.  \\e[0;34m" "$VERSIONID" "$INSTALLDIR"
	_DEPENDSBLOCK_ "$@"
	if [[ "$LCC" = "1" ]]
	then
		_LOADIMAGE_ "$@"
	else
		_MAINBLOCK_
	fi
}

_INTROBLOOM_() { # BLOOM = setupTermuxArch manual verbose
	OPT=BLOOM
	printf "\033]2;%s\007" "bash ${0##*/} bloom 📲"
	printf "\\n\\e[0;34m 🕛 > 🕛 \\e[1;34mＴｅｒｍｕｘＡｒｃｈ $VERSIONID bloom option.  Run \\e[1;32mbash ${0##*/} help \\e[1;34mfor additional information.  Ensure background data is not restricted.  Check the wireless connection if you do not see one o'clock 🕐 below.  "
	_PREPTERMUXARCH_
	_DEPENDSBLOCK_ "$@"
	_BLOOM_
}

_INPKGS_() {	# install missing packages
	STRNGB="\\e[1;38;5;146m%s\\e[0m\\n"
	STRNGC="\\e[1;38;5;124m%s\\e[0m\\n"
	if [[ "$COMMANDIF" = au ]] # enables rollback https://wae.github.io/au/
	then	# use 'au' to install missing packages
		au "${PKGS[@]}" || printf ""$STRNGC "$STRING2"
	elif [[ "$COMMANDIF" = pkg ]]
	then	# use 'pkg' to install missing packages
		pkg install ${PKGS[@]} && printf "$STRNGB" "$STRING1" || printf "$STRNGC" "$STRING2"
	elif [[ "$COMMANDIF" = apt ]]
	then	# use 'apt' to install missing packages
		apt install "${PKGS[@]}" --yes && printf "$STRNGC" "$STRING1" || printf "$STRNGC" "$STRING2"
	else
		printf ""$STRNGC "$STRING1" && printf "$STRNGC" "$STRING2"
	fi
}

_INTROSYSINFO_() {
	printf "\033]2;%s\007" "bash ${0##*/} sysinfo 📲"
	_SETROOT_EXCEPTION_
	printf "\\n\\e[0;34m 🕛 > 🕛 \\e[1;34mTermuxArch $VERSIONID will create a system information file.  Ensure background data is not restricted.  Run \\e[0;32mbash ${0##*/} help \\e[1;34mfor additional information.  Check the wireless connection if you do not see one o'clock 🕐 below.  "
	_DEPENDSBLOCK_ "$@"
	_SYSINFO_ "$@"
}

_INTROREFRESH_() {
	printf '\033]2;  bash setupTermuxArch refresh 📲 \007'
	_SETROOT_EXCEPTION_
	if [[ ! -d "$INSTALLDIR" ]] || [[ ! -d "$INSTALLDIR"/root/bin ]] || [[ ! -d "$INSTALLDIR"/var/binds ]] || [[ ! -f "$INSTALLDIR"/bin/we ]] || [[ ! -f "$INSTALLDIR"/usr/bin/env ]]
	then
		printf "\\n\\e[0;33m%s\\e[1;33m%s\\e[0;33m.\\e[0m\\n\\n" "ＴｅｒｍｕｘＡｒｃｈ WARNING!  " "The root directory structure is incorrect; Cannot continue ${0##*/} refresh!  See '${0##*/} help' and '$STARTBIN help' for more information"
		if [[ -d "$INSTALLDIR"/tmp ]]
		then	# check for superfluous tmp directory
			DIRCHECK=0
			DIRNAME=(dev etc home opt proc root sys usr var)
			for IDIRNAME in ${DIRNAME[@]}
			do
				if [[ ! -d "$INSTALLDIR/$IDIRNAME" ]]
				then
					DIRCHECK=1
				fi
			done
		fi
		if [[ "$DIRCHECK" -eq 1 ]]
		then	# delete superfluous tmp dir
			rm -rf "$INSTALLDIR"/tmp
			rm -rf "$INSTALLDIR"
		fi
		exit 204
	fi
	printf "\\n\\e[0;34m 🕛 > 🕛 \\e[1;34mＴｅｒｍｕｘＡｒｃｈ $VERSIONID will refresh your TermuxArch files in \\e[0;32m~/${INSTALLDIR##*/}\\e[1;34m.  Ensure background data is not restricted.  Run \\e[0;32mbash ${0##*/} help \\e[1;34mfor additional information.  Check the wireless connection if you do not see one o'clock 🕐 below.  "
	_DEPENDSBLOCK_ "$@"
	_REFRESHSYS_ "$@"
}

_LOADCONF_() {
	if [[ -f "${WDIR}setupTermuxArchConfigs.bash" ]]
	then
		. "${WDIR}setupTermuxArchConfigs.bash"
		_PRINTCONFLOADED_
	else
		. knownconfigurations.bash
	fi
}

_MANUAL_() {
	printf '\033]2; bash setupTermuxArch manual 📲 \007'
	_EDITORS_
	if [[ -f "${WDIR}setupTermuxArchConfigs.bash" ]]
	then
		"$ed" "${WDIR}setupTermuxArchConfigs.bash"
		_LOADCONF_
	else
		cp knownconfigurations.bash "${WDIR}setupTermuxArchConfigs.bash"
 		sed -i "7s/.*/\# The architecture of this device is $CPUABI; Adjust configurations in the appropriate section.  Change CMIRROR (https:\/\/wiki.archlinux.org\/index.php\/Mirrors and https:\/\/archlinuxarm.org\/about\/mirrors) to desired geographic location to resolve 404 and checksum issues.  /" "${WDIR}setupTermuxArchConfigs.bash"
		"$ed" "${WDIR}setupTermuxArchConfigs.bash"
		. "${WDIR}setupTermuxArchConfigs.bash"
		_PRINTCONFLOADED_
	fi
}

_NAMEINSTALLDIR_() {
	if [[ "$ROOTDIR" = "" ]]
	then
		ROOTDIR=arch
	fi
	INSTALLDIR="$(printf "%s\\n" "$HOME/${ROOTDIR%/}"|sed 's#//*#/#g')"
}

_NAMESTARTARCH_() {
 	DARCH="$(printf "%s\\n" "${ROOTDIR%/}"|sed 's#//*#/#g')" # ${@%/} removes trailing slash
	if [[ "$DARCH" = "/arch" ]]
	then
		AARCH=""
		STARTBI2=arch
	else
 		AARCH="$(printf "%s\\n" "$DARCH"|sed 's/\//\+/g')"
		STARTBI2=arch
	fi
	declare -g STARTBIN=start"$STARTBI2$AARCH"
}

_OPT1_() {
	if [[ -z "${2:-}" ]]
	then
		_ARG2DIR_ "$@"
	elif [[ "$2" = [Bb]* ]]
	then
		printf "%s\\n" "Setting mode to bloom."
		_INTROBLOOM_ "$@"
	elif [[ "$2" = [Dd]* ]] || [[ "$2" = [Ss]* ]]
	then
		printf "%s\\n" "Setting mode to sysinfo."
		shift
		_ARG2DIR_ "$@"
		_INTROSYSINFO_ "$@"
	elif [[ "$2" = [Ii]* ]]
	then
		printf "%s\\n" "Setting mode to install."
		shift
		_ARG2DIR_ "$@"
	elif [[ "$2" = [Mm]* ]]
	then
		printf "%s\\n" "Setting mode to manual."
		OPT=MANUAL
 		_OPT2_ "$@"
	elif [[ "$2" = [Rr][Ee][Ff]* ]]
	then
		printf "\\n%s\\n" "Setting mode to refresh."
		shift
		_ARG2DIR_ "$@"
		_INTROREFRESH_ "$@"
	elif [[ "$2" = [Rr][Ee]* ]]
	then
		export LCR="2"
		printf "\\n%s\\n" "Setting mode to minimal refresh and refresh user directories."
		shift
		_ARG2DIR_ "$@"
		_INTROREFRESH_ "$@"
	elif [[ "$2" = [Rr]* ]]
	then
		export LCR="1"
		printf "\\n\\e[1;32m%s\\e[1;34m: \\e[0;32m%s '%s' %s\\n\\e[0m" "Setting mode" "minimal refresh;  Use" "${0##*/} re[fresh]" "for full refresh."
		shift
		_ARG2DIR_ "$@"
		_INTROREFRESH_ "$@"
	else
		_ARG2DIR_ "$@"
	fi
}

_OPT2_() {
	if [[ -z "${3:-}" ]]
	then
		shift
		_ARG2DIR_ "$@"
		_INTRO_ "$@"
	elif [[ "$3" = [Ii]* ]]
	then
		printf "%s\\n" "Setting mode to install."
		shift 2
		_ARG2DIR_ "$@"
		_INTRO_ "$@"
	elif [[ "$3" = [Rr][Ee][Ff]* ]]
	then
		printf "\\n%s\\n" "Setting mode to refresh."
		_ARG2DIR_ "$@"
		_INTROREFRESH_ "$@"
	elif [[ "$3" = [Rr][Ee]* ]]
	then
		export LCR="2"
		printf "\\n%s\\n" "Setting mode to minimal refresh and refresh user directories."
		shift 2
		_ARG2DIR_ "$@"
		_INTROREFRESH_ "$@"
	elif [[ "$3" = [Rr]* ]]
	then
		export LCR="1"
		printf "\\n\\e[1;32m%s\\e[1;34m: \\e[0;32m%s '%s' %s\\n\\e[0m" "Setting mode" "minimal refresh;  Use" "${0##*/} re[fresh]" "for full refresh."
		shift 2
		_ARG2DIR_ "$@"
		_INTROREFRESH_ "$@"
	else
		shift
		_ARG2DIR_ "$@"
		_INTRO_ "$@"
	fi
}

_PREPTMPDIR_() {
	[[ ! -d "$INSTALLDIR/tmp" ]] && mkdir -p "$INSTALLDIR/tmp" && chmod 777 "$INSTALLDIR/tmp" && chmod +t "$INSTALLDIR/tmp"
 	TAMPDIR="$INSTALLDIR/tmp/setupTermuxArch$$"
	[[ ! -d "$TAMPDIR" ]] && mkdir -p "$TAMPDIR"
}

_PREPTERMUXARCH_() {
	_NAMEINSTALLDIR_
	_NAMESTARTARCH_
	_PREPTMPDIR_ || printf "%s\\n" "signal received _PREPTMPDIR_ _PREPTERMUXARCH_ ${0##*/}"
}

_PRINTCONFLOADED_() {
	printf "\\n\\e[0;34m%s \\e[1;34m%s \\e[0;32m%s\\e[1;32m%s \\e[1;34m%s \\e[1;32m%s\\n" " 🕛 > 🕑" "TermuxArch configuration" "$WDIR" "setupTermuxArchConfigs.bash" "loaded:" "OK"
}

_PRINTSHA512SYSCHKER_() {
	printf "\\n\\e[07;1m\\e[31;1m\\n%s \\e[34;1m\\e[30;1m%s \\n\\e[0;0m\\n" " 🔆 WARNING sha512sum mismatch!  Setup initialization mismatch!" "  Try again, initialization was not successful this time.  Wait a little while.  Then run 'bash ${0##*/}' again..."
	printf '\033]2; Run bash %s again...\007' "${0##*/} $ARGS"
	exit
}

_PRINTSTARTBIN_USAGE_() {
	printf "\\e[1;38;5;155m"
 	_NAMESTARTARCH_
	if [[ -x "$(command -v "$STARTBIN")" ]]
	then
		printf "\\n%s\\n" "$STARTBIN help"
		"$STARTBIN" help
	fi
}

_PRINTUSAGE_() {
	printf "\\n\\e[1;32m  %s     \\e[0;32mcommand \\e[1;32m%s \\e[0;32m%s\\n" "HELP" "'${0##*/} help'" "prints out this help screen"
	printf "\\n\\e[1;32m  %s    \\e[0;32mcommand \\e[1;32m%s \\e[0;32m%s\\n" "TERSE" "'${0##*/} he[lp]'" "prints out the terse help screen"
	printf "\\n\\e[1;32m  %s  \\e[0;32mcommand \\e[1;32m%s \\e[0;32m%s\\n" "VERBOSE" "'${0##*/} h'" "prints out both terse and verbose help screens"
	printf "\\n\\e[0;32m%s \\e[1;32m%s \\e[0;32m%s \\e[1;32m%s \\e[0;32m%s \\e[1;32m%s \\e[0;32m%s \\e[1;32m%s \\e[0;32m%s \\n\\n%s \\e[1;32m%s\\e[0;32m%s \\e[1;32m%s \\e[0;32m%s \\e[1;32m%s \\e[0;32m%s \\e[1;32m%s\\e[0;32m%s\\n" "Usage information for" "${0##*/}" "$VERSIONID.  Arguments can abbreviated to one, two and three letters each;  Two and three letter arguments are acceptable.  For example" "'bash ${0##*/} cs'" "will use" "curl" "to download TermuxArch and produce a file like" "setupTermuxArchSysInfo$STIME.log" "populated with system information.  If you have a new smartphone that you are not familiar with, this file might make for an interesting read in order to find out more about the device you might be holding in the palm of your hand at this moment." "User configurable variables are in" "setupTermuxArchConfigs.bash" ".  To create this file from" "kownconfigurations.bash" "in the working directory, execute" "'bash ${0##*/} manual'" "to create and edit" "setupTermuxArchConfigs.bash" "."
	printf "\\n\\e[1;32m  %s\\e[0;32m  %s \\e[1;32m%s \\e[0;32m%s \\e[1;32m%s \\e[0;32m%s \\e[1;32m%s \\e[0;32m%s \\e[1;32m%s \\e[0;32m%s \\e[1;32m%s \\e[0;32m%s \\e[1;32m%s \\e[0;32m%s \\e[1;32m%s\\e[0;32m%s \\e[1;32m%s \\e[0;32m%s \\e[1;32m%s \\e[0;32m%s\\n" "INSTALL" "You can run" "./${0##*/}" "without arguments in a bash shell to install Arch Linux in Termux PRoot in a smartphone, table and smartTV.  Command" "'bash ${0##*/} curl'" "will envoke" "curl" "as the download manager.  Copy" "knownconfigurations.bash" "to" "setupTermuxArchConfigs.bash" "with the command" "'bash ${0##*/} manual'" "to edit preferred CMIRROR site, refine the init statement and to access more options.  Change CMIRROR to desired geographic location to resolve download, 404 and checksum issues should these occur.  After editing" "setupTermuxArchConfigs.bash" ", you can run" "'bash ${0##*/}'" "and" "setupTermuxArchConfigs.bash" "loads automatically from the working directory.  User configurable variables are present in this file for your convenience." "  This link https://github.com/SDRausty/TermuxArch/issues/212 at GitHub has the most current information about setting Arch Linux in Termux PRoot as the default login shell in Termux in your smartphone, tablet, smartTV, wearable and more.  If you choose to or are simply curious about setting Arch Linux in Termux PRoot as the default login shell, please be thoroughly familiar with safe mode; Long tap on NEW SESSION will open a new session in safe mode.  You can use safe mode to reset the default shell."
 	printf "\\n\\e[1;32m  %s    \\e[0;32mcommand \\e[1;32m%s \\e[0;32m%s\\n" "PURGE" "'${0##*/} purge'" "uninstalls Arch Linux from Termux."
	printf "\\n\\e[1;32m  %s  \\e[0;32mcommand \\e[1;32m%s \\e[0;32m%s \\e[1;32m%s \\e[0;32m%s \\e[1;32m%s\\n\\n\\e[0;32m%s\\e[1;32m%s\\e[0;32m%s\\n\\n" "SYSINFO" "'${0##*/} sysinfo'" "creates a system information file; A file like" "setupTermuxArchSysInfo$STIME.log" "will be populated with device and system information.  Please post information from this file along with details at" "https://github.com/TermuxArch/TermuxArch/issues." "  If screenshots will help in resolving an issue better, include these with information from this system information log file in a post as well.  If you are sharing an issue, please consider sharing a pull request at " "https://github.com/TermuxArch/TermuxArch/pulls" " too.  Sharing a pull request can give a better perspective of how an issue can be improved."
	if [[ "$LCC" = 1 ]]
	then
		printf "\\e[0;32m  Command \\e[1;32m%s\\e[0;32m has %s usage information:\\n\\n" "'$STARTBIN help'" "$STARTBIN"
		_PRINTSTARTBIN_USAGE_
		printf "\\e[1;38;5;150m%s\\n\\n" "$(sed -n '600,900p;900p' "$0"|grep "^##"|sed 's/## /\n  /g')"
	else
		printf "\\e[0;32m  command \\e[1;32m%s\\e[0;32m has %s usage information\\n\\n" "'$STARTBIN help'" "$STARTBIN"

	fi
#	
}

_RMARCH_() {
	_NAMESTARTARCH_
	_NAMEINSTALLDIR_
	while true; do
		printf "\\n\\e[1;30m"
		read -n 1 -p "Uninstall $INSTALLDIR? [Y|n] " RUANSWER
		if [[ "$RUANSWER" = [Ee]* ]] || [[ "$RUANSWER" = [Nn]* ]] || [[ "$RUANSWER" = [Qq]* ]]
		then
			break
		elif [[ "$RUANSWER" = [Yy]* ]] || [[ "$RUANSWER" = "" ]]
		then
			printf "\\e[30mUninstalling $INSTALLDIR...\\n"
			if [[ -e "$PREFIX/bin/$STARTBIN" ]]
			then
				rm -f "$PREFIX/bin/$STARTBIN"
			else
				printf "Uninstalling $PREFIX/bin/$STARTBIN: nothing to do for $PREFIX/bin/$STARTBIN.\\n"
			fi
			if [[ -e "$HOME/bin/$STARTBIN" ]]
			then
				rm -f "$HOME/bin/$STARTBIN"
			else
				printf "Uninstalling $HOME/bin/$STARTBIN: nothing to do for $HOME/bin/$STARTBIN.\\n"
			fi
			if [[ -d "$INSTALLDIR" ]]
			then
				_RMARCHRM_
			else
				printf "Uninstalling $INSTALLDIR: nothing to do for $INSTALLDIR.\\n"
			fi
			printf "Uninstalling $INSTALLDIR: \\e[1;32mDone\\n\\e[30m"
			break
		else
			printf "\\nYou answered \\e[33;1m$RUANSWER\\e[30m.\\n\\nAnswer \\e[32mYes\\e[30m or \\e[1;31mNo\\e[30m. [\\e[32my\\e[30m|\\e[1;31mn\\e[30m]\\n"
		fi
	done
	printf "\\e[0m\\n"
}

_RMARCHRM_() {
	_SETROOT_EXCEPTION_
	rm -rf "${INSTALLDIR:?}"/* 2>/dev/null ||:
	find  "$INSTALLDIR" -type d -exec chmod 700 {} \; 2>/dev/null ||:
	rm -rf "$INSTALLDIR" 2>/dev/null ||:
}

_RMARCHQ_() {
	if [[ -d "$INSTALLDIR" ]]
	then
		printf "\\n\\e[0;33m %s \\e[1;33m%s \\e[0;33m%s\\n\\n\\e[1;30m%s\\n" "TermuxArch:" "DIRECTORY WARNING!  $INSTALLDIR/" "directory detected." "Purge $INSTALLDIR as requested?"
		_RMARCH_
	fi
}

_SETROOT_EXCEPTION_() {
	if [[ "$INSTALLDIR" = "$HOME" ]] || [[ "$INSTALLDIR" = "$HOME"/ ]] || [[ "$INSTALLDIR" = "$HOME"/.. ]] || [[ "$INSTALLDIR" = "$HOME"/../ ]] || [[ "$INSTALLDIR" = "$HOME"/../.. ]] || [[ "$INSTALLDIR" = "$HOME"/../../ ]]
	then
		printf  '\033]2;%s\007' "Rootdir exception.  Run bash ${0##*/} $ARGS again with different options..."
		printf "\\n\\e[1;31m%s\\n\\n\\e[0m" "Rootdir exception.  Run the script $ARGS again with different options..."
		exit
	fi
}

## User Information:  Configurable variables such as mirrors and download manager options are in 'setupTermuxArchConfigs.bash'.  Working with 'kownconfigurations.bash' in the working directory is simple.  'bash setupTermuxArch manual' will create 'setupTermuxArchConfigs.bash' in the working directory for editing; See 'setupTermuxArch help' for more information.
declare -A ADM		## Declare associative array for all available download tools.
declare -A ATM		## Declare associative array for all available tar tools.
declare -a ARGS="$@"	## Declare arguments as string.
declare APTIN=""	## apt install string
declare COMMANDIF=""
declare COMMANDR
declare COMMANDG=""
declare STRING1
declare STRING2
declare CPUABI=""
declare CPUABI5="armeabi"	## Used for development;  The command 'getprop ro.product.cpu.abi' can be used to ascertain the device architecture.  Matching an alternate CPUABI* will install an alternate architecture on device.  The original device architecture must be changed to something else so it does not match.  This is usefull with QEMU to install and run alternate architectures on device.
declare CPUABI7="armeabi-v7a"	## Used for development.
declare CPUABI8="arm64-v8a"	## Used for development.
declare CPUABIX86="x86"		## Used for development.
declare CPUABIX86_64="x86_64"	## Used for development.
declare DFL=""		## Used for development.
declare DMVERBOSE="-q"	## -v for verbose download manager output from curl and wget;  for verbose output throughout runtime also change in 'setupTermuxArchConfigs.bash' when using 'setupTermuxArch.bash m[anual]'.
declare ed=""
declare DIRLCR=""
declare DM=""
declare FSTND=""
declare -A FILE
declare INSTALLDIR=""
declare LCC=""
declare LCP=""
declare OPT=""
declare ROOTDIR=""
declare WDIR=""
declare WFILE=""
declare STI=""		## Generates pseudo random number.
declare STIME=""	## Generates pseudo random number.
if [[ -z "${TAMPDIR:-}" ]]
then
	TAMPDIR=""
fi
ROOTDIR=/arch
STRING1="COMMAND 'au' enables auto upgrade and rollback.  Available at https://wae.github.io/au/ IS NOT FOUND: Continuing... "
STRING2="Cannot update '${0##*/}' prerequisite: Continuing..."
## TERMUXARCH FEATURES INCLUDE:
## 1) Create aliases and commands that aid in using the command line, and assist in accessing the more advanced features like the command 'yay' easily;  The files '.bashrc' '.bash_profile' and 'bin/README.md' have detailed information about this feature,
## 2) Set timezone and locales from device,
## 3) Test for correct OS,
COMMANDG="$(command -v getprop)" ||:
if [[ "$COMMANDG" = "" ]]
then
	printf "\\n\\e[1;48;5;138m %s\\e[0m\\n\\n" "TermuxArch WARNING: Run 'bash ${0##*/}' and './${0##*/}' from the BASH shell in in Termux: exiting..."
	exit
fi
COMMANDR="$(command -v au)" || COMMANDR="$(command -v pkg)" || COMMANDR="$(command -v apt)"
COMMANDIF="${COMMANDR##*/}"
## 4) Generate pseudo random number to create uniq strings,
if [[ -r  /proc/sys/kernel/random/uuid ]]
then
	STIME="$(cat /proc/sys/kernel/random/uuid)"
	STIME="${STIME//-}"
	STIME="${STIME:0:3}"
else
	STIME="$(date +%s)"
	STIME="$(printf "%s" "${STIME:7:4}"|rev)"
fi
ONESA="$(date +%s)"
ONESA="${ONESA: -1}"
PKGS=(bsdtar proot)
STIME="$ONESA$STIME"
## 5) Get device information via the 'getprop' command,
CPUABI="$(getprop ro.product.cpu.abi)"
SYSVER="$(getprop ro.build.version.release)"
NASVER="$(getprop net.bt.name ) $SYSVER"
WDIR="$PWD/"
WFILE="$0"
[[ "${WFILE%/*}" != "$WDIR" ]] && [[ "${WFILE%/*}" != "${0##*/}" ]] && DIRLCR=0
[ ! -d ${WFILE%/*} ]&&WFILE="$PWD/$WFILE" 
## 6) Create a default user account with the 'addauser' command that configures this account for use with the 'sudo' command,
## 7) And all options are optional for install.
## THESE OPTIONS ARE AVAILABLE FOR YOUR CONVENIENCE:
## GRAMMAR[a]: setupTermuxArch.bash [HOW] [DO] [WHERE]
## OPTIONS[a]: setupTermuxArch.bash [HOW] [DO] [WHERE]
## GRAMMAR[b]: setupTermuxArch.bash [WHAT] [WHERE]
## OPTIONS[b]: setupTermuxArch.bash [~/|./|/absolute/path/]image.tar.gz [WHERE]
## DEFAULTS ARE IMPLIED AND CAN BE OMITTED
## SYNTAX[1]: [HOW (aria2|axel|curl|lftp|wget (default1: present on system (default2: lftp)))]
## SYNTAX[2]: [DO (help|install|manual|purge|refresh|sysinfo (default: install))]
## SYNTAX[3]: [WHERE (default: arch)]  Install in userspace, not external storage.
## USAGE[1]: 'setupTermuxArch.bash wget sysinfo' will use wget as the download manager and produce a system information file in the working directory.  This can be abbreviated to 'setupTermuxArch.bash ws' and 'setupTermuxArch.bash w s'.
## USAGE[2]: 'setupTermuxArch.bash wget manual customdir' will install the installation in customdir with wget and use manual mode during instalation.
## USAGE[3]: 'setupTermuxArch.bash wget refresh customdir' will refresh this installation using wget as the download manager.
## >>>>>>>>>>>>>>>>>>
## >> OPTION  HELP >>
## >>>>>>>>>>>>>>>>>>
## []  Run default Arch Linux install.
if [[ -z "${1:-}" ]]
then
	_PREPTERMUXARCH_
	_INTRO_ "$@"
## [./path/systemimage.tar.gz [customdir]]  Install directory argument is optional.  Network install can be substituted by copying systemimage.tar.gz and systemimage.tar.gz.md5 files with 'setupTermuxArch.bash ./[path/]systemimage.tar.gz' and 'setupTermuxArch.bash /absolutepath/systemimage.tar.gz'.
elif [[ "${ARGS:0:1}" = . ]]
then
 	printf "\\n%s\\n" "Setting mode to copy system image."
 	GFILE="$1"
 	LCC="1"
 	LCP="1"
 	_ARG2DIR_ "$@"
 	_INTRO_ "$@"
## [systemimage.tar.gz [customdir]]  Install directory argument is optional.  Network install can be substituted by copying systemimage.tar.gz and systemimage.tar.gz.md5 files with 'setupTermuxArch.bash systemimage.tar.gz'.
elif [[ "$ARGS" = *.tar.gz* ]]
then
 	printf "\\n%s\\n" "Setting mode to copy system image."
 	GFILE="$1"
	LCC="1"
	LCP="0"
	_ARG2DIR_ "$@"
	_INTRO_ "$@"
## [axd|axs]  Get device system information with 'axel'.
elif [[ "${1//-}" = [Aa][Xx][Dd]* ]] || [[ "${1//-}" = [Aa][Xx][Ss]* ]]
then
	printf "\\nGetting device system information with 'axel'.\\n"
	DM=axel
	shift
	_ARG2DIR_ "$@"
	_INTROSYSINFO_ "$@"
## [ax[el] [customdir]|axi [customdir]]  Install Arch Linux with 'axel'.
elif [[ "${1//-}" = [Aa][Xx]* ]] || [[ "${1//-}" = [Aa][Xx][Ii]* ]]
then
	printf "\\nSetting 'axel' as download manager.\\n"
	DM=axel
	_OPT1_ "$@"
	_INTRO_ "$@"
## [ad|as]  Get device system information with 'aria2c'.
elif [[ "${1//-}" = [Aa][Dd]* ]] || [[ "${1//-}" = [Aa][Ss]* ]]
then
	printf "\\nGetting device system information with 'aria2c'.\\n"
	DM=aria2
	shift
	_ARG2DIR_ "$@"
	_INTROSYSINFO_ "$@"
## [a[ria2c] [customdir]|ai [customdir]]  Install Arch Linux with 'aria2c'.
elif [[ "${1//-}" = [Aa]* ]]
then
	printf "\\nSetting 'aria2c' as download manager.\\n"
	DM=aria2
	_OPT1_ "$@"
	_INTRO_ "$@"
## [b[loom]]  Create and run a local copy of TermuxArch in TermuxArchBloom.  Useful for running a customized setupTermuxArch.bash locally, for developing and hacking TermuxArch.
elif [[ "${1//-}" = [Bb]* ]]
then
	printf "\\nSetting mode to bloom. \\n"
	_INTROBLOOM_ "$@"
## [cd|cs]  Get device system information with 'curl'.
elif [[ "${1//-}" = [Cc][Dd]* ]] || [[ "${1//-}" = [Cc][Ss]* ]]
then
	printf "\\nGetting device system information with 'curl'.\\n"
	DM=curl
	shift
	_ARG2DIR_ "$@"
	_INTROSYSINFO_ "$@"
## [c[url] [customdir]|ci [customdir]]  Install Arch Linux with 'curl'.
elif [[ "${1//-}" = [Cc][Ii]* ]] || [[ "${1//-}" = [Cc]* ]]
then
	printf "\\nSetting 'curl' as download manager.\\n"
	DM=curl
	_OPT1_ "$@"
	_INTRO_ "$@"
## [d[ebug]|s[ysinfo]]  Generate system information.
elif [[ "${1//-}" = [Dd]* ]] || [[ "${1//-}" = [Ss]* ]]
then
	printf "\\nSetting mode to sysinfo.\\n"
	shift
	_ARG2DIR_ "$@"
	_INTROSYSINFO_ "$@"
## [he[lp]|?]  Display terse builtin help.
elif [[ "${1//-}" = [Hh][Ee]* ]] || [[ "${1//-}" = [?]* ]]
then
	_ARG2DIR_ "$@"
	_PRINTUSAGE_ "$@"
## [h]  Display verbose builtin help.
elif [[ "${1//-}" = [Hh]* ]]
then
	LCC="1"
	_ARG2DIR_ "$@"
	_PRINTUSAGE_ "$@"
## [i[nstall] [customdir]]  Install Arch Linux in a custom directory.  Instructions: Install in userspace.  The HOME directory is appended to the installation directory.  To install Arch Linux in HOME/customdir use 'bash setupTermuxArch.bash install customdir'.  In the BASH shell you can use './setupTermuxArch.bash install customdir'.  All options can be abbreviated to one, two and three letters.  Hence './setupTermuxArch.bash install customdir' can be run as './setupTermuxArch.bash i customdir' in BASH.
elif [[ "${1//-}" = [Ii]* ]]
then
	printf "\\nSetting mode to install.\\n"
	_OPT1_ "$@"
	_INTRO_ "$@"
## [ld|ls]  Get device system information with 'lftp'.
elif [[ "${1//-}" = [Ll][Dd]* ]] || [[ "${1//-}" = [Ll][Ss]* ]]
then
	printf "\\nGetting device system information with 'lftp'.\\n"
	DM=lftp
	shift
	_ARG2DIR_ "$@"
	_INTROSYSINFO_ "$@"
## [l[ftp] [customdir]]  Install Arch Linux with 'lftp'.
elif [[ "${1//-}" = [Ll]* ]]
then
	printf "\\nSetting 'lftp' as download manager.\\n"
	DM=lftp
	_OPT1_ "$@"
	_INTRO_ "$@"
## [m[anual]]  Manual Arch Linux install, useful for resolving download issues.
elif [[ "${1//-}" = [Mm]* ]]
then
	printf "\\nSetting mode to manual.\\n"
	OPT=MANUAL
	_OPT1_ "$@"
	_INTRO_ "$@"
## [o[ption]]  Option under development.
elif [[ "${1//-}" = [Oo]* ]]
then
	printf "\\nSetting mode to option.\\n"
	LCC="1"
	_PRINTUSAGE_ "$@"
## [p[urge] [customdir]]  Remove Arch Linux.
elif [[ "${1//-}" = [Pp]* ]]
then
	printf "\\nSetting mode to purge.\\n"
	_ARG2DIR_ "$@"
	_RMARCHQ_
## [ref[resh] [customdir]]  Refresh the Arch Linux in Termux PRoot scripts created by TermuxArch and the installation itself.  Useful for refreshing the installation, the root user's home directory, user home directories and the TermuxArch generated scripts to their newest version and also runs keys and generates locales.
elif [[ "${1//-}" = [Rr][Ee][Ff]* ]]
then
	printf "\\nSetting mode to full refresh.\\n"
	_ARG2DIR_ "$@"
	_INTROREFRESH_ "$@"
## [re [customdir]]  Refresh the Arch Linux in Termux PRoot scripts created by TermuxArch.  Useful for refreshing the root user's home directory and user home directories and the TermuxArch generated scripts to their newest version.
elif [[ "${1//-}" = [Rr][Ee] ]]
then
	export LCR="2"
	printf "\\n\\e[0;32mSetting mode\\e[1;34m : \\e[1;32mminimal refresh with refresh user directories\\e[1;34m :\\e[0;32m For a full refresh you can use the%s \\e[1;32mbash '%s' \\e[0;32m%s\\e[1;34m...\\n\\e[0m" "" "${0##*/} ref[resh]" "command"
	_ARG2DIR_ "$@"
	_INTROREFRESH_ "$@"
## [r [customdir]]  Refresh the Arch Linux in Termux PRoot scripts created by TermuxArch.  Useful for refreshing the root user's home directory and the TermuxArch generated scripts to their newest version.
elif [[ "${1//-}" = [Rr] ]]
then
	export LCR="1"
	printf "\\n\\e[0;32mSetting mode\\e[1;34m : \\e[1;32mminimal refresh\\e[1;34m :\\e[0;32m For a full refresh you can use the%s \\e[1;32mbash '%s' \\e[0;32m%s\\e[1;34m...\\n\\e[0m" "" "${0##*/} ref[resh]" "command"
	_ARG2DIR_ "$@"
	_INTROREFRESH_ "$@"
## [wd|ws]  Get device system information with 'wget'.
elif [[ "${1//-}" = [Ww][Dd]* ]] || [[ "${1//-}" = [Ww][Ss]* ]]
then
	printf "\\nGetting device system information with 'wget'.\\n"
	DM=wget
	shift
	_ARG2DIR_ "$@"
	_INTROSYSINFO_ "$@"
## [w[get] [customdir]]  Install Arch Linux with 'wget'.
elif [[ "${1//-}" = [Ww]* ]]
then
	printf "\\nSetting 'wget' as download manager.\\n"
	DM=wget
	_OPT1_ "$@"
	_INTRO_ "$@"
else
	_PRINTUSAGE_
fi
## File 'uprTermuxArch.bash' will execute 'git pull' and populate git repository modules, and file 'uprTermuxArch.bash' can be run directly in a PRoot environment.  File uprTermuxArch.bash's functions are not related to updating functions run by command 'setupTermuxArch r[e[fresh]]' that have completely different update functions.  The command 'setupTermuxArch r[e[fresh]]' attempts to refresh the Arch Linux in Termux PRoot installation and the TermuxArch generated scripts to the newest version.  It also helps in the installation and configuration process if everything did not go smoothly on the first try to install Arch Linux in Termux PRoot.
## Files 'setupTermuxArch{.bash,.sh}' are held for backward compatibility;  Please reference file 'setupTermuxArch' as the chosen install file if aid and assistance be through sharing insight about this Arch Linux in a Termux PRoot container project which can be used on a smartphone, smartTV, tablet, wearable and more.  File 'setupTermuxArch' is earmarked as the install file name for this project.
## File 'setupTermuxArch' downloads as files 'setupTermuxArch.[bin,\ \(1\),\ \(2\),etc...]' through Internet browsers into Android Downloads on smartphone and Arch Linux in Termux PRoot can be installed directly from this file in Android with this command 'bash ~/storage/downloads/setupTermuxArch.bin' and similar which may also check whether there is a newer version automatically since the time it was downloaded.  If there is a newer version, this file might self update.  If this updating process went smoothly, this file will restart the process that was initially initiated by the user.
## These files 'setupTermuxArch[.{bash,sh}]' will NOT selfupdate to the most recent version published if they are used inside their git repository;  In this case 'git pull' or 'uprTermuxArch.bash' can be employed to update to the newest published version.
## Very many hardy thank yous to contributors who are helping and have already helped to make this open source resource better!  Please accept a wholehearted thank you for using this product!
# The name of file 'setupTermuxArch' in the EOF line at the end of this file is to assist scripts 'setupTermuxArch[.{bash,bin,sh}]' when they selfupdate to the latest version when the user runs them.
# setupTermuxArch EOF
	printf '\033]2; Run bash %s again...\007' "${0##*/} $ARGS"
