#!/bin/sh
#
# start/stop rpcbind daemon.

### BEGIN INIT INFO
# Provides:          rpcbind
# Required-Start:    $network $local_fs
# Required-Stop:     $network $local_fs
# Default-Start:     S 2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: RPC portmapper replacement
# Description:       rpcbind is a server that converts RPC (Remote
#                    Procedure Call) program numbers into DARPA
#                    protocol port numbers. It must be running in
#                    order to make RPC calls. Services that use
#                    RPC include NFS and NIS.
### END INIT INFO

test -f /sbin/rpcbind || exit 0

. /lib/lsb/init-functions

OPTIONS="-w"
STATEDIR=/var/run/rpcbind
if [ -f /etc/default/rpcbind ]
then
    . /etc/default/rpcbind
elif [ -f /etc/rpcbind.conf ]
then
    . /etc/rpcbind.conf
fi

start ()
{
    if [ ! -d $STATEDIR ] ; then
        mkdir $STATEDIR
    fi
    if [ ! -O $STATEDIR ] ; then
        log_begin_msg "$STATEDIR not owned by root"
        log_end_msg 1
        exit 1
    fi
    log_begin_msg "Starting rpcbind daemon..."
    ps=$( ps aux | grep /sbin/rpcbind | grep -v grep )
    if [ -n "$ps" ]
    then
        log_begin_msg "Already running."
        log_end_msg 0
        exit 0
    fi
    start-stop-daemon --start --quiet --oknodo --exec /sbin/rpcbind -- "$@"
    log_end_msg $?
}

stop ()
{
    log_begin_msg "Stopping rpcbind daemon..."
    start-stop-daemon --stop --quiet --oknodo --exec /sbin/rpcbind
    log_end_msg $?
}

case "$1" in
    start)
        start $OPTIONS
        ;;
    stop)
        stop
        ;;
    force-reload)
        stop
        start $OPTIONS
        ;;
    restart)
        stop
        start $OPTIONS
        ;;
    status)
        status_of_proc /sbin/rpcbind rpcbind && exit 0 || exit $?
        ;;
    *)
        log_success_msg "Usage: /etc/init.d/rpcbind {start|stop|force-reload|restart|status}"
        exit 1
        ;;
esac

exit 0