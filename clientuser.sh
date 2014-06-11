#!/bin/bash

KEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAxnnxp5DnnoZ4eL162tPRa37hpNTA8RHLEo5WFQuxWZ9aO6gL6IoaJ15NdnYVbMJD31hvm5QLQEwD16MOx3M/JgWjRcQLCn/v0t1GYTz3rVJcQYt4Tdpw
lP54Epy2E1y8JsBd4JVKEyombe0dmsZZDSYqRUNsRkXafha0tGAr6Uk= public@proxy_all"

echo $KEY
useradd $1

if [ -f /home/$1/.ssh/authorized_keys ] 
then
    echo "$KEY" >> /home/$1/.ssh/authorized_keys
else
    mkdir -p /home/$1/.ssh
    echo "$KEY" > /home/$1/.ssh/authorized_keys
    chown -R $1.$1 /home/$1/.ssh/ && chmod -R 700 /home/$1/.ssh/
    chmod 600 /home/$1/.ssh/authorized_keys 
fi
