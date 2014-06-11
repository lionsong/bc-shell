#!/bin/bash

sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.eth9.rp_filter=0
sysctl -w net.ipv4.tcp_tw_recycle=1
sysctl -w net.ipv4.tcp_tw_reuse=1

###route add###
for rt in vpn dx
do
	ip route flush table $rt
	ip route show |grep -v default|while read line; do ip route add $line table $rt; done
	ip route flush cache 
#
done

ip route add default via 172.16.100.2 dev eth9:vpn table vpn
ip route add default via 106.120.110.225 dev eth9:dx table dx
####iptables config###
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -P FORWARD DROP
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -s 0/0 -d 192.168.28.0/24 -j ACCEPT
iptables -A FORWARD -s 0/0 -d 192.168.31.0/24 -j ACCEPT
iptables -A FORWARD -s 192.168.28.81 ! -d 192.168.0.0/16 -j ACCEPT
iptables -A FORWARD -s 192.168.28.83 ! -d 192.168.0.0/16 -j ACCEPT
iptables -A FORWARD -s 192.168.28.32/27 ! -d 192.168.0.0/16 -j ACCEPT
iptables -A FORWARD -s 192.168.25.0/24 -d 0/0 -j ACCEPT
iptables -A FORWARD -s 192.168.21.0/24 ! -d 192.168.0.0/16 -j ACCEPT
iptables -A FORWARD -s 192.168.22.0/24 ! -d 192.168.0.0/16 -j ACCEPT
iptables -A FORWARD -s 192.168.23.0/24 ! -d 192.168.0.0/16 -j ACCEPT
iptables -A FORWARD -s 192.168.24.0/24 ! -d 192.168.0.0/16 -j ACCEPT
iptables -A FORWARD -s 192.168.27.0/24 ! -d 192.168.0.0/16 -j ACCEPT
iptables -A FORWARD -s 192.168.29.0/24 ! -d 192.168.0.0/16 -j ACCEPT
iptables -A FORWARD -s 192.168.30.0/24 ! -d 192.168.0.0/16 -j ACCEPT
iptables -t nat -A PREROUTING -i eth0 -p udp --dport 53 -j REDIRECT --to-port 53
#iptables -t nat -A PREROUTING -p tcp --dport 53 -j DNAT --to 192.168.8.245:53

#iptables -t nat -A POSTROUTING -o eth9 -s 192.168.25.0/24 -d 0/0 -j SNAT --to-source 106.120.110.226
iptables -t nat -A POSTROUTING -s 192.168.25.0/24 -d 192.168.3.0/24 -j RETURN
iptables -t nat -A POSTROUTING -o eth9 -j MASQUERADE
#iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

#####mark table###
iptables -t mangle -A PREROUTING -i eth0 -s 192.168.25.0/24 -j MARK --set-mark 210
iptables -t mangle -A PREROUTING -i eth1 -s 192.168.21.0/24 -j MARK --set-mark 210
#iptables -t mangle -A PREROUTING -i eth2 -s 192.168.24.0/24 -j MARK --set-mark 210 ####jishu####
iptables -t mangle -A PREROUTING -i eth4 -s 192.168.27.0/24 -j MARK --set-mark 210
#iptables -t mangle -A PREROUTING -i eth0 -s 192.168.25.0/24 -j MARK --set-mark 111
#iptables -t mangle -A PREROUTING -i eth0 -s 192.168.8.0/24 -d 199.59.150.7 -j MARK --set-mark 222   ####twitter.com
#iptables -t mangle -A PREROUTING -i eth0 -s 192.168.25.0/24 -d identix.state.gov -j MARK --set-mark 111   ####identix.state.gov
#iptables -t mangle -A PREROUTING -i eth1 -s 192.168.21.0/24 -d identix.state.gov -j MARK --set-mark 111   ####identix.state.gov
#iptables -t mangle -A PREROUTING -i eth2 -s 192.168.24.0/24 -d identix.state.gov -j MARK --set-mark 111   ####identix.state.gov
#iptables -t mangle -A PREROUTING -i eth4 -s 192.168.27.0/24 -d identix.state.gov -j MARK --set-mark 111   ####identix.state.gov
##iptables -t mangle -A PREROUTING -i eth0 -s 192.168.8.0/24 -d rentalcars.com -j MARK --set-mark 222   ####rentalcars.com
#iptables -t mangle -A PREROUTING -i eth0 -s 192.168.8.0/24 -d cardelmar.co.uk -j MARK --set-mark 222   ####cardelmar.co.uk
#iptables -t mangle -A PREROUTING -i eth0 -s 192.168.8.0/24 -d carhire3000.com -j MARK --set-mark 222   ####carhire3000.com
#iptables -t mangle -A PREROUTING -i eth4 -s 192.168.27.0/24 -d www.visa4uk.fco.gov.uk -j MARK --set-mark 222   ####www.visa4uk.fco.gov.uk
#iptables -t mangle -A PREROUTING -i eth0 -s 192.168.25.0/24 -d www.visa4uk.fco.gov.uk -j MARK --set-mark 222   ####www.visa4uk.fco.gov.uk
iptables -t mangle -A PREROUTING -i eth0 -s 192.168.25.0/24 -d 74.125.128.0/24 -j MARK --set-mark 111
iptables -t mangle -A PREROUTING -i eth0 -s 192.168.25.0/24 -d 31.13.70.0/24 -j MARK --set-mark 111
iptables -t mangle -A PREROUTING -i eth0 -s 192.168.25.0/24 -d 173.194.33.0/24 -j MARK --set-mark 111
iptables -t mangle -A PREROUTING -i eth0 -s 192.168.25.0/24 -d 173.194.127.0/24 -j MARK --set-mark 111
