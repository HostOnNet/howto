#!/bin/sh
#
# $FreeBSD: ports/mail/postfix/files/postfix.sh.in,v 1.3 2006/01/16 21:47:47 mnag Exp $
#
# PROVIDE: postfix
# REQUIRE: DAEMON slapd
# KEYWORD: shutdown
#
# Add the following lines to /etc/rc.conf to enable postfix:
# postfix_enable (bool):	Set it to "YES" to enable postfix.
#				Default is "NO".
# postfix_pidfile (path):	Set full path to master.pid.
#				Default is "/var/spool/postfix/pid/master.pid".
# postfix_procname (command):	Set command that start master. Used to verify if
#				postfix is running.
#				Default is "/usr/local/libexec/postfix/master".
#

. /etc/rc.subr

name="postfix"
rcvar=`set_rcvar`

load_rc_config $name

: ${postfix_enable="NO"}
: ${postfix_pidfile="/var/spool/postfix/pid/master.pid"}
: ${postfix_procname="/usr/libexec/postfix/master"}

start_cmd=${name}_start
stop_cmd=${name}_stop
extra_commands="reload"

pidfile=${postfix_pidfile}
procname=${postfix_procname}

postfix_start() {
	/usr/sbin/postfix start
}

postfix_stop() {
	/usr/sbin/postfix stop
}

run_rc_command "$1"
