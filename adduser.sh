#!/bin/bash

if [ -z $1 ]
then
    echo "The `basename $0` need args!!"
    exit 1
fi
if [ ! -d /home/$1 ]
then
    useradd $1 
fi

mkdir -p /home/$1/.ssh && chmod 700 /home/$1/.ssh && cp -f /keys/proxy.conf /home/$1
cp -f /keys/id_rsa /home/$1/.ssh/ && chown -R $1.$1 /home/$1/.ssh/

if [ -n $2 -a $2 == "key" ]
then
    echo "Creating $1 key......."
    su - $1 -c "cd /home/$1/.ssh/;ssh-keygen -t dsa -f $1 -q -N '' "
    cat /home/$1/.ssh/$1.pub > /home/$1/.ssh/authorized_keys
    chmod 600 /home/$1/.ssh/authorized_keys
    chown -R $1.$1 /home/$1/.ssh/authorized_keys
else
    echo "OK"
fi

sed -i "/$1/s/bash/bcash/" /etc/passwd
