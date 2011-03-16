#!/bin/sh

OS=`uname`

#####################################################
# User Variables

APACHE_VER=1.3.41
MODSSL_VER=2.8.31
APACHE2_VER=2.0.63
PHP_VER=4.4.9
GD_VER=2.0.34
#GD_VER=2.0.35 #configure.ac:64: error: possibly undefined macro: AM_ICONV If this token and others are legitimate, please use m4_pattern_allow See the Autoconf documentation
#CURL_VER=7.15.5
#CURL_VER=7.16.0 #compile errors with this: undefined: CURLOPT_FTPASCII, etc
#CURL_VER=7.17.1
CURL_VER=7.19.3
#was 7.18.0
ZLIB_VER=1.2.3
#PNG_VER=1.2.10 //lib64 check below
FRONTPAGE_VER=1.6.1
MCRYPT_VER=2.5.8
MODPERL_FILE=mod_perl-1.0-current.tar.gz
MODPERL2_FILE=mod_perl-2.0-current.tar.gz
MODPERL_DIR=mod_perl-1.29
MODPERL2_DIR=mod_perl-2.0.3
MHASH_VER=0.9.1
#MHASH_VER=0.9.9
#MHASH_VER=0.9.2

#http://choon.net/opensource/php/php-${PHP_VER}-mail-header.patch
APPLY_MAIL_HEADER_PATCH=1
MAIL_HEADER_FILE=php-${PHP_VER}-mail-header.patch

if [ -e /etc/debian_version ]; then
	#ZZIP_VER=0.13.45
	ZZIP_VER=0.10.82
else
	#centos
	if [ "`grep -c 6 /etc/fedora-release 2>/dev/null`" = "1" ] || [ "`grep -c 7 /etc/fedora-release 2>/dev/null`" = "1" ] || [ "`grep -c 'CentOS release 5' /etc/redhat-release 2>/dev/null`" = "1" ] || [ "`grep -c 'Red Hat Enterprise Linux Server release 5' /etc/redhat-release 2>/dev/null`" = "1" ]; then
		ZZIP_VER=0.13.47
	elif [ "`grep -c Werewolf /etc/fedora-release 2>/dev/null`" = "1" ] || [ "`grep -c 8 /etc/fedora-release 2>/dev/null`" = "1" ]; then
		#fedora 8
		ZZIP_VER=0.13.45
	else
		ZZIP_VER=0.10.82
		#ZZIP_VER=0.13.38
		#ZZIP_VER=0.13.45
	fi
fi

#ZEND_VER=3.3.0  #this is breaking DA skins: /usr/local/bin/php quits immediately and accepts no input
ZEND_VER=3.2.8
#ZEND_VER=2.6.2
FBSD4_ZEND_VER=2.6.0

if [ -e /lib64 ]; then
	PNG_VER=1.2.8
	#PNG_VER=1.2.18
else
	PNG_VER=1.2.25
fi

DOVECOT_VER=1.1.10

PHP_CONFIGURE=configure.php
PHP_CONFIGURE_AP2=configure.php_ap2
PHP_INI=/usr/local/lib/php.ini
APACHE_SSL_CONFIGURE=configure.apache_ssl
APACHE2_CONFIGURE=configure.apache_2

HTTPDCONF=/etc/httpd/conf
HTTPD_CONF=${HTTPDCONF}/httpd.conf
WEBPATH=http://files.directadmin.com/services/customapache
WEBPATH_BACKUP=http://84.16.234.222/services/customapache

DEBIAN_VERSION=/etc/debian_version

USER_INPUT=1
INPUT_VALUE=d

if [ $OS = "FreeBSD" ]; then
        OS_VER=`uname -r | cut -d- -f1`
elif [ -e /etc/fedora-release ]; then
        OS=fedora
        OS_VER=`cat /etc/fedora-release | cut -d\  -f4`

	if [ "$OS_VER" = "(Moonshine)" ]; then
		OS_VER=7
	fi

	if [ "$OS_VER" = "4" ]; then
		ZZIP_VER=0.13.38
	fi
	if [ "$OS_VER" = "5" ]; then
		ZZIP_VER=0.13.38
	fi
else
        OS_VER=`cat /etc/redhat-release | cut -d\  -f5`
	if [ "$OS_VER" = "" ]; then
		OS_VER=`cat /etc/redhat-release | cut -d\  -f1`
	fi
fi

B64=0
if [ -e /usr/lib64 ]; then
	B64=1
fi

ROOT_GRP=root
if [ $OS = "FreeBSD" ]; then
	FRONTPAGE_EXT=fp50.freebsd.tar.gz
	ROOT_GRP=wheel
else
	FRONTPAGE_EXT=fp50.linux.tar.gz
fi
MOD_FRONTPAGE=mod_frontpage.c
FP_PATCH0=Makefile.tmpl.patch
FP_PATCH1=frontpage.patch
FP_PATCH_AP2=fp-patch-apache_2.0
FRONTPAGE_PATH=/usr/local


case "$OS_VER" in
        1|1.90|2|2.0|2.1|3|3.0|4|4.0|5|6|7.2|7.3|8.0|9|9.0|release|ES|WS|CentOS|7) ZENDNAME=ZendOptimizer-${ZEND_VER}-linux-glibc21-i386
                ;;
        4.8|4.9|4.10|4.11)	ZEND_VER=$FBSD4_ZEND_VER
				ZENDNAME=ZendOptimizer-${ZEND_VER}-freebsd4.3-i386
                ;;
        5.0|5.1|5.2|5.2.1|5.3|5.4|5.5) ZENDNAME=ZendOptimizer-${ZEND_VER}-freebsd5.4-i386
                ;;
	6.0|6.1|6.2) ZENDNAME=ZendOptimizer-${ZEND_VER}-freebsd6.0-i386
		;;
esac

if [ $B64 -eq 1 ]; then
	ZENDNAME=ZendOptimizer-${ZEND_VER}-linux-glibc23-x86_64
fi

if [ -e $DEBIAN_VERSION ]; then
	ZENDNAME=ZendOptimizer-${ZEND_VER}-linux-glibc21-i386
fi

ZENDFILE=${ZENDNAME}.tar.gz

JPEGFILE=jpegsrc.v6b.tar.gz
JPEGDIR=jpeg-6b

WEBALIZER=webalizer-2.01-10
WEBALIZER_FILE=webalizer-2.01-10-src.tgz

#####################################################

SERVICES=/usr/local/directadmin/data/admin/services.status

CWD=`pwd`
FORCE=0

showHelp() {
	echo "*************************************";
	echo "*                                   *";
	echo "* DirectAdmin WebServices Installer *";
	echo "*                                   *";
	echo "*************************************";
	echo "";
	echo "  To build everything run:";
	echo "     $0 all";
	echo "";
	echo "  Other options:";
	echo "     $0 php";
	echo "     $0 apache_mod_ssl";
	echo "     $0 gd";
	echo "     $0 libjpeg";
	echo "     $0 libpng";
	echo "     $0 zlib";
	echo "     $0 curl";
	echo "     $0 mcrypt";
	echo "     $0 mhash";
	echo "     $0 zzip";
	echo "     $0 mod_perl";
	echo "     $0 mod_frontpage     #dso depreciated";
	echo "     $0 frontpage_ext";
	echo "     $0 webalizer";
	echo "     $0 zend (not included with 'all')";
	echo "";
	echo "  Apache 2 options (beta):";
	echo "     $0 update_data_ap2";
	echo "     $0 convert";
	echo "     $0 apache_2";
	echo "     $0 php_ap2";
	echo "     $0 mod_frontpage_ap2";
	echo "     $0 mod_perl_ap2";
	echo "";
	echo "  Dovecot options (beta):";
	echo "     $0 update_dovecot";
	echo "     $0 dovecot";
	echo "     $0 todovecot";
	echo "";
	echo "  Remove old build data:";
	echo "     $0 clean";
	echo "";
	echo "";
	echo "  Get lastest build script and data";
	echo "     $0 update";
	echo "";
	echo "  Get data for current build script";
	echo "     $0 update_data";
	echo "";
	echo "  You can pass a 2nd argument to automate the input";
	echo "     $0 <option1> d : do the default action";
	echo "     $0 <option1> y : answer yes to all questions";
	echo "     $0 <optino1> n : answer no to all questions";
	echo "";
}

checkFile() {
	if [ ! -e $1 ]
	then
		echo "*** Cannot find $1. Aborting ***";
		exit 1;		
	else
		echo "Found $1";
	fi
}


####################################################

preCheck() {
	checkFile /usr/bin/patch
	checkFile /usr/bin/gcc
}


####################################################

checkCURL() {
	cd ${CWD};
	NUM=`cat ${PHP_CONFIGURE} | grep -c '\-\-with\-curl'`
	if [ $NUM = 0 ]
	then
		return;
	fi

	if [ -e /usr/local/lib/libcurl.so ]
	then
		if [ $USER_INPUT -eq 1 ]; then
			echo -n "cURL is already installed. Do you want to build it again? (y/n) :";
			read yesno;
			echo "";
		else
			if [ "$INPUT_VALUE" = "d" ]; then
				yesno=y
			else
				yesno=$INPUT_VALUE
			fi
		fi
		if [ "$yesno" = "n" ]
		then
			return;
		fi	
	fi
	
	doCURL;	
}

checkLibJpeg() {
	cd $CWD;
        NUM=`cat ${PHP_CONFIGURE} | grep -c '\-\-with\-jpeg\-dir'`
        if [ $NUM = 0 ]
        then
                return;
        fi

	if [ -e /usr/local/lib/libjpeg.a ]
	then
		if [ $FORCE = 1 ]
		then
			return;
		fi

		if [ $USER_INPUT -eq 1 ]; then
			echo -n "LibJPEG is already installed. Do you want to build it again? (y/n) :";
			read yesno;
			echo "";
                else
                        if [ "$INPUT_VALUE" = "d" ]; then
                                yesno=y
                        else
                                yesno=$INPUT_VALUE
                        fi
                fi


		if [ "$yesno" = "n" ]
		then
			return;
		fi
	fi

	doLibJpeg;
}

checkLibz() {
	#if this is called it has to be included :)

	if [ -e /usr/local/lib/libz.so ]
	then
		if [ $FORCE = 1 ]
		then
			return;
		fi

		if [ $USER_INPUT -eq 1 ]; then	
	                echo -n "LibZ is already installed. Do you want to build it again? (y/n) :";
        	        read yesno;
                	echo "";
                else
                        if [ "$INPUT_VALUE" = "d" ]; then
                                yesno=y
                        else
                                yesno=$INPUT_VALUE
                        fi
                fi

                if [ "$yesno" = "n" ]
                then
                        return;
                fi
        fi

	doZlib;
}

checkLibPng() {

        cd $CWD;
        NUM=`cat ${PHP_CONFIGURE} | grep -c '\-\-with\-png\-dir'`
        if [ $NUM = 0 ]
        then
                return;
        fi

	checkLibz;

        if [ -e /usr/local/lib/libpng.a ]
        then
		if [ $FORCE = 1 ]
		then
			return;
		fi
		
		if [ $USER_INPUT -eq 1 ]; then
	                echo -n "LibPng is already installed. Do you want to build it again? (y/n) :";
        	        read yesno;
                	echo "";
                else
                        if [ "$INPUT_VALUE" = "d" ]; then
                                yesno=y
                        else
                                yesno=$INPUT_VALUE
                        fi
                fi

                if [ "$yesno" = "n" ]
                then
                        return;
                fi
        fi

        doLibPng;
}

checkGD() {
        cd ${CWD};
        NUM=`cat ${PHP_CONFIGURE} | grep -c '\-\-with\-gd'`
        if [ $NUM = 0 ]
        then
        	return;
        fi

	checkLibJpeg;
	checkLibPng;        
        
	if [ -e /usr/local/lib/libgd.a ]
	then
	
		if [ $USER_INPUT -eq 1 ]; then
			echo -n "GD is already installed. Do you want to build it again? (y/n) :";
			read yesno;
			echo "";
                else
                        if [ "$INPUT_VALUE" = "d" ]; then
                                yesno=y
                        else
                                yesno=$INPUT_VALUE
                        fi
                fi

		if [ "$yesno" = "n" ]
		then
			return;
		fi	
	fi
        
        doGD;        
}

checkMCrypt() {
        cd ${CWD};
        NUM=`cat ${PHP_CONFIGURE} | grep -c '\-\-with\-mcrypt'`
        if [ $NUM = 0 ]
        then
        	return;
        fi
        
	if [ -e /usr/local/lib/libmcrypt.so ]
	then

		if [ $USER_INPUT -eq 1 ]; then
			echo -n "mCrypt is already installed. Do you want to build it again? (y/n) :";
			read yesno;
			echo "";
                else
                        if [ "$INPUT_VALUE" = "d" ]; then
                                yesno=y
                        else
                                yesno=$INPUT_VALUE
                        fi
                fi
		
		if [ "$yesno" = "n" ]
		then
			return;
		fi	
	fi
        
        doMCrypt;
}

checkMHash() {
        cd ${CWD};
        NUM=`cat ${PHP_CONFIGURE} | grep -c '\-\-with\-mhash'`
        if [ $NUM = 0 ]
        then
                return;
        fi

        if [ -e /usr/local/lib/libmhash.so ]
        then
		if [ $USER_INPUT -eq 1 ]; then
	                echo -n "mHash is already installed. Do you want to build it again? (y/n) :";
        	        read yesno;
                	echo "";
                else
                        if [ "$INPUT_VALUE" = "d" ]; then
                                yesno=y
                        else
                                yesno=$INPUT_VALUE
                        fi
                fi

                if [ "$yesno" = "n" ]
                then
                        return;
                fi
        fi

        doMHash;
}

checkZZip() {
        cd ${CWD};

        NUM=`cat ${PHP_CONFIGURE} | grep -c '\-\-with\-zip'`
        if [ $NUM = 0 ]
        then
                return;
        fi

        if [ -e /usr/local/lib/libzzip.so ]
        then
		if [ $USER_INPUT -eq 1 ]; then
	                echo -n "zZip is already installed. Do you want to build it again? (y/n) :";
        	        read yesno;
                	echo "";
                else
                        if [ "$INPUT_VALUE" = "d" ]; then
                                yesno=y
                        else
                                yesno=$INPUT_VALUE
                        fi
                fi

                if [ "$yesno" = "n" ]
                then
                        return;
                fi
        fi

        doZZip;
}


####################################################

doPhp() {
	checkCURL
	checkGD
	checkMCrypt
	checkMHash
	checkZZip
	cd $CWD;
	FILE=${CWD}/php-${PHP_VER}.tar.gz
	checkFile $FILE
	echo "Extracting ...";
	tar xzf $FILE
	echo "Done.";

	if [ "$APPLY_MAIL_HEADER_PATCH" = "1" ]; then
		patch -p0 < $MAIL_HEADER_FILE
	fi

	cd php-${PHP_VER}

	#make sure we have the sendmail link
	ln -sf exim /usr/sbin/sendmail

	#some reports of missing -lltdl, problem found to be simple missing link
	if [ -e /usr/lib64 ]; then
		if [ ! -e /usr/lib64/libltdl.so ]; then
			ln -s libltdl.so.3 /usr/lib64/libltdl.so
		fi
	else
		if [ ! -e /usr/lib/libltdl.so ]; then
			ln -s libltdl.so.3 /usr/lib/libltdl.so
		fi
	fi
	
	if [ "$OS" = "FreeBSD" ] && [ "$OS_VER" = "6.1" ]; then
		if [ ! -e /lib/libm.so.3 ]; then
			ln -s libm.so.4 /lib/libm.so.3
		fi
		if [ ! -e /lib/libz.so.2 ]; then
			ln -s libz.so.3 /lib/libz.so.2
		fi
	fi

	#fix pear error in 4.4.2 -> remove after 4.4.3 is out
	#perl -pi -e 's/install-pear.php -d/install-pear.php --force -d/' pear/Makefile.frag

	#fix pear error in 4.4.5 -> remove after 4.4.6 is out
	if [ "$PHP_VER" = "4.4.5" ];
	then
		echo "patching pear register_globals bug...";
		cd ext/session
		wget -O php-pear.patch http://files.directadmin.com/services/customapache/php-pear.patch
		patch -p0 < php-pear.patch
		cd ../..
	fi

	
	echo "Configuring php-${PHP_VER}...";

	CONF_FILE=${CWD}/${PHP_CONFIGURE};
	if [ "$1" = "2" ]; then
		CONF_FILE=${CWD}/${PHP_CONFIGURE_AP2};
	fi

	#we need to make sure that the mysql path is set.
	MYSQL_H="";
	if [ -e /usr/include/mysql/mysql.h ]; then
		MYSQL_H=/usr
	fi
	if [ "$MYSQL_H" = "" ]; then
		if [ -e /usr/local/mysql/include/mysql.h ]; then
			MYSQL_H=/usr/local/mysql
		fi
	fi

	if [ "$MYSQL_H" != "" ]; then
		STR="perl -pi -e 's#with-mysql\s#with-mysql=${MYSQL_H} #' $CONF_FILE";
		eval $STR;
	fi

	#if this is a 64bit system,make sure libmysqlclient is correct.
	if [ -e /usr/lib64/libmysqlclient.so ] && [ ! -e /usr/lib/libmysqlclient.so ]; then
		ln -s /usr/lib64/libmysqlclient.so /usr/lib/libmysqlclient.so
	fi

	#${CWD}/${PHP_CONFIGURE};
	$CONF_FILE
	if [ $? -ne 0 ]
	then
		echo -e "\n*** There was an error while trying to configure php. Check the configure.php file\n";
		exit 1;
	fi

	echo "Done Configuration.";

	# Multiple symbol fix -- replace multiple -lz with just one. R.D.
	perl -pi.bak -e '/^EXTRA_LIBS/ && s/\s+\-lz\b//g && s/$/ -lz/;' Makefile

	while
	echo "Trying to make php..."
	do
	{
		C_INCLUDE_PATH=/usr/kerberos/include make

		if [ $? -ne 0 ]
		then
			if [ $USER_INPUT -eq 1 ]; then
				echo -n -e "\n*** The make has failed, do you want to try to make again? (y,n): ";
				read yesno;
				echo "";
	                else
        	                if [ "$INPUT_VALUE" = "d" ]; then
                	                yesno=n
                        	else
                                	yesno=$INPUT_VALUE
	                        fi
        	        fi

			if [ "$yesno" = "n" ]
			then	
				exit 0;
			fi
		else
			break;
		fi
	}
	done
	echo "Make Complete";

	#change the pear settings to remove the -n option.
	#the default memory limit was messing this up.
	/usr/bin/perl -pi -e 's/PEAR_INSTALL_FLAGS = .*/PEAR_INSTALL_FLAGS = -dshort_open_tag=0 -dsafe_mode=0/' Makefile

	#this was moved here, again for pear
        echo "Copying php.ini..";
        if [ ! -e $PHP_INI ]
        then
                cp ./php.ini-dist $PHP_INI;
		echo "Enabling register_globals...";
		/usr/bin/perl -pi -e 's/^register_globals = Off/register_globals = On/' $PHP_INI
        else
                echo "$PHP_INI already exists, skipping.";
        fi

	echo "Increasing memory limit to 20M...";
	/usr/bin/perl -pi -e 's/memory_limit = 8M/memory_limit = 20M/' $PHP_INI


	while
	echo "Installing php...";
	do
	{
		make install

		if [ $? -ne 0 ]
		then
			if [ $USER_INPUT -eq 1 ]; then
	                        echo -e "\n*** The install has failed, do you want to try to install it again? (y,n): ";
        	                read yesno;
                	        echo "";
			else
                                if [ "$INPUT_VALUE" = "d" ]; then
                                        yesno=n
                                else
                                        yesno=$INPUT_VALUE
                                fi
			fi

                        if [ "$yesno" = "n" ]
                        then
                                exit 0;
                        fi
                else
                        break;
                fi
	}
	done;
	

	echo "PHP Installed.";

	cd $CWD;
}

####################################################

doModFrontpage() {
	cd $CWD;
	FILE=${CWD}/mod_frontpage-${FRONTPAGE_VER}.tar.gz
	checkFile $FILE
	echo "Extracting ...";
	tar xzf $FILE
	echo "Done.";

	cd mod_frontpage-${FRONTPAGE_VER}
	echo "Configuring mod_frontpage-${FRONTPAGE_VER}...";
	/usr/bin/perl -pi -e 's/$thechoice="\/usr\/local\/sbin\/httpd";/$thechoice="\/usr\/sbin\/httpd";\n\$user="apache";\n/' Makefile.PL;
	/usr/bin/perl Makefile.PL;	
		
	make clean

	echo "Done. Making mod_frontpage-${FRONTPAGE_VER}...";
	while
	echo "Trying to make mod_frontpage..."
	do
	{
		make

		if [ $? -ne 0 ]
		then
			if [ $USER_INPUT -eq 1 ]; then
				echo -e "\n*** The make has failed, do you want to try to make again? (y,n): ";
				read yesno;
				echo "";
			else
                                if [ "$INPUT_VALUE" = "d" ]; then
                                        yesno=n
                                else
                                        yesno=$INPUT_VALUE
                                fi
                        fi


			if [ "$yesno" = "n" ]
			then	
				exit 0;
			fi
		else
			break;
		fi
	}
	done
	echo "Make complete";

	echo "Installing mod_frontpage-${FRONTPAGE_VER}...";
	make install
	echo "Done mod_frontpage.";

	cd $CWD
}

####################################################

doFrontpageExt() {

	cd $CWD;
	FILE=${CWD}/${FRONTPAGE_EXT};
	checkFile $FILE;	
	echo "Extracting Frontpage Extensions...";
	tar xzf $FILE -C ${FRONTPAGE_PATH}
	echo "Setting the suidkey...";
	FPDIR=${FRONTPAGE_PATH}/frontpage
	FPFILE=${FPDIR}/version5.0/apache-fp/suidkey
	ps ea | tail -10 | sed -e 's/ //g' | cut -c10-137 > ${FPFILE}
	chown root ${FPFILE}
	chmod 600 ${FPFILE}
	${FPDIR}/version5.0/set_default_perms.sh

	cp -R /usr/local/frontpage/version5.0/exes/_vti_bin/images /usr/local/frontpage/version5.0/exes/_vti_bin/_vti_adm

	echo "Creating we80.cnf...";	
	FPFILE=${FPDIR}/we80.cnf

	if [ -e $FPDIR ]
	then
		if [ ! -e $FPFILE ]
		then
			echo "vti_encoding:SR|utf8-nl" > $FPFILE;
			echo "frontpageroot:/usr/local/frontpage/version5.0" >> $FPFILE;
			echo "authoring:enabled" >> $FPFILE;
			echo "servertype:apache-fp" >> $FPFILE;
			echo "serverconfig:${HTTPD_CONF}" >> $FPFILE;
			echo "SMTPHost:127.0.0.1" >> $FPFILE;
			echo "SendmailCommand:/usr/sbin/sendmail" >> $FPFILE;
			echo "MailSender:webmaster@" >> $FPFILE;
		fi
	fi
	echo "Done.  Frontpage Extension install complete.";

}

####################################################

doModSSL() {
	
	cd $CWD;
	FILE=${CWD}/mod_ssl-${MODSSL_VER}-${APACHE_VER}.tar.gz
	checkFile $FILE;
	echo "Extracting $FILE...";
	
	tar xzf $FILE
	cd mod_ssl-${MODSSL_VER}-${APACHE_VER}
	
	echo "Configuring mod_ssl-${MODSSL_VER}-${APACHE_VER}...";

        if [ $OS = "FreeBSD" ]; then
                OPTIM="-DHARD_SERVER_LIMIT=32768 -DFD_SETSIZE=32768 " \
                EAPI_MM="SYSTEM" \
                SSL_BASE="/usr" \
                PORTOBJFORMAT=elf \
                ${CWD}/${APACHE_SSL_CONFIGURE};
        else
                ${CWD}/${APACHE_SSL_CONFIGURE};
        fi

	if [ $? -ne 0 ]
	then
		echo -e "\n*** There was an error while trying to configure apache+mod_ssl. Check the ${APACHE_SSL_CONFIGURE} file\n";
		exit 1;
	fi

	echo "Done Configuration.";

	cd $CWD;
}

####################################################

backupHttp() {
	echo "Backing up certificate and key, and turning off httpd for DirectAdmins's check.";

	if [ -e ${HTTPDCONF}/ssl.crt/server.crt ]
	then
		cp -f ${HTTPDCONF}/ssl.crt/server.crt ${HTTPDCONF}/ssl.crt/server.crt.backup
	fi
	if [ -e ${HTTPDCONF}/ssl.key/server.key ]
	then
		cp -f ${HTTPDCONF}/ssl.key/server.key ${HTTPDCONF}/ssl.key/server.key.backup
	fi
	if [ -e ${HTTPD_CONF} ]
	then
		cp -f ${HTTPD_CONF} ${HTTPD_CONF}.backup
	fi
	
	#turn off httpd service checking
	if [ -e $SERVICES ]
	then
		/usr/bin/perl -pi -e 's/httpd=ON/httpd=OFF/' ${SERVICES};
	fi
	
}

restoreHttp() {
	echo "Restoring certificate and key, and turning on httpd for DirectAdmins's check.";

	if [ -e ${HTTPDCONF}/ssl.crt/server.crt.backup ]
	then
		cp -f ${HTTPDCONF}/ssl.crt/server.crt.backup ${HTTPDCONF}/ssl.crt/server.crt
	fi
	if [ -e ${HTTPDCONF}/ssl.key/server.key.backup ]
	then
		cp -f ${HTTPDCONF}/ssl.key/server.key.backup ${HTTPDCONF}/ssl.key/server.key
	fi
	if [ -e ${HTTPDCONF}/httpd.conf.backup ]
	then
		cp -f ${HTTPDCONF}/httpd.conf.backup ${HTTPDCONF}/httpd.conf
	fi

	#turn on httpd service checking
	if [ -e $SERVICES ]
	then
		/usr/bin/perl -pi -e 's/httpd=OFF/httpd=ON/' ${SERVICES};
	fi
}

####################################################

checkRPMS() {
	if [ $OS = "FreeBSD" ]; then
		return;
	fi

	if [ -e $DEBIAN_VERSION ]; then
		return;
	fi

	echo "Removing all apache related rpms...";
	rpm -e --nodeps mod_auth_pgsql 2> /dev/null
	rpm -e --nodeps mod_python 2> /dev/null
	rpm -e --nodeps mod_auth_mysql 2> /dev/null
	rpm -e --nodeps mod_auth_any 2> /dev/null
	rpm -e --nodeps mod_dav 2> /dev/null
	rpm -e --nodeps mod_ssl 2> /dev/null
	rpm -e --nodeps mod_perl 2> /dev/null
	rpm -e --nodeps mod_fpse 2> /dev/null
	rpm -e --nodeps apache-fp 2> /dev/null
	rpm -e --nodeps apache-fp-devel 2> /dev/null
	rpm -e --nodeps apache-manual 2> /dev/null
	rpm -e --nodeps apacheconf 2> /dev/null
	rpm -e --nodeps apache-devel 2> /dev/null
	rpm -e --nodeps apache 2> /dev/null
	rpm -e --nodeps httpd 2> /dev/null
	rpm -e --nodeps httpd-devel 2> /dev/null
	rpm -e --nodeps php 2> /dev/null
	echo "All apache related rpms have been removed.";
}

####################################################

addUserGroup() {

	if [ $OS = "FreeBSD" ]; then
		PW=/usr/sbin/pw
		if ! /usr/bin/grep -q "^${2}:" < /etc/group; then
			$PW groupadd ${2}
		fi
		if ! /usr/bin/id ${1} > /dev/null; then
			$PW useradd -g ${2} -n ${1}
		fi
	elif [ -e $DEBIAN_VERSION ]; then
		if ! /usr/bin/id ${1} > /dev/null; then
			adduser --system --group --no-create-home \
		            --disabled-login --force-badname ${1} > /dev/null
		fi
	else
		if ! /usr/bin/id ${1} > /dev/null; then				
			/usr/sbin/useradd ${1} -r
		fi
	fi
}

####################################################

set64() {

	if [ ! -d /usr/lib64 ]; then
		return;
	fi

	if [ ! -e /usr/lib/libssl.so ]; then
		ln -s /usr/lib64/libssl.so /usr/lib/libssl.so
	fi
	if [ ! -e /usr/lib/libidn.so ]; then
		ln -s /usr/lib64/libidn.so /usr/lib/libidn.so
	fi
}

####################################################

doApache() {

	set64;

	addUserGroup apache apache
	
	#this bit is to increase the socket limit
	if [ -e /usr/include/bits/typesizes.h ]; then
		perl -pi -e 's/__FD_SETSIZE.*1024/__FD_SETSIZE 32768/' /usr/include/bits/typesizes.h
	fi
	#same thing, for freebsd
	if [ -e /usr/include/sys/select.h ]; then
		perl -pi -e 's/FD_SETSIZE.*1024U/FD_SETSIZE 32768U/' /usr/include/sys/select.h
	fi

	perl -pi -e 's#^LoadModule frontpage_module#\#LoadModule frontpage_module#' /etc/httpd/conf/httpd.conf > /dev/null 2>&1
	backupHttp;
	
	cd $CWD;
	FILE=${CWD}/apache_${APACHE_VER}.tar.gz
	checkFile $FILE;
	
	#removing old apache dir, because the patch may get applied twice (might confuse the user)
	rm -rf ${CWD}/apache_${APACHE_VER};
	
	echo "Extracting $FILE...";
	
	tar xzf $FILE
	cd apache_${APACHE_VER}
	
	echo "Done. Applying patches...";
	
	if [ $OS = "FreeBSD" ]; then
		cp ../$MOD_FRONTPAGE .
		patch -p0 < ../$FP_PATCH0
	else
		patch -p0 < ../fp-patch-apache_1.3.22
		patch -p0 < ../fp-patch-suexec
	fi
	
	echo "Increasing hard limit to 32768...";
	/usr/bin/perl -pi -e 's/^#define HARD_SERVER_LIMIT 256/#define HARD_SERVER_LIMIT 32768/' ./src/include/httpd.h;
	/usr/bin/perl -pi -e 's/\/\* Majority of os/#undef FD_SETSIZE\n#define FD_SETSIZE 32768\n\n\/\* Majority of os/' ./src/include/ap_config.h
	/usr/bin/perl -pi -e 's/r->connection->keepalive > 0/r->connection->keepalive != -1/' ./src/main/http_request.c

	if [ $OS = "FreeBSD" ]; then
		# do nothing
		echo "";
	else
		/usr/bin/perl -pi -e 's/__FD_SETSIZE\s1024/__FD_SETSIZE\t32768/' /usr/include/bits/types.h
		echo "131072" > /proc/sys/fs/file-max
		
	fi

	if [ "$1" = "fake" ]; then
                ./configure \
                        --prefix=/etc/httpd \
                        --exec-prefix=/etc/httpd \
                        --bindir=/usr/bin \
                        --sbindir=/usr/sbin \
                        --sysconfdir=/etc/httpd/conf \
			--enable-module=all \
			--enable-shared=max \
                        --includedir=/usr/include/apache \
			--libexecdir=/usr/lib/apache \
                        --datadir=/var/www \
                        --localstatedir=/var \
                        --runtimedir=/var/run \
                        --logfiledir=/var/log/httpd \
                        --proxycachedir=/var/cache/httpd \
			--disable-module=auth_db --disable-module=auth_dbm
	else

		echo "Setting up mod_ssl...";
	
		#configure apache through mod_ssl
		doModSSL;
	
		#cd ${CWD}/apache_${APACHE_VER}/src/modules;
		#ln -sf ../../../mod_frontpage-${FRONTPAGE_VER} frontpage
	fi

	cd ${CWD}/apache_${APACHE_VER};
	
	if [ $OS = "FreeBSD" ]; then
		patch -p0 < ../$FP_PATCH1
	fi

	while
	echo "Trying to make apache..."
	do
	{
		C_INCLUDE_PATH=/usr/kerberos/include make

		if [ $? -ne 0 ]
		then
			if [ $USER_INPUT -eq 1 ]; then
				echo -e "\n*** The make has failed, do you want to try to make again? (y,n): ";
				read yesno;
				echo "";
                        else
                                if [ "$INPUT_VALUE" = "d" ]; then
                                        yesno=n
                                else
                                        yesno=$INPUT_VALUE
                                fi
                        fi

			if [ "$yesno" = "n" ]
			then	
				exit 0;
			fi
		else
			break;
		fi
	}
	done
	echo "Make complete";
	
	checkRPMS;
	
	echo "Installing Apache...";
	make install
	
	make certificate TYPE=dummy;
	cp -f ./conf/ssl.crt/server.crt ${HTTPDCONF}/ssl.crt/server.crt
	cp -f ./conf/ssl.key/server.key ${HTTPDCONF}/ssl.key/server.key

	echo "Done installing Apache+Mod_SSL+Frontpage.";
		
	cd $CWD

	restoreHttp;
	
	#remove the auth modules from the httpd.conf
	/usr/bin/perl -pi -e 's/^LoadModule db_auth_module/#LoadModule db_auth_module/' ${HTTPD_CONF};
	/usr/bin/perl -pi -e 's/^AddModule mod_auth_db.c/#AddModule mod_auth_db.c/' ${HTTPD_CONF};
	
	ln -sf ../../var/log/httpd /etc/httpd/logs
	ln -sf ../../usr/lib/apache /etc/httpd/modules 

	#changed nov 24, 2006 for hardened log security (was just 755)
	chmod 711 /var/log/httpd
	mkdir -p /var/log/httpd/domains
	chmod 710 /var/log/httpd/domains
	chown root:nobody /var/log/httpd/domains

	if [ $OS = "FreeBSD" ]
	then
		cp -f ${CWD}/httpd_freebsd /usr/local/etc/rc.d/httpd
		chmod 755 /usr/local/etc/rc.d/httpd
	elif [ -e /etc/debian_version ]; then
		cp -f ${CWD}/httpd_debian /etc/init.d/httpd
                chmod 755 /etc/init.d/httpd
		update-rc.d httpd defaults
	else
		cp -f ${CWD}/httpd /etc/rc.d/init.d/httpd
		chmod 755 /etc/rc.d/init.d/httpd
		/sbin/chkconfig httpd on
	fi

	if [ ! -e /etc/mime.types ]
	then
		cp ${CWD}/mime.types /etc/mime.types
	fi
	
	mkdir -p /var/www/html

	if [ ! -e /var/www/html/index.html ]
	then
        	if [ -e /var/www/html/index.html.en ]
	        then
        	        cp -f /var/www/html/index.html.en /var/www/html/index.html
	        else
        	        echo "<html>Apache is functioning normally</html>" > /var/www/html/index.html
	        fi
	fi

	if [ ! -e /var/www/html/404.shtml ]
	then
		wget -O /var/www/html/404.shtml $WEBPATH/404.shtml.txt
		touch /var/www/html/favicon.ico
	fi

	#echo "<?phpinfo();?>" > /var/www/html/info.php

        #log rotate
        if [ ! -e /etc/logrotate.d/apache ] && [ $OS != "FreeBSD" ]
        then
                wget http://files.directadmin.com/services/customapache/apache.logrotate -O /etc/logrotate.d/apache
        fi

	COUNT=0;
	if [ -e /etc/logrotate.d/apache ];
	then
		COUNT=`grep -c suexec_log /etc/logrotate.d/apache`
	fi
	if [ -e /etc/logrotate.d/apache ] && [ "$OS" != "FreeBSD" ] && [ "$COUNT" -eq 0 ]
	then
		wget http://files.directadmin.com/services/customapache/apache.logrotate -O /etc/logrotate.d/apache
	fi


	#this is an addition for jailing
	#if the jailing patch was previously installed, repatch.
	if [ -e ${CWD}/jail/build ]; then

		echo "*****";
		echo "  Repatching apache with jailed suexec";
		echo "*****";

		${CWD}/jail/build suexec
	fi
	

}	

####################################################

doGD() {
	
	cd $CWD;
	FILE=${CWD}/gd-${GD_VER}.tar.gz
	checkFile $FILE
	echo "Extracting ...";
	tar xzf $FILE
	echo "Done.";
	cd gd-${GD_VER}
	echo "Configuring gd-${GD_VER}...";

	./configure --with-png=/usr/local --with-jpeg=/usr/local --without-freetype --without-x

	echo "Done. Making gd-${GD_VER}...";
	
	
	while
	echo "Trying to make gd..."
	do
	{
		make

		if [ $? -ne 0 ]
		then
			if [ $USER_INPUT -eq 1 ]; then
				echo -e "\n*** The make has failed, do you want to try to make again? (y,n): ";
				read yesno;
				echo "";
                        else
                                if [ "$INPUT_VALUE" = "d" ]; then
                                        yesno=n
                                else
                                        yesno=$INPUT_VALUE
                                fi
                        fi

			if [ "$yesno" = "n" ]
			then	
				exit 0;
			fi
		else
			break;
		fi
	}
	done
	echo "Make complete";
	
	echo "Installing gd-${GD_VER}...";
	make install
	echo "Done gd.";

	cd $CWD
}

####################################################

doCURL() {

	cd $CWD;
	FILE=${CWD}/curl-${CURL_VER}.tar.gz
	checkFile $FILE
	echo "Extracting ...";
	tar xzf $FILE
	echo "Done.";
	chmod -R 755 curl-${CURL_VER}
	cd curl-${CURL_VER}
	echo "Configuring curl-${CURL_VER}...";
	./configure --disable-file
	/usr/bin/perl -pi -e 's/\#define HAVE_OPENSSL_ENGINE_H 1/\/\/\#define HAVE_OPENSSL_ENGINE_H 0/' ./lib/config.h;
	echo "Done. Making curl-${CURL_VER}...";
	while
	echo "Trying to make cURL..."
	do
	{
		make CPPFLAGS=-I/usr/kerberos/include

		if [ $? -ne 0 ]
		then
			if [ $USER_INPUT -eq 1 ]; then
				echo -e "\n*** The make has failed, do you want to try to make again? (y,n): ";
				read yesno;
				echo "";
                        else
                                if [ "$INPUT_VALUE" = "d" ]; then
                                        yesno=n
                                else
                                        yesno=$INPUT_VALUE
                                fi
                        fi

			if [ "$yesno" = "n" ]
			then	
				exit 0;
			fi
		else
			break;
		fi
	}
	done
	echo "Make complete";
	echo "Installing curl-${CURL_VER}...";
	make install
	echo "Done curl.";

	cd $CWD
}

####################################################

doMCrypt() {
	
	cd $CWD;
	FILE=${CWD}/libmcrypt-${MCRYPT_VER}.tar.gz
	checkFile $FILE
	echo "Extracting ...";
	tar xzf $FILE
	echo "Done.";
	chmod -R 755 libmcrypt-${MCRYPT_VER}

	#added /libltdl
	#cd libmcrypt-${MCRYPT_VER}/libltdl
	#removed it as it broke eveyrthing, mcrypt wasn't installed at all
	cd libmcrypt-${MCRYPT_VER}

	echo "Configuring libmcrypt-${MCRYPT_VER}...";
	./configure --enable-ltdl-install
	echo "Done. Making libmcrypt-${MCRYPT_VER}...";
	while
	echo "Trying to make mCrypt..."
	do
	{
		make

		if [ $? -ne 0 ]
		then
			if [ $USER_INPUT -eq 1 ]; then
				echo -e "\n*** The make has failed, do you want to try to make again? (y,n): ";
				read yesno;
				echo "";
                        else
                                if [ "$INPUT_VALUE" = "d" ]; then
                                        yesno=n
                                else
                                        yesno=$INPUT_VALUE
                                fi
                        fi

			if [ "$yesno" = "n" ]
			then	
				exit 0;
			fi
		else
			break;
		fi
	}
	done
	echo "Make complete";
	echo "Installing mcrypt-${MCRYPT_VER}...";
	make install
	echo "Done mcrypt.";

	cd $CWD
}

####################################################

doMHash() {

        cd $CWD;
        FILE=${CWD}/mhash-${MHASH_VER}.tar.gz
        checkFile $FILE
        echo "Extracting ...";
        tar xzf $FILE
        echo "Done.";
	chmod -R 755 mhash-${MHASH_VER}
        cd mhash-${MHASH_VER}
        echo "Configuring mhash-${MHASH_VER}...";
        ./configure
        echo "Done. Making mhash-${MHASH_VER}...";
        while
        echo "Trying to make mHash..."
        do
        {
                make

                if [ $? -ne 0 ]
                then
			if [ $USER_INPUT -eq 1 ]; then
	                        echo -e "\n*** The make has failed, do you want to try to make again? (y,n): ";
        	                read yesno;
                	        echo "";
                        else
                                if [ "$INPUT_VALUE" = "d" ]; then
                                        yesno=n
                                else
                                        yesno=$INPUT_VALUE
                                fi
                        fi

                        if [ "$yesno" = "n" ]
                        then
                                exit 0;
                        fi
                else
                        break;
                fi
        }
        done
        echo "Make complete";
        echo "Installing mhash-${MHASH_VER}...";
        make install
        echo "Done mhash.";

        cd $CWD
}

####################################################

doZZip() {

        cd $CWD;
        FILE=${CWD}/zziplib-${ZZIP_VER}.tar.gz
        checkFile $FILE
        echo "Extracting ...";
        tar xzf $FILE
        echo "Done.";
        cd zziplib-${ZZIP_VER}

	echo "fixing zzip/zzip.h and zziplib/zzip-conf.h";
	perl -pi -e 's/include <zzip\/conf.h>/include <zzip\/conf.h>\n#include <sys\/types.h>/' zzip/zzip.h
	perl -pi -e 's/\/\* especially win32/#include <sys\/types.h>\n\/\* especially win32/' zziplib/zzip-conf.h

        echo "Configuring zziplib-${ZZIP_VER}...";
        ./configure
        echo "Done. Making zziplib-${ZZIP_VER}...";
        while
        echo "Trying to make zZip..."
        do
        {
                LANG=c make;

                if [ $? -ne 0 ]
                then
			if [ $USER_INPUT -eq 1 ]; then
	                        echo -e "\n*** The make has failed, do you want to try to make again? (y,n): ";
        	                read yesno;
                	        echo "";
                        else
                                if [ "$INPUT_VALUE" = "d" ]; then
                                        yesno=n
                                else
                                        yesno=$INPUT_VALUE
                                fi
                        fi

                        if [ "$yesno" = "n" ]
                        then
                                exit 0;
                        fi
                else
                        break;
                fi
        }
        done
        echo "Make complete";
        echo "Installing zziplib-${ZZIP_VER}...";
        LANG=c make install;
        echo "Done zZip";

        cd $CWD
}

####################################################

doModPerl() {
	cd $CWD;
	FILE=${CWD}/${MODPERL_FILE}
	checkFile $FILE
	echo "Extracting ...";
	tar xzf $FILE
	echo "Done.";
	cd ${MODPERL_DIR}
	echo "Configuring ${MODPERL_DIR}...";
	perl Makefile.PL USE_APXS=1 WITH_APXS=/usr/sbin/apxs EVERYTHING=1
	echo "Done. Making ${MODPERL_DIR}...";
	while
	echo "Trying to make mod_perl..."
	do
	{
		make

		if [ $? -ne 0 ]
		then
			if [ $USER_INPUT -eq 1 ]; then
				echo -e "\n*** The make has failed, do you want to try to make again? (y,n): ";
				read yesno;
				echo "";
                        else
                                if [ "$INPUT_VALUE" = "d" ]; then
                                        yesno=n
                                else
                                        yesno=$INPUT_VALUE
                                fi
                        fi

			if [ "$yesno" = "n" ]
			then	
				return;
			fi
		else
			break;
		fi
	}
	done
	echo "Make complete";
	echo "Installing ${MODPERL_DIR}...";
	make install
	echo "Done mod_perl.";


	#This code is to remove mod_perl from freebsd
	if [ "$OS" = "FreeBSD" ]; then
		perl -pi -e 's/^AddModule mod_perl.c/\#AddModule mod_perl.c/' /etc/httpd/conf/httpd.conf
		perl -pi -e 's/^AddModule mod_perl.c/\#AddModule mod_perl.c/' /usr/local/directadmin/data/templates/httpd.conf
	fi

	cd $CWD
}

doModPerl2() {
        cd $CWD;
        FILE=${CWD}/${MODPERL2_FILE}
        checkFile $FILE
        echo "Extracting ...";
        tar xzf $FILE
        echo "Done.";
        cd ${MODPERL2_DIR}
	
	echo "Nuking previous mod_perl install (or configure will fail)...";
	rm -f /usr/lib/perl5/site_perl/*/i386-linux-thread-multi/Apache2.pm 2>/dev/null
	rm -rf /usr/lib/perl5/site_perl/*/i386-linux-thread-multi/Apache2 2>/dev/null

        echo "Configuring ${MODPERL2_DIR}...";
	perl Makefile.PL MP_APXS=/usr/sbin/apxs MP_APR_CONFIG=/usr/bin/apr-1-config MP_APU_CONFIG=/usr/bin/apu-1-config;
        echo "Done. Making ${MODPERL2_DIR}...";
        while
        echo "Trying to make mod_perl-2.0..."
        do
        {
                make

                if [ $? -ne 0 ]
                then
			if [ $USER_INPUT -eq 1 ]; then
	                        echo -e "\n*** The make has failed, do you want to try to make again? (y,n): ";
        	                read yesno;
                	        echo "";
                        else
                                if [ "$INPUT_VALUE" = "d" ]; then
                                        yesno=n
                                else
                                        yesno=$INPUT_VALUE
                                fi
                        fi

                        if [ "$yesno" = "n" ]
                        then
                                return;
                        fi
                else
                        break;
                fi
        }
        done
        echo "Make complete";
        echo "Installing ${MODPERL2_DIR}...";
        make install
        echo "Done ${MODPERL2_DIR}.";

        cd $CWD
}


####################################################

doWebalizer() {
	
	PREFIX=/usr
	if [ $OS = "FreeBSD" ]; then
		PREFIX=/usr/local
	fi

	if [ -e ${PREFIX}/bin/webalizer ]; then
		return;
	fi

	

        cd $CWD;
        getFile $WEBALIZER_FILE
        tar xzf $WEBALIZER_FILE
        cd $WEBALIZER

        ./configure --prefix=${PREFIX} --with-png=/usr/local/lib --with-gdlib=/usr/local/lib --with-gd=/usr/local/include --enable-dns --with-dblib --with-db --with-z-inc --with-zlib 
	
	#/usr/bin/perl -pi -e 's/^LIBS   = -lgd -lpng -lz -lm/LIBS   = -lgd -lpng -lz -lm -liconv/' Makefile

        while
        echo "Trying to make webalizer..."
        do
        {
                make

                if [ $? -ne 0 ]
                then
			if [ $USER_INPUT -eq 1 ]; then
	                        echo -n -e "\n*** The make has failed, do you want to try to make again? (y,n): ";
        	                read yesno;
                	        echo "";
                        else
                                if [ "$INPUT_VALUE" = "d" ]; then
                                        yesno=n
                                else
                                        yesno=$INPUT_VALUE
                                fi
                        fi

                        if [ "$yesno" = "n" ]
                        then
                                return;
                        fi
                else
                        break;
                fi
        }
        done

        make install

	if [ -e /etc/webalizer.conf ]; then
		mv -f /etc/webalizer.conf /etc/webalizer.conf.moved 2> /dev/null > /dev/null
	fi
}

####################################################

doAll() {
	FORCE=1;
	
	#doApache "fake";	
	#doModFrontpage;
	doApache;
	#doModFrontpage;

	#Sorry debian, but zzip has far too many problems
	#one version works on one instance of 3.1, but not another instance.
	#another version work in the opposite manner. No solution. Removed.
	if [ -e /etc/debian_version ]; then
		mv -f $PHP_CONFIGURE ${PHP_CONFIGURE}.nozip
		cat ${PHP_CONFIGURE}.nozip | grep -v zip > $PHP_CONFIGURE
		chmod 755 $PHP_CONFIGURE

		mv -f $PHP_CONFIGURE_AP2 ${PHP_CONFIGURE_AP2}.nozip
		cat ${PHP_CONFIGURE_AP2}.nozip | grep -v zip > $PHP_CONFIGURE_AP2
		chmod 755 $PHP_CONFIGURE_AP2
	fi

	doPhp;
	doModPerl;
	#doModFrontpage;
	doFrontpageExt;
	doWebalizer;

	chown -R root:$ROOT_GRP /usr/local/directadmin/customapache

	echo -e "\n\n\n";
	echo "*************************************";
	echo "*                                   *";
	echo "*   All parts have been installed   *";
	echo "*                                   *";
	echo "*************************************";
	echo "";
	if [ $OS = "FreeBSD" ]; then
		echo "Type: /usr/local/etc/rc.d/httpd restart";
	elif [ -e $DEBIAN_VERSION ]; then
		echo "Type: /etc/init.d/httpd restart";
	else
		echo "Type: /sbin/service httpd restart";
	fi
}

####################################################

doClean() {
	cd $CWD
	rm -rf apache_${APACHE_VER};
	rm -rf mod_ssl-${MODSSL_VER}-${APACHE_VER};
	rm -rf php-${PHP_VER};
	rm -rf ${MODPERL_DIR};
	rm -rf curl-${CURL_VER};
	rm -rf gd-${GD_VER};
	rm -rf zlib-${ZLIB_VER};
	rm -rf ${JPEGDIR}
	rm -rf libpng-${PNG_VER};
	rm -rf libmcrypt-${MCRYPT_VER};
	rm -rf mhash-${MHASH_VER};
	rm -rf zziplib-${ZZIP_VER};
	rm -rf mod_frontpage-${FRONTPAGE_VER};
	rm -rf ${ZENDNAME}
	rm -rf ${WEBALIZER}

	rm -rf httpd-${APACHE2_VER}
	rm -rf ${MODPERL2_DIR}

	rm -rf dovecot-${DOVECOT_VER}
	
	echo "All clean!";
}

####################################################

doUpdate() {
	cd $CWD
	if [ $OS = "FreeBSD" ]
	then
		fetch -o ${CWD}/build.new ${WEBPATH}/build
		fetch -o ${CWD}/README ${WEBPATH}/README
	else
		wget ${WEBPATH}/build -O ${CWD}/build.new
		wget ${WEBPATH}/README -O ${CWD}/README
	fi
	
	mv -f build.new build
	chmod 755 build
	
	./build update_data

}

####################################################

getFile() {
	if [ ! -e $1 ]
	then
		echo -e "Downloading\t\t$1...";
		if [ $OS = "FreeBSD" ]; then
			fetch ${WEBPATH}/${1};
		else
			wget ${WEBPATH}/${1} -O ${CWD}/${1};
		fi
		if [ ! -e $1 ]
		then
			echo "Fileserver is down, using the backup file server..";
			if [ $OS = "FreeBSD" ]; then
				fetch ${WEBPATH_BACKUP}/${1};
			else
				wget ${WEBPATH_BACKUP}/${1} -O ${CWD}/${1};
			fi
		fi
		
	else
		echo -e "File already exists:\t${1}";
	fi
	
}

doUpdateData2() {
	cd $CWD
	getFile httpd-${APACHE2_VER}.tar.gz
	getFile $APACHE2_CONFIGURE
	chmod 755 $APACHE2_CONFIGURE
	getFile $PHP_CONFIGURE_AP2
	chmod 755 $PHP_CONFIGURE_AP2
	getFile httpd_2
	getFile httpd_2_freebsd
	getFile httpd_2_debian
	getFile httpd.conf
	getFile ssl.conf
	rm -f $MODPERL2_FILE 2>/dev/null
	getFile $MODPERL2_FILE
	getFile $FP_PATCH_AP2
}

updateDovecot() {
	cd $CWD
	getFile dovecot-${DOVECOT_VER}.tar.gz
	getFile dovecot.boot
	getFile dovecot.boot.freebsd
	getFile dovecot.boot.debian
	getFile dovecot.conf
	getFile exim.conf.dovecot.patch
}

doUpdateData() {
	cd $CWD
	getFile apache_${APACHE_VER}.tar.gz
	getFile $APACHE_SSL_CONFIGURE
	chmod 755 configure.apache_ssl
        str="perl -pi -e 's/1.3.39/$APACHE_VER/' $APACHE_SSL_CONFIGURE"
        eval $str;
        str="perl -pi -e 's/1.3.37/$APACHE_VER/' $APACHE_SSL_CONFIGURE"
        eval $str;
        str="perl -pi -e 's/1.3.36/$APACHE_VER/' $APACHE_SSL_CONFIGURE"
        eval $str;
        str="perl -pi -e 's/1.3.35/$APACHE_VER/' $APACHE_SSL_CONFIGURE"
        eval $str;
	str="perl -pi -e 's/1.3.34/$APACHE_VER/' $APACHE_SSL_CONFIGURE"
	eval $str;
        str="perl -pi -e 's/1.3.33/$APACHE_VER/' $APACHE_SSL_CONFIGURE"
        eval $str;
	str="perl -pi -e 's/1.3.32/$APACHE_VER/' $APACHE_SSL_CONFIGURE"
	eval $str;
	str="perl -pi -e 's/1.3.31/$APACHE_VER/' $APACHE_SSL_CONFIGURE"
	eval $str;
	str="perl -pi -e 's/1.3.29/$APACHE_VER/' $APACHE_SSL_CONFIGURE"
	eval $str;
	str="perl -pi -e 's/1.3.28/$APACHE_VER/' $APACHE_SSL_CONFIGURE"
	eval $str;
	str="perl -pi -e 's/1.3.27/$APACHE_VER/' $APACHE_SSL_CONFIGURE"
        eval $str;
	getFile $PHP_CONFIGURE
	chmod 755 $PHP_CONFIGURE
	getFile $MOD_FRONTPAGE
	getFile $FP_PATCH0
	getFile $FP_PATCH1
	getFile fp-patch-apache_1.3.22
	getFile fp-patch-suexec
	getFile httpd
	getFile httpd_freebsd
	getFile httpd_debian
	getFile mime.types
	#because they changed versions
	rm -f $MODPERL_FILE 2>/dev/null
	getFile $MODPERL_FILE
	getFile mod_ssl-${MODSSL_VER}-${APACHE_VER}.tar.gz
	getFile curl-${CURL_VER}.tar.gz
	getFile gd-${GD_VER}.tar.gz
	getFile libmcrypt-${MCRYPT_VER}.tar.gz
	getFile mhash-${MHASH_VER}.tar.gz
	getFile zziplib-${ZZIP_VER}.tar.gz
	getFile php-${PHP_VER}.tar.gz
	getFile $MAIL_HEADER_FILE
	getFile mod_frontpage-${FRONTPAGE_VER}.tar.gz
	getFile ${FRONTPAGE_EXT}
	getFile ${WEBALIZER_FILE}
}

####################################################

doZend() {

	cd $CWD;
	getFile $ZENDFILE
	tar xzf $ZENDFILE
	cd $ZENDNAME;
	echo "";
	echo -e "Location of php.ini:\n  /usr/local/lib";
	echo "Press return to continue...";
	read bogusdata;
	
	./install.sh
	
	cd $CWD;
}

####################################################

doLibJpeg() {

        cd $CWD;
        getFile $JPEGFILE
        tar xzf $JPEGFILE
        cd $JPEGDIR

	./configure

        while
        echo "Trying to make libjpeg..."
        do
        {
                make CFLAGS=-fpic libjpeg.a

                if [ $? -ne 0 ]
                then
			if [ $USER_INPUT -eq 1 ]; then
	                        echo -n -e "\n*** The make has failed, do you want to try to make again? (y,n): ";
        	                read yesno;
                	        echo "";
                        else
                                if [ "$INPUT_VALUE" = "d" ]; then
                                        yesno=n
                                else
                                        yesno=$INPUT_VALUE
                                fi
                        fi

                        if [ "$yesno" = "n" ]
                        then
                                exit 0;
                        fi
                else
                        break;
                fi
        }
        done

	make install-lib
}

####################################################

doZlib() {

        cd $CWD;
        getFile zlib-${ZLIB_VER}.tar.gz
        tar xzf zlib-${ZLIB_VER}.tar.gz
        cd zlib-${ZLIB_VER}

        ./configure --shared

        while
        echo "Trying to make libz..."
        do
        {
                make

                if [ $? -ne 0 ]
                then
			if [ $USER_INPUT -eq 1 ]; then
	                        echo -e "\n*** The make has failed, do you want to try to make again? (y,n): ";
        	                read yesno;
                	        echo "";
                        else
                                if [ "$INPUT_VALUE" = "d" ]; then
                                        yesno=n
                                else
                                        yesno=$INPUT_VALUE
                                fi
                        fi

                        if [ "$yesno" = "n" ]
                        then
                                exit 0;
                        fi
                else
                        break;
                fi
        }
        done

        make install
}

####################################################

doLibPng() {

        cd $CWD;
        getFile libpng-${PNG_VER}.tar.gz
        tar xzf libpng-${PNG_VER}.tar.gz
        cd libpng-${PNG_VER}

	if [ "$OS" = "FreeBSD" ]; then
		cp scripts/makefile.freebsd makefile
	else
		cp scripts/makefile.linux makefile
	fi

        while
        echo "Trying to make libpng"
        do
        {
                make

                if [ $? -ne 0 ]
                then
			if [ $USER_INPUT -eq 1 ]; then
	                        echo -e "\n*** The make has failed, do you want to try to make again? (y,n): ";
        	                read yesno;
                	        echo "";
                        else
                                if [ "$INPUT_VALUE" = "d" ]; then
                                        yesno=n
                                else
                                        yesno=$INPUT_VALUE
                                fi
                        fi

                        if [ "$yesno" = "n" ]
                        then
                                exit 0;
                        fi
                else
                        break;
                fi
        }
        done

	mkdir -p /usr/local/include/libpng >/dev/null 2>&1

        make install
}

####################################################

convert() {
	#delete old modules
	#backup httpd.conf
	#copy httpd.conf ssl.conf
	#insert all Include lines
	#tokenize the |IP|

	cd $CWD

	rm -f /usr/lib/apache/*
	if [ `grep -c 'Port 80' /etc/httpd/conf/httpd.conf` = 1 ]; then
		cp -f $HTTPD_CONF ${HTTPD_CONF}.1.3.backup
		getFile httpd.conf
		getFile ssl.conf
		getFile httpd_2
		getFile httpd_2_debian
		#getFile httpd_2_freebsd

		if [ ! -e httpd.conf ]; then
			echo "cannot find httpd.conf in customapache directory";
			exit 1;
		fi
		if [ ! -e ssl.conf ]; then
			echo "cannot find ssl.conf in the customapache directory";
			exit 1;
		fi

		cp -f httpd.conf $HTTPD_CONF
		cp -f ssl.conf $HTTPDCONF

	
		#tokenize the IP
		HOSTNAME=`hostname`;
		IP=`grep $HOSTNAME /etc/hosts | awk '{print $1}'`	
		echo "Using $IP for your server IP";

		STR="perl -pi -e 's/\|IP\|/$IP/' $HTTPD_CONF";
		eval $STR;

		#add all the Include lines
		grep "Include /usr/local/directadmin/data/users" ${HTTPD_CONF}.1.3.backup >> ${HTTPD_CONF}

		#just for frontpage's socket
		mkdir -p /var/logs
	
		if [ "$OS" = "FreeBSD" ]; then
			cp -f httpd_2_freebsd /usr/local/etc/rc.d/httpd
			chmod 755 /usr/local/etc/rc.d/httpd
		else
			if [ -e /etc/debian_version ]; then
				cp -f httpd_2_debian /etc/init.d/httpd
			else
				cp -f httpd_2 /etc/init.d/httpd
			fi
			chmod 755 /etc/init.d/httpd
			/sbin/chkconfig httpd on
		fi

		echo "apache_ver=2.0" >> /usr/local/directadmin/conf/directadmin.conf
		echo "action=rewrite&value=ips" >> /usr/local/directadmin/data/task.queue
		echo "action=rewrite&value=httpd" >> /usr/local/directadmin/data/task.queue
		echo "action=directadmin&value=restart" >> /usr/local/directadmin/data/task.queue
	else
		echo "$HTTPD_CONF seems to already be converted";
	fi
}

####################################################

doApache2() {
	addUserGroup apache apache
	backupHttp;
	cd $CWD;
	FILE=${CWD}/httpd-${APACHE2_VER}.tar.gz

	checkFile $FILE;

	echo "Extracting $FILE...";
	tar xzf $FILE
	cd httpd-${APACHE2_VER}
	
	echo "Patching with $FP_PATCH_AP2"
	patch -p0 < ../$FP_PATCH_AP2

	#configure
	echo "Configuring httpd-${APACHE2_VER}";
	${CWD}/${APACHE2_CONFIGURE};
        if [ $? -ne 0 ]
        then
                echo -e "\n*** There was an error while trying to configure Apache 2. Check the ${APACHE2_CONFIGURE} file\n";
                exit 1;
        fi
	echo "Done Configuration.";

	echo "increasing FD_SETSIZE in os/tpf/os.h ..";
	if [ -e ./os/tpf/os.h ]; then
                perl -pi -e 's/FD_SETSIZE.*2048/FD_SETSIZE 32768/' ./os/tpf/os.h
        fi

	while
	echo "Trying to make Apache 2..."
	do
	{
		C_INCLUDE_PATH=/usr/kerberos/include make

		if [ $? -ne 0 ]
		then
			if [ $USER_INPUT -eq 1 ]; then
				echo -e "\n*** The make has failed, do you want to try to make again? (y,n): ";
				read yesno;
				echo "";
                        else
                                if [ "$INPUT_VALUE" = "d" ]; then
                                        yesno=n
                                else
                                        yesno=$INPUT_VALUE
                                fi
                        fi

			if [ "$yesno" = "n" ]
			then
				exit 0;
			fi
		else
			break
		fi
	}
	done
	echo "Make complete";

	checkRPMS;

	echo "Installing Apache...";
	make install

	cd $CWD

	restoreHttp;

	if [ $OS = "FreeBSD" ]
	then
		cp -f ${CWD}/httpd_2_freebsd /usr/local/etc/rc.d/httpd
		chmod 755 /usr/local/etc/rc.d/httpd
	elif [ -e /etc/debian_version ]; then
		cp -f ${CWD}/httpd_2_debian /etc/init.d/httpd
                chmod 755 /etc/init.d/httpd
		update-rc.d httpd defaults
	else
		cp -f ${CWD}/httpd_2 /etc/rc.d/init.d/httpd
		chmod 755 /etc/rc.d/init.d/httpd
		/sbin/chkconfig httpd on
	fi

	if [ ! -e /etc/mime.types ]
	then
		cp ${CWD}/mime.types /etc/mime.types
	fi

	mkdir -p /var/www/html

	if [ ! -e /var/www/html/index.html ]
	then
		if [ -e /var/www/html/index.html.en ]
		then
			cp -f /var/www/html/index.html.en /var/www/html/index.html
		else
			echo "<html>Apache is functioning normally</html>" > /var/www/html/index.html
		fi
	fi
	if [ ! -e /etc/logrotate.d/apache ] && [ $OS != "FreeBSD" ]
	then
		wget http://files.directadmin.com/services/customapache/apache.logrotate -O /etc/logrotate.d/apache
	fi
}

####################################################

modFPap2() {
	MOD_FPC=${FRONTPAGE_PATH}/frontpage/version5.0/apache2/mod_frontpage.c
	MOD_FPCGI=${FRONTPAGE_PATH}/frontpage/version5.0/apache2/mod_fpcgid.c
	MOD_FPLA=${FRONTPAGE_PATH}/frontpage/version5.0/apache2/mod_frontpage.la
	
	checkFile $MOD_FPC
	checkFile $MOD_FPCGI

	mkdir -p /var/logs

	if [ "$OS" = "FreeBSD" ]; then
		/usr/sbin/apxs -c -Wc,-DFREEBSD $MOD_FPC $MOD_FPCGI
	else
		/usr/sbin/apxs -c -Wc,-Dlinux $MOD_FPC $MOD_FPCGI
	fi
	
	/usr/sbin/apxs -i -a -n frontpage $MOD_FPLA
}

####################################################

convertToDovecot() {

        #patch exim.conf
        echo "patching /etc/exim.conf to maildir";
        patch -p0 < $CWD/exim.conf.dovecot.patch

        echo "Adding dovecot=1 to the directadmin.conf ...";

        COUNT=`grep -c -e '^dovecot=1' /usr/local/directadmin/conf/directadmin.conf`
        if [ $COUNT -eq 0 ]; then
                echo "dovecot=1" >> /usr/local/directadmin/conf/directadmin.conf
                echo "dovecot=ON" >> /usr/local/directadmin/data/admin/services.status
        fi

        #uninstall old services and restart exim

        if [ "$OS" = "FreeBSD" ]; then
                /usr/local/etc/rc.d/directadmin restart
                /usr/local/etc/rc.d/exim restart
                perl -pi -e 's/^imap/#imap/' /etc/inetd.conf
                killall -HUP inetd
                /usr/local/etc/rc.d/vm-pop3d stop
                cat /usr/local/etc/rc.d/boot.sh | grep -v vm-pop3d > /usr/local/etc/rc.d/boot.sh.new
		mv -f /usr/local/etc/rc.d/boot.sh /usr/local/etc/rc.d/boot.sh.old
		mv -f /usr/local/etc/rc.d/boot.sh.new /usr/local/etc/rc.d/boot.sh
		chmod 755 /usr/local/etc/rc.d/boot.sh
	elif [ -e /etc/debian_version ]; then
		/etc/init.d/exim restart
		/etc/init.d/directadmin restart
		perl -pi -e 's/^imap/#imap/' /etc/inetd.conf
		killall -HUP inetd
		/etc/init.d/vm-pop3d stop
		chmod 0 /etc/init.d/vm-pop3d
        else
                /sbin/service exim restart
                /sbin/service directadmin restart
                rm -f /etc/xinetd.d/imap
                killall -HUP xinetd
                /sbin/service vm-pop3d stop
                /sbin/chkconfig vm-pop3d off
        fi

	killall -9 vm-pop3d 2> /dev/null

	FILE=/usr/local/directadmin/data/admin/services.status
        cat $FILE | grep -v vm-pop3d > $FILE.new
	mv -f $FILE $FILE.old
	mv -f $FILE.new $FILE
	chown diradmin:diradmin $FILE
	chmod 600 $FILE


	echo "Adding conversion command to the task.queue ...";
	echo "action=convert&value=todovecot" >> /usr/local/directadmin/data/task.queue
	echo "Executing the task.queue cotents now, please be patient ...";
	/usr/local/directadmin/dataskq d


	if [ "$OS" = "FreeBSD" ]; then
		/usr/local/etc/rc.d/dovecot start
	else
		/etc/init.d/dovecot start
	fi


	echo "Done.";

}

doDovecot() {

	echo "Installing dovecot $DOVECOT_VER ...";

	addUserGroup dovecot dovecot

        cd $CWD;
        FILE=${CWD}/dovecot-${DOVECOT_VER}.tar.gz
        checkFile $FILE
        echo "Extracting ...";
        tar xzf $FILE
        echo "Done.";
        cd dovecot-${DOVECOT_VER}

	echo "Patching syslog with LOG_PID ...";

	perl -pi -e 's/LOG_NDELAY/LOG_NDELAY|LOG_PID/' src/auth/main.c
	perl -pi -e 's/LOG_NDELAY/LOG_NDELAY|LOG_PID/' src/imap/main.c
	perl -pi -e 's/LOG_NDELAY/LOG_NDELAY|LOG_PID/' src/master/main.c
	perl -pi -e 's/LOG_NDELAY/LOG_NDELAY|LOG_PID/' src/pop3/main.c

	echo "Configuring dovecot $DOVECOT_VER ...";

	./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --without-gssapi
	if [ $? -ne 0 ]
	then
	echo -e "\n*** There was an error while trying to configure dovecot.\n";
		exit 1;
	fi
	echo "Done Configuration.";

        while
        echo "Trying to make dovecot..."
        do
        {
		make CPPFLAGS=-I/usr/kerberos/include

		#make

                if [ $? -ne 0 ]
                then
                        if [ $USER_INPUT -eq 1 ]; then
                                echo -e "\n*** The make has failed, do you want to try to make again? (y,n): ";
                                read yesno;
                                echo "";
                        else
                                if [ "$INPUT_VALUE" = "d" ]; then
                                        yesno=n
                                else
                                        yesno=$INPUT_VALUE
                                fi
                        fi

                        if [ "$yesno" = "n" ]
                        then
                                exit 0;
                        fi
                else
                        break;
                fi
        }
        done
        echo "Make complete";

	echo "Installing ...";

	make install

	cd $CWD


	#install the boot scripts.

	if [ "$OS" = "FreeBSD" ]; then
		if [ ! -e /usr/local/etc/rc.d/dovecot ]; then
			cp ${CWD}/dovecot.boot.freebsd /usr/local/etc/rc.d/dovecot
			chmod 755 /usr/local/etc/rc.d/dovecot
			echo "./dovecot \$1" >> /usr/local/etc/rc.d/boot.sh
		fi
	elif [ -e /etc/debian_version ]; then
	        if [ ! -e /etc/init.d/dovecot ]; then
                        cp ${CWD}/dovecot.boot.debian /etc/init.d/dovecot
                        chmod 755 /etc/init.d/dovecot
			update-rc.d dovecot defaults
                fi
		if [ ! -e /etc/exim.cert ] && [ ! -e /etc/exim.key ]; then
			ln -s /etc/httpd/conf/ssl.crt/server.crt /etc/exim.cert
			ln -s /etc/httpd/conf/ssl.key/server.key /etc/exim.key
		fi
	else
		if [ ! -e /etc/init.d/dovecot ]; then
			cp ${CWD}/dovecot.boot /etc/init.d/dovecot
			chmod 755 /etc/init.d/dovecot
			/sbin/chkconfig dovecot on
		fi
	fi

	#install the dovecot.conf
	if [ ! -e /etc/dovecot.conf ]; then
		cp -f ${CWD}/dovecot.conf /etc/dovecot.conf
	fi
	if [ "$OS" = "FreeBSD" ]; then
		perl -pi -e 's/passdb shadow/passdb passwd/' /etc/dovecot.conf
	fi

	perl -pi -e 's/mail_extra_groups/mail_access_groups/' /etc/dovecot.conf

        #dovecot 1.1+
        perl -pi -e 's|default_mail_env|mail_location|' /etc/dovecot.conf
        perl -pi -e 's|args = /etc/virtual/%d/passwd|args = username_format=%n /etc/virtual/%d/passwd|' /etc/dovecot.conf

}

####################################################


if [ $# -eq 2 ]; then
	USER_INPUT=0
	INPUT_VALUE=$2

	if [ "$INPUT_VALUE" = "y" ]; then
		echo "";
		echo "";
		echo "***** WARNING:  y  option has been selected ******";
		echo "";
		echo "";
		echo "  The y option should not be used regularly with this script";
		echo "  Consider using d or n instead.";
		echo "  Recompiling zlib after the original install is hazardous to the health of sshd.";
		echo "";
		echo "";
		echo "Pres ctrl-c to cancel or wait 10 seconds to conitue";
		sleep 10
	fi
fi

case "$1" in
    all)
	doAll;
        ;;
    php)
	doPhp;
	;;
    gd) doGD;
    	;;
    libjpeg) doLibJpeg;
	;;
    libpng) doLibPng;
	;;
    zlib) doZlib;
	;;
    curl) doCURL;
    	;;
    mcrypt) doMCrypt;
    	;;
    mhash) doMHash;
	;;
    zzip) doZZip;
	;;
    apache_mod_ssl) doApache;
    	;;
    mod_perl) doModPerl;
    	;;
    mod_frontpage) doModFrontpage;
    	;;
    frontpage_ext) doFrontpageExt;
    	;;
    clean) doClean;
    	;;
    update) doUpdate;
    	;;
    update_data) doUpdateData;
    	;;
    update_data_ap2) doUpdateData2;
	;;
    webalizer) doWebalizer;
	;;
    zend) doZend;
    	;;
    convert) convert;
	;;
    apache_2) doApache2;
	;;
    php_ap2) doPhp 2;
	;;
    mod_frontpage_ap2) modFPap2;
	;;
    mod_perl_ap2) doModPerl2;
	;;
    update_dovecot) updateDovecot;
	;;
    todovecot) convertToDovecot;
	;;
    dovecot) doDovecot;
	;;
    * )	showHelp;
	exit 0;
        ;;
esac

exit 0;
