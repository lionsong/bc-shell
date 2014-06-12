#!/usr/bin/python

import paramiko
import ConfigParser
import threading
import sys
import time

#paramiko.util.log_to_file("support_scripts.log")
def client(IPLIST,NAME,CMD):
    for IP in IPLIST:
	t1=time.time()
	global Errorhost
	ssh2=paramiko.SSHClient()
	ssh2.set_missing_host_key_policy(paramiko.AutoAddPolicy())
	try:
	    ssh2.connect(IP,22,username=NAME,key_filename='/keys/id_rsa',timeout=4)
	except:
	    message="Connet to %s is faild!!!"%IP
	    Errorhost.append(message)
	else:
	    stdin,stdout,stderr=ssh2.exec_command(CMD)
	    result=stdout.readlines()
	    result_err=stderr.readlines()
	    ssh2.close()
	    t2=time.time()
	    if result_err:
		print "IP:%s"%IP,result_err,"%0.3f"%(t2-t1)
	    else:
		print "IP:%s"%IP,result,"%0.3f"%(t2-t1)

def target_host(host):
    IPlist=[f.rstrip() for f in open(host)]
    return IPlist

def progrouping(host,Num):
    Thread_pool={}
    IPlist=[f.rstrip() for f in open(host)]
    if int(Num) > len(IPlist):
	Num=len(IPlist)
    for i in xrange(int(Num)):
	Thread_pool[i]=[]
    while IPlist:
	for k,v in Thread_pool.items():
	    v.append(IPlist[0])
	    del IPlist[0]
	    if not IPlist:
		break
    return Thread_pool
    
if __name__ == '__main__':
    host=''
    Errorhost=[]
    NAME='songliguo'
    Thread_pool={}
    if len(sys.argv) < 3:
        print """The %s need argument
for example: The %s [ipfile] [cmd]"""%(sys.argv[0],sys.argv[0])
        sys.exit(-1)
    CMD=sys.argv[2]
    if sys.argv[1].find('ip=') != -1:
	host=sys.argv[1][3:len(sys.argv[1])].split(',')
	client(host,NAME,CMD)
	sys.exit(-1)
    GroupResult=progrouping(sys.argv[1],30)
    for x in xrange(len(GroupResult)):
	Thread_pool[x]=threading.Thread(target=client,args=(GroupResult[x],NAME,CMD))
    for t in Thread_pool:
	Thread_pool[t].start()
    for t in Thread_pool:
	Thread_pool[t].join()
    if Errorhost:
        fn=open('ip.log','w')
        fn.write('\n'.join(Errorhost))
        fn.close()
