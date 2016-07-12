#!/bin/bash

D=$(dirname $0)

. $D/spinner.sh

LOGFILE=/dev/null

while [ -n "$1" ]; do
	case $1 in 
	-L)
		LOGFILE="$2"
		;;
	--)
		shift
		break
		;;
	esac
	shift
done

if [ -z "$1" ]  ; then exit 127; fi
start_spinner 
"$@" > ${LOGFILE} 2>&1
rv=$?
stop_spinner $rv
exit $rv
