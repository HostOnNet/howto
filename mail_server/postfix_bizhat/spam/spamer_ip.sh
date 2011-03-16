#!/usr/bin/bash

grep NOQUEUE /var/log/maillog| awk '{print $10}'| cut -d[ -f2 | while read line
do
len=${#line}-3
ipaddress=${line:1:$len}
echo $ipaddress >>/tmp/spammer-ip.dat
done
sort -rn /tmp/spammer-ips.dat|uniq -c