#!/bin/bash
# remove_old_mail.sh
# Removes queued mail with messages older then 1 day
# 15 * * * * /root/remove_old_mail.sh > /dev/null 2>&1


mailq () {
        /usr/sbin/exiqgrep -o 86400 -b
}

for line in `mailq| awk '{ print $1 }'`; do /usr/sbin/exim -Mrm $line; done
