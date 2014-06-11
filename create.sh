#!/bin/bash

# create a rrd file

rrdfile="/data/vpntrafic.rrd"
STEP=300
HEARTBEAT=600
now=`date +%s`

if [ ! -f $rrdfile ]
then
    rrdtool create $rrdfile --start $now --step $STEP \
    DS:IN:COUNTER:$HEARTBEAT:U:U              \
    DS:OUT:COUNTER:$HEARTBEAT:U:U             \
    RRA:AVERAGE:0.5:1:603 \
    RRA:AVERAGE:0.5:6:603 \
    RRA:AVERAGE:0.5:24:603 \
    RRA:AVERAGE:0.5:288:800 \
    RRA:LAST:0.5:1:603 \
    RRA:LAST:0.5:6:603 \
    RRA:LAST:0.5:24:603 \
    RRA:LAST:0.5:288:800 \

else
    echo "$rrdfile already exists, remove it"
fi

TEMPLATE_STR="IN:OUT"

while :
do
    IN=`snmpwalk -cpublic -v2c 172.16.100.2 IF-MIB::ifInOctets.2|awk '{print $NF}'`
    OUT=`snmpwalk -cpublic -v2c 172.16.100.2 IF-MIB::ifOutOctets.2|awk '{print $NF}'`
    rrdtool update $rrdfile                           \
        --template $TEMPLATE_STR                      \
        N:$IN:$OUT

    sleep $STEP
done
