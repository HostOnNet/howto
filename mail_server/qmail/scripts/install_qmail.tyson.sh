#!/bin/sh

workdir=/usr/src/files/qmail/
url="http://10.1.90.205"
qmailadminversion="1.2.9"
vpopmailversion="5.4.0"
courierauthlibversion="0.57"
courierimapversion="4.0.4"
hostname=`hostname`
osvers=`uname -sr`
case $osvers in
FreeBSD*)
	runos="FREEBSD"
	download=`which fetch`
	courierimapmake=`which gmake`
	;;
Linux*)
	if [ -e /etc/redhat-release ]; then
	runos="REDHAT"
	download=`which wget`
	courierimapmake=`which make`
	else
		runos="LINUX"
		download=`which wget`
		courierimapmake=`which make`
	fi
	;;
*)
	echo -n "Unable to determine OS"
	exit 1
	;;
esac

if [ ! -e $workdir ]; then
        mkdir -p $workdir
fi

if [ ! -e "/bin/true" ]; then
	ln -s `which true` /bin/true
fi


bigfetch () {
cd $workdir
echo -n "downloading packages .."
$download $url/qmail-1.03.tar.gz >> /dev/null 2>&1
$download $url/ucspi-ssl-0.68.tar.gz >> /dev/null 2>&1
$download $url/ucspi-tcp-0.88.tar.gz >> /dev/null 2>&1
$download $url/qmailadmin-$qmailadminversion.tar.gz >> /dev/null 2>&1
$download $url/vpopmail-$vpopmailversion.tar.gz >> /dev/null 2>&1
$download $url/ezmlm-0.53.tar.gz >> /dev/null 2>&1
$download $url/autorespond.tar.gz >> /dev/null 2>&1
$download $url/dot-forward-0.71.tar.gz >> /dev/null 2>&1
$download $url/daemontools-0.76.tar.gz >> /dev/null 2>&1
$download $url/qmail-1.03-jms1.5f.patch >> /dev/null 2>&1
$download $url/toaster-scripts.tar.gz >> /dev/null 2>&1
$download $url/run.smtp >> /dev/null 2>&1

echo "done"
}

qmailinstall () {
# install daemontools
echo -n "installing daemontools .."
mkdir -p /package
chmod 1755 /package
cd /package
tar -xpzf $workdir/daemontools-0.76.tar.gz >> /dev/null 2>&1
cd admin/daemontools-0.76/src
mv -f error.h error.h.tmp
echo "#include <errno.h>" > error.h
cat error.h.tmp >> error.h
cd ..
package/install >> /dev/null 2>&1

if [ ! "`ps ax | grep svsca[n]`" ]; then
	csh -cf '/command/svscanboot &'
fi


# install ucspi-tcp-ssl
cd $workdir
echo -n "installing ucspi-ssl .."
tar -zxvf ucspi-ssl-0.68.tar.gz >> /dev/null 2>&1
cd ucspi-ssl-0.68
package/install >> /dev/null 2>&1
echo "done"

#install ucspi-tcp
cd $workdir
echo -n "installing ucspi .."
tar -zxvf ucspi-tcp-0.88.tar.gz >> /dev/null 2>&1
cd ucspi-tcp-0.88
make && make setup check >> /dev/null 2>&1
echo "done"

echo -n "installing qmail .."
# install qmail
cd $workdir
tar -zxvf qmail-1.03.tar.gz >> /dev/null 2>&1
tar -zxvf toaster-scripts.tar.gz >> /dev/null 2>&1
cd qmail-1.03
patch -p1 < ../qmail-1.03-jms1.5f.patch
if [ ! -e /usr/qmail ]; then
	mkdir /usr/qmail
fi
ln -s /usr/qmail /var/qmail


if [ $runos = FREEBSD ]; then
pw groupadd nofiles >> /dev/null 2>&1
	pw useradd alias -g nofiles -d /var/qmail/alias -s /nonexistent >> /dev/null 2>&1
	pw useradd qmaild -g nofiles -d /var/qmail -s /nonexistent >> /dev/null 2>&1
	pw useradd qmaill -g nofiles -d /var/qmail -s /nonexistent >> /dev/null 2>&1
	pw useradd qmailp -g nofiles -d /var/qmail -s /nonexistent >> /dev/null 2>&1
	pw groupadd qmail >> /dev/null 2>&1
	pw useradd qmailq -g qmail -d /var/qmail -s /nonexistent >> /dev/null 2>&1
	pw useradd qmailr -g qmail -d /var/qmail -s /nonexistent >> /dev/null 2>&1
	pw useradd qmails -g qmail -d /var/qmail -s /nonexistent >> /dev/null 2>&1
	pw groupadd -n vchkpw -g 89 >> /dev/null 2>&1
	pw useradd -u 89 -n vpopmail -d /home/vpopmail -g vchkpw >> /dev/null 2>&1
	mkdir /home/vpopmail >> /dev/null 2>&1
	chown vpopmail:vchkpw /home/vpopmail >> /dev/null 2>&1
else
	groupadd nofiles >> /dev/null 2>&1
	useradd -g nofiles -d /var/qmail/alias alias >> /dev/null 2>&1
	useradd -g nofiles -d /var/qmail qmaild >> /dev/null 2>&1
	useradd -g nofiles -d /var/qmail qmaill >> /dev/null 2>&1
	useradd -g nofiles -d /var/qmail qmailp >> /dev/null 2>&1
	groupadd qmail >> /dev/null 2>&1
	useradd -g qmail -d /var/qmail qmailq >> /dev/null 2>&1
	useradd -g qmail -d /var/qmail qmailr >> /dev/null 2>&1
	useradd -g qmail -d /var/qmail qmails >> /dev/null 2>&1
	if [ "`id postfix`" ]; then
		userdel postfix
		groupdel postfix
	fi
	groupadd -g 89 vchkpw >> /dev/null 2>&1
	useradd -g vchkpw -u 89 vpopmail >> /dev/null 2>&1
fi
make setup check >> /dev/null 2>&1
./config-fast $hostname >> /dev/null 2>&1
cd ~alias
for i in .qmail-postmaster .qmail-mailer-daemon .qmail-root
do
: > $i
done
echo "done"

# setup supervise scripts
echo -n "setting up supervise scripts .."
cd $workdir
cp toaster-scripts/rc /var/qmail/rc
chmod 755 /var/qmail/rc
echo ./Maildir/ >/var/qmail/control/defaultdelivery
cp toaster-scripts/qmailctl /var/qmail/bin/
chmod 755 /var/qmail/bin/qmailctl
ln -s /var/qmail/bin/qmailctl /usr/bin
mkdir -p /var/qmail/supervise/qmail-send/log
mkdir -p /var/qmail/supervise/qmail-smtpd/log
mkdir -p /var/qmail/supervise/qmail-pop3d/log
mkdir -p /var/qmail/supervise/qmail-pop3ds/log
chmod +t /var/qmail/supervise/qmail-send
chmod +t /var/qmail/supervise/qmail-smtpd
chmod +t /var/qmail/supervise/qmail-pop3d/log
chmod +t /var/qmail/supervise/qmail-pop3ds/log
cp $workdir/toaster-scripts/send.run /var/qmail/supervise/qmail-send/run
cp $workdir/toaster-scripts/send.log.run /var/qmail/supervise/qmail-send/log/run
cp $workdir/toaster-scripts/smtpd.run /var/qmail/supervise/qmail-smtpd/run
cp $workdir/toaster-scripts/smtpd.log.run /var/qmail/supervise/qmail-smtpd/log/run
cp $workdir/toaster-scripts/pop3d.run /var/qmail/supervise/qmail-pop3d/run
cp $workdir/toaster-scripts/pop3d.log.run /var/qmail/supervise/qmail-pop3d/log/run
cp $workdir/toaster-scripts/pop3ds.run /var/qmail/supervise/qmail-pop3ds/run
cp $workdir/toaster-scripts/pop3ds.log.run /var/qmail/supervise/qmail-pop3ds/log/run

cp -f $workdir/run.smtp /var/qmail/supervise/qmail-smtpd/run
chmod +x /service/qmail-smtpd/run

echo 20 > /var/qmail/control/concurrencyincoming
chmod 644 /var/qmail/control/concurrencyincoming
chmod 755 /var/qmail/supervise/qmail-send/run
chmod 755 /var/qmail/supervise/qmail-send/log/run
chmod 755 /var/qmail/supervise/qmail-smtpd/run
chmod 755 /var/qmail/supervise/qmail-smtpd/log/run
chmod 755 /var/qmail/supervise/qmail-pop3d/run
chmod 755 /var/qmail/supervise/qmail-pop3d/log/run
chmod 755 /var/qmail/supervise/qmail-pop3ds/run
chmod 755 /var/qmail/supervise/qmail-pop3ds/log/run
ln -s /var/qmail/supervise/qmail-send /var/qmail/supervise/qmail-smtpd /service
cd /service/qmail-smtpd
echo "done"

# setup sendmail wrappers
echo -n "setting up sendmail wrappers .."
mv /usr/sbin/sendmail /usr/sbin/sendmail.bak
ln -s /var/qmail/bin/sendmail /usr/sbin/sendmail
echo "done"

# install vpopmail
echo -n "installing vpopmail .."
cd $workdir
tar -zxvf vpopmail-$vpopmailversion.tar.gz >> /dev/null 2>&1
cd vpopmail-$vpopmailversion
mkdir -p /home/vpopmail/etc
chown -R vpopmail:vchkpw /home/vpopmail

./configure --enable-roaming-users=y --enable-logging=y --enable-clear-passwd=y >> /dev/null 2>&1
make >> /dev/null 2>&1
make install >> /dev/null 2>&1

ln -s /home/vpopmail/bin/* /usr/local/bin
cp $workdir/toaster-scripts/vpopmailctl /var/qmail/bin/vpopmailctl
chmod 755 /var/qmail/bin/vpopmailctl
ln -s /var/qmail/bin/vpopmailctl /usr/bin
ln -s /var/qmail/supervise/qmail-pop3d /var/qmail/supervise/qmail-pop3ds /service

echo "done"


# startup scripts
echo -n "configuring startup scripts .."
cat << EOF >> /etc/rc.local

/usr/bin/qmailctl start
/usr/bin/vpopmailctl start
EOF
echo "done"

echo -n "disabling sendmail .."
if [ $runos = FREEBSD ]; then
sed 's/^sendmail/sendmail_enable="NONE"/' /etc/rc.conf >> /etc/rc.conf.script
mv /etc/rc.conf.script /etc/rc.conf
else
chkconfig --level 235 sendmail off
fi
echo "done"

# install ezmlm
echo -n "installing ezmlm .."
cd $workdir
tar -zxvf ezmlm-0.53.tar.gz >> /dev/null 2>&1
cd ezmlm-0.53
mv -f error.h error.h.tmp
echo "#include <errno.h>" > error.h
cat error.h.tmp >> error.h
make >> /dev/null 2>&1
make man >> /dev/null 2>&1
make setup >> /dev/null 2>&1
echo "done"


# install autoresponder
echo -n "installing autoresponder .."
cd $workdir
tar -zxvf autorespond.tar.gz >> /dev/null 2>&1
gcc -Wall -o autorespond autorespond.c >> /dev/null 2>&1
chmod +x autorespond
cp autorespond /usr/local/bin
echo "done"


# install qmailadmin
echo -n "installing qmailadmin .."
cd $workdir
tar -zxvf qmailadmin-$qmailadminversion.tar.gz >> /dev/null 2>&1
cd qmailadmin-$qmailadminversion >> /dev/null 2>&1
mkdir -p /usr/local/apache/qmailadmin/mail
./configure  --enable-htmldir=/usr/local/apache/qmailadmin --enable-cgibindir=/usr/local/apache/qmailadmin/mail --enable-cgipath=/mail/qmailadmin --enable-autoresponder-bin=/usr/local/bin --enable-ezmlmdir=/usr/local/bin/ezmlm --enable-modify-quota >> /dev/null 2>&1
make >> /dev/null 2>&1
make install >> /dev/null 2>&1
echo "done"



# configure apache
echo -n "configuring httpd.conf .."
if [ -e /usr/local/apache/conf/httpd.conf ]; then
cat << EOF >> /usr/local/apache/conf/httpd.conf

ScriptAlias /mail /usr/local/apache/qmailadmin/mail/
Alias /mail/qmailadmin /usr/local/apache/qmailadmin/mail/qmailadmin
Alias /images/qmailadmin /usr/local/apache/qmailadmin/images/qmailadmin
EOF
killall -HUP httpd
echo "done"
else
	echo "config file not found"
	echo
	echo "dont forget to add these lines to the httpd.conf"
	echo
cat << EOF
ScriptAlias /mail /usr/local/apache/qmailadmin/mail/
Alias /mail/qmailadmin /usr/local/apache/qmailadmin/mail/qmailadmin
Alias /images/qmailadmin /usr/local/apache/qmailadmin/images/qmailadmin
EOF
	echo
fi

# get rid of bullshit emails
# /home/vpopmail/bin/vadddomain -e postmaster@`hostname` `hostname` duhhh

# startup everything
echo -n "starting everything .."
echo -n "killing sendmail .."
killall sendmail
ln -s /home /usr/home
/usr/bin/qmailctl cdb
chown vpopmail:vchkpw /home/vpopmail/etc/tcp.smtp.cdb
echo "done"

# setup crontab
echo -n "adding cronjobs .."
crontab -l > .tmp
cat << EOF >> .tmp

40 * * * * /home/vpopmail/bin/clearopensmtp 2>&1 > /dev/null
EOF
crontab .tmp
echo "done"
}

imapinstall () {
cd $workdir

echo -n "downloading packages .."
$download $url/courier-authlib-$courierauthlibversion.tar.bz2 >> /dev/null 2>&1
$download $url/courier-imap-$courierimapversion.tar.bz2 >> /dev/null 2>&1

echo "done"

# install courier-authlib
echo -n "installing courier-authlib .."
cd $workdir
tar -jxvf courier-authlib-$courierauthlibversion.tar.bz2 >> /dev/null 2>&1
cd courier-authlib-$courierauthlibversion >> /dev/null 2>&1
if [ $runos = REDHAT ]; then
	./configure --with-redhat --prefix=/usr/local/courier-authlib --without-authpam --without-authldap --without-authpwd --without-authmysql --without-authpgsql --without-authshadow --without-authuserdb --without-authcustom --without-authcram --without-authdaemon --with-authvchkpw --with-mailuser=vpopmail --with-mailgroup=vchkpw >> /dev/null 2>&1
else
	./configure --prefix=/usr/local/courier-authlib --without-authpam --without-authldap --without-authpwd --without-authmysql --without-authpgsql --without-authshadow --without-authuserdb --without-authcustom --without-authcram --without-authdaemon --with-authvchkpw --with-mailuser=vpopmail --with-mailgroup=vchkpw >> /dev/null 2>&1
fi
make >> /dev/null 2>&1
make install >> /dev/null 2>&1
make install-configure >> /dev/null 2>&1

echo "done"

# install courier-imap
echo -n "installing courier-imap .."
cd $workdir
tar -jxvf courier-imap-$courierimapversion.tar.bz2 >> /dev/null 2>&1
cd courier-imap-$courierimapversion >> /dev/null 2>&1
if [ $runos = REDHAT ]; then
	export CFLAGS="-DHAVE_OPEN_SMTP_RELAY -DHAVE_VLOGAUTH"
	export COURIERAUTHCONFIG=/usr/local/courier-authlib/bin/courierauthconfig
	export CPPFLAGS=-I/usr/local/courier-authlib/include
	./configure --with-redhat --prefix=/usr/local/courier-imap --disable-root-check --with-ssl >> /dev/null 2>&1
else
	export CFLAGS="-DHAVE_OPEN_SMTP_RELAY -DHAVE_VLOGAUTH"
	export COURIERAUTHCONFIG=/usr/local/courier-authlib/bin/courierauthconfig
	export CPPFLAGS=-I/usr/local/courier-authlib/include
	./configure --prefix=/usr/local/courier-imap --disable-root-check --with-ssl >> /dev/null 2>&1
fi
$courierimapmake >> /dev/null 2>&1
$courierimapmake install >> /dev/null 2>&1
$courierimapmake install-configure >> /dev/null 2>&1
cp courier-imap.sysvinit /usr/bin/courier-imap
chmod +x /etc/init.d/courier-imap
mkdir -p /var/lock/subsys/
sed 's/^TCPDOPTS.*/TCPDOPTS="-nodnslookup -noidentlookup -user=vpopmail -group=vchkpw"/' /usr/local/courier-imap/etc/imapd | sed 's/^IMAPDSTART.*/IMAPDSTART=YES/' /usr/local/courier-imap/etc/imapd.dist > /usr/local/courier-imap/etc/imapd
sed 's/^IMAPDSSLSTART.*/IMAPDSSLSTART=YES/' /usr/local/courier-imap/etc/imapd-ssl.dist > /usr/local/courier-imap/etc/imapd-ssl
cat << EOF > /usr/local/courier-imap/etc/imapd.cnf

RANDFILE = /usr/local/courier-imap/share/imapd.rand

[ req ]
default_bits = 1024
encrypt_key = yes
distinguished_name = req_dn
x509_extensions = cert_type
prompt = no

[ req_dn ]
C=US
ST=FL
L=Florida
O=Courier Mail Server
OU=Automatically-generated IMAP SSL key
CN=$hostname
emailAddress=postmaster@$hostname


[ cert_type ]
nsCertType = server
EOF
sed 's/^POP3DSSLSTART.*/POP3DSSLSTART=YES' /usr/local/courier-imap/etc/pop3d-ssl.dist > /usr/local/courier-imap/etc/pop3d-ssl 
echo "done"

# start courier-imap
echo -n "starting courier-imap .."
chmod +x /usr/bin/courier-imap
/usr/bin/courier-imap start
/usr/local/courier-authlib/sbin/authdaemond start
chown vpopmail:vchkpw /usr/local/courier-imap/var/
chown vpopmail:vchkpw /usr/local/courier-imap/share/imapd.pem
chown vpopmail:vchkpw /usr/local/courier-imap/share/pop3d.pem
cat << EOF >> /etc/rc.local

/usr/bin/courier-imap start
/usr/local/courier-authlib/sbin/authdaemond start
EOF
echo "done"
}


thefinish () {
echo
echo
echo "everything has been successfully installed"
echo "dont forget to add the domains and everything"
echo "just run: vadddomain <domain.com> <postmaster password>"
echo
echo
echo "you can access qmailadmin at:"
echo "http://www.domain.com/mail/qmailadmin"
echo
echo "qmail control info:"
/usr/bin/qmailctl stat
echo
echo "vpopmail control info:"
/usr/bin/vpopmailctl stat
exit 0
}

usage () {
echo "Usage:"
echo " $(basename $0) [-hi]"
echo "Flags:"
echo " -i, --imap  setup qmail with imap"
echo " -h, --help  this message"
echo "default is to install qmail"
exit 0
}

case $1 in
	-h|--help)
		usage
		;;
	-i|--imap)
		bigfetch
		qmailinstall
		imapinstall
		thefinish
		;;
	*)
		bigfetch
		qmailinstall
		thefinish
		;;
esac