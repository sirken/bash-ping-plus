#!/bin/bash

# Logfile location
logdir_base=~/ping_logs

# CLI parameters: hostname, packet size
host=$1
packet=$2

mkdir -p "$logdir_base"
cd "$logdir_base"

# If hostname doesn't exist, show tip
if [ -z $host ]; then
    echo "Usage: `basename $0` [HOST] [PACKET SIZE]"
    exit 1
fi

# If packet size isn't entered, default size
if [ -z $packet ]; then
    packet=56
fi

# verify IP
if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	ip=$host
else
	ip=`getent hosts $host | awk '{ print $1 ; exit }'`
fi


while :; do
	logdir="$logdir_base/`date +%Y`/`date +%m`/`date +%d`"
	if [ ! -d "$logdir" ]; then
		mkdir -p "$logdir"
	fi
    fileName="$logdir/ping_[$host]_`date +'%Y%m%d'`.txt"
    result=`ping -W 1 -c 1 $ip | grep 'bytes from '`
    if [ $? -gt 0 ]; then
        echo -e "`date +'%m/%d/%y %H:%M:%S'` - $host is \033[0;31mdown\033[0m"
        echo -e "`date +'%m/%d/%y %H:%M:%S'` - $host is down" >> $fileName
    else
         echo -e "`date +'%m/%d/%y %H:%M:%S'` - $host is \033[0;32mup\033[0m - size=$packet ttl=`echo $result | awk -F"ttl=" '{print $2}'`"
         echo -e "`date +'%m/%d/%y %H:%M:%S'` - $host is up - size=$packet ttl=`echo $result | awk -F"ttl=" '{print $2}'`">> $fileName
    fi
    sleep 1 # pause between pings
done
