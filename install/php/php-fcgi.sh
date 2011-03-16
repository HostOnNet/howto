#!/bin/sh

set -e
export DOMAIN="YOURDOMAIN.TLD"

#SRCDIR=/usr/local/src/php-fcgi/
#INSTALLDIR=/usr/local/php-lighttpd
DISTDIR=/usr/local/src/php-src/

rm -rf /usr/local/src/php-fcgi/

# $DISTDIR
# Go to the sites and update latest versions below

# http://php.net/
PHP5="php-5.2.9"

# http://www.gnu.org/software/libiconv/
LIBICONV="libiconv-1.12"

# http://sourceforge.net/project/showfiles.php?group_id=87941&package_id=91774&release_id=487459
LIBMCRYPT="libmcrypt-2.5.8"

# http://xmlsoft.org/sources/
LIBXML2="libxml2-2.7.3"

# http://xmlsoft.org/sources/
LIBXSLT="libxslt-1.1.24"

# http://mhash.sourceforge.net/
MHASH="mhash-0.9.9.9"

# http://www.zlib.net/
ZLIB="zlib-1.2.3"

# http://curl.haxx.se/download.html
CURL="curl-7.19.4"

# http://www.gnu.org/software/libidn/
LIBIDN="libidn-1.13"

#CCLIENT="imap-2004g"
#CCLIENT_DIR="imap-2004g" # Another pest!

# http://freetype.sourceforge.net/index2.html
# http://sourceforge.net/project/showfiles.php?group_id=3157
FREETYPE="freetype-2.3.9"

#OPENSSL="openssl-0.9.8i"

# What PHP features do you want enabled?
PHPFEATURES="--prefix=/usr/local/php-lighttpd/ \
 --with-config-file-path=/usr/local/php-lighttpd/etc/php5/${DOMAIN} \
 --enable-fastcgi \
 --enable-force-cgi-redirect \
 --with-xml \
 --with-libxml-dir=/usr/local/php-lighttpd \
 --with-freetype-dir=/usr/local/php-lighttpd \
 --enable-soap \
 --with-openssl=/usr/local/php-lighttpd \
 --with-mhash=/usr/local/php-lighttpd \
 --with-mcrypt=/usr/local/php-lighttpd \
 --with-zlib-dir=/usr/local/php-lighttpd \
 --with-jpeg-dir=/usr \
 --with-png-dir=/usr \
 --with-gd \
 --enable-gd-native-ttf \
 --enable-memory-limit \
 --enable-ftp \
 --enable-exif \
 --enable-sockets \
 --enable-wddx \
 --with-iconv=/usr/local/php-lighttpd \
 --enable-sqlite-utf8 \
 --enable-calendar \
 --with-curl=/usr/local/php-lighttpd \
 --enable-mbstring \
 --enable-mbregex \
 --enable-bcmath \
 --with-mysql=/usr \
 --with-mysqli \
 --without-pear \
 --with-gettext \
 --with-imap=/usr/local/php-lighttpd \
 --without-imap-ssl"

# ---- end of user-editable bits. Hopefully! ----

# Push the install dir's bin directory into the path
export PATH=/usr/local/php-lighttpd/bin:$PATH

# set up directories
mkdir -p /usr/local/src/php-fcgi/
mkdir -p /usr/local/php-lighttpd
mkdir -p /usr/local/src/php-src/
cd /usr/local/src/php-src/

# Get all the required packages
wget -c http://us.php.net/get/${PHP5}.tar.gz/from/this/mirror
wget -c http://ftp.gnu.org/pub/gnu/libiconv/${LIBICONV}.tar.gz
wget -c http://easynews.dl.sourceforge.net/sourceforge/mcrypt/${LIBMCRYPT}.tar.gz
wget -c ftp://xmlsoft.org/libxml2/${LIBXML2}.tar.gz
wget -c ftp://xmlsoft.org/libxml2/${LIBXSLT}.tar.gz
wget -c http://superb-west.dl.sourceforge.net/sourceforge/mhash/${MHASH}.tar.gz
wget -c http://www.zlib.net/${ZLIB}.tar.gz
wget -c http://curl.haxx.se/download/${CURL}.tar.gz
wget -c http://kent.dl.sourceforge.net/sourceforge/freetype/${FREETYPE}.tar.gz
wget -c ftp://alpha.gnu.org/pub/gnu/libidn/${LIBIDN}.tar.gz
#wget -c ftp://ftp.cac.washington.edu/imap/old/${CCLIENT}.tar.Z
#wget -c http://www.openssl.org/source/${OPENSSL}.tar.gz

echo ---------- Unpacking downloaded archives. This process may take several minutes! ----------

cd /usr/local/src/php-fcgi/
# Unpack them all
echo Extracting ${PHP5}...
tar xzf /usr/local/src/php-src/${PHP5}.tar.gz
echo Done.
echo Extracting ${LIBICONV}...
tar xzf /usr/local/src/php-src/${LIBICONV}.tar.gz
echo Done.
echo Extracting ${LIBMCRYPT}...
tar xzf /usr/local/src/php-src/${LIBMCRYPT}.tar.gz
echo Done.
echo Extracting ${LIBXML2}...
tar xzf /usr/local/src/php-src/${LIBXML2}.tar.gz
echo Done.
echo Extracting ${LIBXSLT}...
tar xzf /usr/local/src/php-src/${LIBXSLT}.tar.gz
echo Done.
echo Extracting ${MHASH}...
tar xzf /usr/local/src/php-src/${MHASH}.tar.gz
echo Done.
echo Extracting ${ZLIB}...
tar xzf /usr/local/src/php-src/${ZLIB}.tar.gz
echo Done.
echo Extracting ${CURL}...
tar xzf /usr/local/src/php-src/${CURL}.tar.gz
echo Done.
echo Extracting ${LIBIDN}...
tar xzf /usr/local/src/php-src/${LIBIDN}.tar.gz
echo Done.
#echo Extracting ${CCLIENT}...
#uncompress -cd /usr/local/src/php-src/${CCLIENT}.tar.Z |tar x
#echo Done.
#echo Done.
echo Extracting ${FREETYPE}...
tar xzf /usr/local/src/php-src/${FREETYPE}.tar.gz
echo Done.
#echo Extracting ${OPENSSL}...
#tar xzf /usr/local/src/php-src/${OPENSSL}.tar.gz
#echo Done.

# Build them in the required order to satisfy dependencies.

#libiconv
cd /usr/local/src/php-fcgi/${LIBICONV}
./configure --enable-extra-encodings --prefix=/usr/local/php-lighttpd
# make clean
make
make install

#libxml2
cd /usr/local/src/php-fcgi/${LIBXML2}
./configure --with-iconv=/usr/local/php-lighttpd --prefix=/usr/local/php-lighttpd
# make clean
make
make install

#libxslt
cd /usr/local/src/php-fcgi/${LIBXSLT}
./configure --prefix=/usr/local/php-lighttpd \
 --with-libxml-prefix=/usr/local/php-lighttpd \
 --with-libxml-include-prefix=/usr/local/php-lighttpd/include/ \
 --with-libxml-libs-prefix=/usr/local/php-lighttpd/lib/
# make clean
make
make install

#zlib
cd /usr/local/src/php-fcgi/${ZLIB}
./configure --shared --prefix=/usr/local/php-lighttpd
# make clean
make
make install

#libmcrypt
cd /usr/local/src/php-fcgi/${LIBMCRYPT}
./configure --disable-posix-threads --prefix=/usr/local/php-lighttpd
# make clean
make
make install

#libmcrypt lltdl issue!!
cd  /usr/local/src/php-fcgi/${LIBMCRYPT}/libltdl
./configure --prefix=/usr/local/php-lighttpd --enable-ltdl-install
# make clean
make
make install

#mhash
cd /usr/local/src/php-fcgi/${MHASH}
./configure --prefix=/usr/local/php-lighttpd
# make clean
make
make install

#freetype
cd /usr/local/src/php-fcgi/${FREETYPE}
./configure --prefix=/usr/local/php-lighttpd
# make clean
make
make install

#libidn
cd /usr/local/src/php-fcgi/${LIBIDN}
./configure --with-iconv-prefix=/usr/local/php-lighttpd --prefix=/usr/local/php-lighttpd
# make clean
make
make install

#cURL
cd /usr/local/src/php-fcgi/${CURL}
./configure --with-ssl=/usr/local/php-lighttpd --with-zlib=/usr/local/php-lighttpd \
  --with-libidn=/usr/local/php-lighttpd --enable-ipv6 --enable-cookies \
  --enable-crypto-auth --prefix=/usr/local/php-lighttpd
# make clean
make
make install

# c-client
#cd /usr/local/src/php-fcgi/${CCLIENT_DIR}
#make -i ldb SSLTYPE=none
# Install targets are for wusses!
#cp c-client/c-client.a /usr/local/php-lighttpd/lib/libc-client.a
#cp c-client/*.h /usr/local/php-lighttpd/include

#OpenSSL
#cd /usr/local/src/php-fcgi/${OPENSSL}
#./config --prefix=/usr/local/php-lighttpd --openssldir=/usr/local/php-lighttpd
#make
#make install

echo - about to build php5...
echo
read -p  "(Press any key to continue)" temp;
echo

#PHP 5
cd /usr/local/src/php-fcgi/${PHP5}
./configure ${PHPFEATURES}
# make clean
make
make install

#copy config file
mkdir -p /usr/local/php-lighttpd/etc/php5/${DOMAIN}
cp /usr/local/src/php-fcgi/${PHP5}/php.ini-dist /usr/local/php-lighttpd/etc/php5/${DOMAIN}/php.ini

#copy PHP CGI
mkdir -p ${HOME}/${DOMAIN}/cgi-bin
chmod 0755 ${HOME}/${DOMAIN}/cgi-bin
cp /usr/local/php-lighttpd/bin/php ${HOME}/${DOMAIN}/cgi-bin/php.cgi
rm -rf /usr/local/src/php-fcgi/ /usr/local/src/php-src
echo ---------- INSTALL COMPLETE! ----------
