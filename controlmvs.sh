#!/bin/bash

HERCENV=/home/dan/sdl/herc4x/hyperion-init-bash.sh
SCREEN=/usr/bin/screen
HERCDIR=/home/dan/mvsce/sysgen/MVSCE
HERCSTART=/home/dan/mvsce/sysgen/MVSCE/start_mvs.sh
SHUTDOWN_JCL=/home/dan/mvsce/sysgen/MVSCE/shutdown.jcl
HERCJIS=/home/dan/herc-tools/bin/hercjis

test -x $SCREEN || exit 1
test -d $HERCDIR || exit 1
test -x $HERCSTART || exit 1
test -e $SHUTDOWN_JCL || exit 1
test -x $HERCJIS || exit 1

case "$1" in
start)
	if [ "$(pidof hercules)" ]; then
		echo "Hercules is already running"
	else
		# For SDL-Hyperion
		if [ -f $HERCENV ]; then
			echo "Loading Hercules Envirorment vars"
			# dot command to make the env vars stick
    			. $HERCENV
		fi

		echo "Starting Hercules S/390 emulator..."
		cd $HERCDIR
		$SCREEN -D -m "$HERCSTART" &
	fi
;;
stop)
	PID=$(pidof hercules)
	if [ "$PID" ]; then
		$HERCJIS $SHUTDOWN_JCL
		# Wait up to 5 minutes (60 * 5) for systems to shut down
		n=60
		while [ $n -gt 0 ] && [ "$(pidof hercules)" ]; do
			sleep 5
			n=$(expr $n - 1)
		done
		# Fail if Hercules is still running
		if [ "$(pidof hercules)" ]; then
			echo "Failed hercules shutdown"
			exit 1
		else
			echo "Clean Shutdown of hercules"
			exit 0
		fi
	fi
;;
*)
	echo "Usage: controlmvs.sh {start|stop}"
	echo "Usage: systemctl {start|stop} hercules.service"
	exit 1
esac
