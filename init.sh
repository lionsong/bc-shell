#!/bin/bash
#Author:lionsong
#Time:2012:02:24
#
export LANG=C

Changevi () {
	vi_path=$(whereis vi|awk '{print $2}')	
	vim_path=$(whereis vim|awk '{print $2}')
	mv ${vi_path} /bin/vi_bak
	ln -s ${vim_path} ${vi_path}

}

Re=`tail -1 /etc/security/limits.conf |awk '{print $3}'`
if [[ $Re == "nofile" ]]
then
        echo "add to /etc/security/limits.conf is OK"
else
        echo "* - nofile 767623" >> /etc/security/limits.conf
        echo "add to /etc/security/limits.conf is OK"
fi

#Profile_LANG=`tail -1 /etc/profile |grep "LANG"` || echo "LANG=zh_CN.GB18030" >> /etc/profile

#echo $LANG

Service () {
        export LANG=C
        for i in `chkconfig --list|awk '$NF == "6:off" {print $1}'`
        do
                chkconfig --level 2345 $i off
        done

        Slist=(crond network sshd syslog )

        for((i=0;i<${#Slist[@]};i++))
        do
                chkconfig --level 2345 ${Slist[$i]} on
        done

}

Userclose () {
        for i in `awk -F: '{if($1!="root")print $1}' /etc/passwd`
        do
                usermod -s /sbin/nologin $i
        done
}
syskernel () {
cat << EOF >> /etc/sysctl.conf
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets  = 5000
EOF
sysctl -p
}
Service
#Userclose
syskernel
Changevi

