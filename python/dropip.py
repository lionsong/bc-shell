#!/usr/bin/python
#coding:utf-8
####本脚本功能：封禁传参ip，禁止其访问网站入口####
####Create by SongLiGuo 2015.02.11 ###############
import os
import re
import sys
import time
from IPy import IP

###高危操作，暂不指向线上真实ip对象 #####
Target_ip=['web-32-2.liepin.inc','web-32-3.liepin.inc','web-32-4.liepin.inc','web-32-5.liepin.inc','ops-32-1.liepin.inc']
#Target_ip=['ops-32-1.liepin.inc']
white_list=['192.168.0.0/16','127.0.0.1','0.0.0.0','10.10.0.0/16','118.186.252.98']
ISOtimeformat='%Y-%m-%d %X'
ip_list=[]

class drop_ip:
    def __init__(self,ip):
        self.ip=ip
        self.clean="iptables -t raw -F"
        self.view="iptables -t raw -vnL PREROUTING --line"
        self.drop="iptables -t raw -A PREROUTING -s %s -j DROP"%self.ip
        self.dropone="iptables -t raw -D PREROUTING -s %s -j DROP"%self.ip
        self.delone="iptables -t raw -D PREROUTING 1"

    def check_ip(self,arg):
        pattern=re.compile("^(\d{1,3}\.){3}\d{1,3}$")
        if re.match(pattern,arg):
            print "The %s is OK" %arg
            for ip in white_list:
                if arg in IP(ip):
                    print "\033[1;31;40mThe ip %s in white list so do not it\033[0m"%arg
                    return False
            return True
        else:
            print "\033[1;31;40mThe ip %s is wrong !!!\033[0m" %arg
            return False

    def ip_state(self,host):
        DO_it="mco shell '%s' -I %s "%(self.view,host)
        return os.popen(DO_it).read()

    def cmd_ip(self,host,state):
        if state == "clean":
            cmd=self.clean
        elif state == "close":
            cmd=self.drop
        elif state == "one":
            cmd=self.delone
        elif state == "dropone":
            cmd=self.dropone
        DO_it="mco shell '%s' -I %s >/dev/null"%(cmd,host)
        os.popen(DO_it)

    def log(self,host,ip,state):
        if state == "clean":
            content="#%s clean all ip for iptables is OK"%host
        elif state == "close":
            content="#%s Drop IP %s is Successfull !!!"%(host,ip)
        return content

    def log_cache(self,ip,state):
        F=open('/tmp/ip.cache','a+')
        for i in F.readlines():
            ip_list.append(i.strip()) 
        ip_dic=dict(item.split('#')[:2]for item in ip_list)
        if ip not in ip_dic.values():
            if state == "delete":
                pass
            elif state == "write":
                F.write(str(int(time.time()))+'#'+ip+'\n')
        F.close()
def help():
    print "The %s need argument!! for example: python %s [list or clean or ip_address or ip_address del]"%(sys.argv[0],sys.argv[0])       
    sys.exit(-1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        help()
    elif len(sys.argv) >2:
        if sys.argv[2] and sys.argv[2] == "del":
            ip=sys.argv[1]
            T=drop_ip(ip)
            for host in Target_ip:
                T.cmd_ip(host,'dropone')
        print "\033[1;31;40m clean one ip for iptables is OK \033[0m"
        sys.exit()
    ip=sys.argv[1]
    T=drop_ip(ip)
    Log=open('/opt/python/dropip.log','a')
    if ip == "list":
        for host in Target_ip:
            print T.ip_state(host)
        Log.close()
        sys.exit()     

    if ip == "clean" :
        for host in Target_ip:
            T.cmd_ip(host,'clean')
            Log.write(time.strftime(ISOtimeformat,time.localtime())+T.log(host,ip,'clean')+'\n')
        print "\033[1;31;40m clean all ip for iptables is OK \033[0m"
        Log.close()
        sys.exit()  

    if T.check_ip(ip):
        for host in Target_ip:
            IPrt=T.ip_state(host)
            num=int(IPrt.count('DROP'))-1
            if IPrt.count(ip) != 0:
                print "The \033[1;31;40m IP %s is exsits \033[0m" %ip
                continue
            if num >= 100:
                T.cmd_ip(host,'one') 
                T.cmd_ip(host,'close')      
            else:
                T.cmd_ip(host,'close')
                log_con="%s Drop IP %s is Successfull !!!"%(host,ip)
                Log.write(time.strftime(ISOtimeformat,time.localtime())+T.log(host,ip,'close')+'\n')
                print "The \033[1;31;40m %s Drop IP %s is Successfull !!! \033[0m"%(host,ip)
        T.log_cache(ip,'write')
                
    else:
        print "Faild"
    Log.close()
