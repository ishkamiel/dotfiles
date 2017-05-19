#!/bin/bash
# Start offlineimap, but first check if its already running.
# NOTE: this won't work if another user is running offlienimap...

BIN=offlineimap

if [[ $(ps -A | awk -v x=4 '{print $x}' | grep ^${BIN}$) ]]; then
	echo "${BIN} already running"
else
	echo "starting ${BIN}"
	${BIN} -u quiet &
fi
