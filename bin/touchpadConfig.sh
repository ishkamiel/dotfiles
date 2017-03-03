#!/usr/bin/env bash

# TODO: This could, instead of parsing out the ids use the string names?

LOGFILE="${LOGDIR}/touchpadConfig.log"

function log {
	echo -e $1
    	echo "$(date --rfc-3339=seconds) ${1}" >> "${LOGFILE}"
}

function die {
	log "$1"
	exit
}

function setProp {
	prop=$(echo -e """${PROPS}""" |\
	       	grep -P "$2" |\
		sed -r 's/.*\(([[:digit:]]+)\).*/\1/')

	[ -z "${prop}" ] && die "Failed to find prop num for ${1}"

	log "Configuring $1\t--> xinput --set-prop ${DEVID} ${prop} $3 $4"
	xinput --set-prop ${DEVID} ${prop} $3 $4
}


DEVID=$(xinput --list | grep TouchPad | sed -r 's/.*id=([[:digit:]]+).*/\1/')

[ -z "${DEVID}" ] && die "Failed to find TouchPad xprop id"

PROPS=$(xinput --list-props ${DEVID})

# setProp 'Tapping\t        ' 'Tapping Enabled\s+\(\d+\)' 1
setProp 'Middle Emulation' 'Middle Emulation Enabled\s+\(\d+\)' 1
setProp 'Naturl Scrolling' 'Natural Scrolling Enabled\s+\(\d+\)' 1
setProp 'Acceleration' 'Accel Speed\s+\(\d+\)' 1

