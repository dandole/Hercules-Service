#!/usr/bin/bash

HERCENV=/home/dan/herc/herc4x/aethra-init-bash.sh
SCREEN=/usr/bin/screen
OSDIR=/home/dan/MVSCE
HERCSTART=/home/dan/MVSCE/start_mvs.sh
SHUTDOWN_JCL=/home/dan/MVSCE/shutdown.jcl
HERCJIS=/usr/bin/nc
PRINTER=/home/dan/virtual1403/virtual1403

test -x $SCREEN || exit 1
test -d $HERCDIR || exit 1
test -x $HERCSTART || exit 1
test -e $SHUTDOWN_JCL || exit 1
test -x $HERCJIS || exit 1
test -x $PRINTER || exit 1

case "$1" in
start)
        CHECK=$($SCREEN -ls | grep PRT_00E)
        if [ "$CHECK" == "" ]; then
                echo Starting V_Printer 00E Class A
                cd $OSDIR
                $SCREEN -S PRT_00E_CLASS_A -D -m "$PRINTER" --config $OSDIR/cfg1403.yaml &
        fi

        CHECK=$($SCREEN -ls | grep PRT_00F)
        if [ "$CHECK" == "" ]; then
                echo Starting V-Printer 00F Class M
                $SCREEN -S PRT_00F_CLASS_M -D -m "$PRINTER" --config $OSDIR/cfg1404.yaml &
        fi

        CHECK=$($SCREEN -ls | grep PRT_015)
        if [ "$CHECK" == "" ]; then
                echo Starting V-Printer 015 Class L
                $SCREEN -S PRT_015_CLASS_L -D -m "$PRINTER" --config $OSDIR/cfg1405.yaml &
        fi

        PID=$(pidof hercules)
        if [ "$PID" == "" ]; then
                # For SDL-Hyperion
                if [ -f $HERCENV ]; then
                        echo "Loading Hercules Envirorment vars"
                        # dot command to make the env vars stick
                        . $HERCENV
                fi

                cd $OSDIR
                $SCREEN -S MVSCE -t MSVCE -D -t MVSCE -m "$HERCSTART" &
        fi
;;
stop)
        PID=$(pidof hercules)
        if [ "$PID" ]; then
                $HERCJIS -w1 localhost 3505 < $SHUTDOWN_JCL
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
