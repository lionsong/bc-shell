#!/bin/bash


rrdfile="/data/dxtrafic.rrd"
PIC="/usr/local/webserver/nginx/html/dx.png"

rrdtool graph $PIC                    \
    --title "电信流量"     \
    --vertical-label "dx traffic"   \
    --color "BACK#CCCCCC"             \
    --color "CANVAS#CCFFFF"           \
    --color "SHADEB#9999CC"           \
    --height 200                      \
    --width  400                      \
    --slope-mode                      \
    --alt-autoscale                   \
    --lower-limit 0                   \
    DEF:IN=$rrdfile:IN:LAST      \
    DEF:OUT=$rrdfile:OUT:LAST    \
    VDEF:inmax=IN,MAXIMUM	\
    VDEF:inavg=IN,AVERAGE	\
    VDEF:inmin=IN,MINIMUM	\
    VDEF:outmax=OUT,MAXIMUM	\
    VDEF:outavg=OUT,AVERAGE	\
    VDEF:outmin=OUT,MINIMUM	\
    CDEF:inbits=IN,8,*		\
    CDEF:outbits=OUT,8,*	\
    COMMENT:"		"	\
    COMMENT:"max	"	\
    COMMENT:"avg	"	\
    COMMENT:"min	"	\
    COMMENT:"\n"    \
    AREA:inbits#00FF00:"Inbound"        \
    GPRINT:inmax:"%6.2lf %Sbps"		\
    GPRINT:inavg:"%6.2lf %Sbps"		\
    GPRINT:inmin:"%6.2lf %Sbps"		\
    COMMENT:"\n"    \
    LINE2:outbits#FF0000:"Outbound"        \
    GPRINT:outmax:"%6.2lf %Sbps"		\
    GPRINT:outavg:"%6.2lf %Sbps"		\
    GPRINT:outmin:"%6.2lf %Sbps"		\
    -h 200 -w 600 \
    COMMENT:"\n"    \
    COMMENT:"Last update\: $(date '+%Y-%m-%d %H\:%M\:%S' -r $rrdfile)"
