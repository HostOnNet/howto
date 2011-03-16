#!/bin/bash
#FFMPEG installer [ as modified by PHPmotion : Date - 24 July 2007]

#colors

RED='\033[01;31m'
RESET='\033[0m'
clear
echo -e "$RED"
echo "############################### ffmpeg installation ####################################"
echo "                  [ as modified by PHPmotion : Date - 24 July 2007]"
echo "########################################################################################"
echo -e "$RESET"
sleep 3
#detecting number of physical/logical processors
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
echo "processors detected      :     "$cpu
sleep 2
#public variables
INSTALL_SDIR='/usr/src/ffmpegscript'
SOURCE_URL='http://www.phpmotion.com/ffmpeg_sources'
flvtool_source='flvtool2_1.0.5_rc6.tgz'
lame_source='lame-3.97.tar.gz'
codec_source='essential-20061022.tar.bz2'
mplayer_source='MPlayer-1.0rc1.tar.bz2'
libogg_source='libogg-1.1.3.tar.gz'
libvorbis_source='libvorbis-1.1.2.tar.gz'
ffmpeg_source='ffmpeg_source.tgz'
ffmpeg_php_source='ffmpeg-php-0.5.0.tbz2'
ruby_source='ruby-1.8.6-p110.tar.gz'

#presetup 
rm -rf $INSTALL_SDIR
mkdir -p $INSTALL_SDIR
echo "creating folders..........done"

#checking /tmp execute permissions
echo "creating temp environment.."
rm -rf $HOME/phpmptiontemp
mkdir -p $HOME/phpmptiontemp
chmod 4777 $HOME/phpmptiontemp
export TMPDIR=$HOME/phpmptiontemp

#install ruby
   cd $INSTALL_SDIR
sleep 5
echo -e $RED"installing ruby........ "$RESET
echo "removing old source"
   rm -vrf ruby*
   wget $SOURCE_URL/$ruby_source
   gunzip ruby-1.8.6-p110.tar.gz
   tar -xvf ruby-1.8.6-p110.tar
   cd ruby-1.8.6-p110
   ./configure
   make
   make install
echo -e $RED"ruby....................completed"$RESET
sleep 15

#install flvtool
   cd $INSTALL_SDIR
sleep 5
echo -e $RED"installing flvtool........ "$RESET
echo "removing old source"
   rm -vrf flvtool*
   wget $SOURCE_URL/$flvtool_source
   tar -zxvf   flvtool2_1.0.5_rc6.tgz
   cd flvtool2_1.0.5_rc6/
   ruby setup.rb config
   ruby setup.rb setup
   ruby setup.rb install
echo -e $RED"flvtool....................completed"$RESET
sleep 5
#install lame encoder
   cd $INSTALL_SDIR
clear
sleep 5
echo -e $RED"installing lame......"$RESET
echo "removing old source"
   rm -vrf lame*
   wget $SOURCE_URL/$lame_source
   tar -zxvf lame-3.97.tar.gz
   cd lame-3.97
   ./configure --prefix=/usr --enable-mp3x --enable-mp3rtp
sleep 5
   make -j$cpu
sleep 5
   make install
echo -e $RED"lame....................completed"$RESET
sleep 5

#install codecs
   cd $INSTALL_SDIR
clear
sleep 5
echo -e $RED"Installing codecs......."$RESET
echo "removing old source"
   rm -vfr essential*
   wget $SOURCE_URL/$codec_source
   tar -xvjf essential-20061022.tar.bz2
   chown -R root.root essential-20061022
   mkdir -pv /usr/local/lib/codecs/
   cp -vrf essential-20061022/* /usr/local/lib/codecs/
   chmod -R 755 /usr/local/lib/codecs/
echo -e $RED"codecs....................completed"$RESET
sleep 5
#install Mplayer
   cd $INSTALL_SDIR
clear
sleep 5
echo -e $RED"Installing  MPlayer......."$RESET
echo "removing old source"
   rm -vrf MPlayer*
   wget $SOURCE_URL/$mplayer_source
   tar -jvxf MPlayer-1.0rc1.tar.bz2
   cd MPlayer-1.0rc1/
   ./configure --prefix=/usr --with-codecsdir=/usr/local/lib/codecs/
sleep 15
   make -j$cpu
sleep 10
   make install
echo -e $RED"Mplayer....................completed"$RESET
sleep 10
#install libogg
    cd $INSTALL_SDIR
clear
sleep 5
echo -e $RED"Installing libogg......"$RESET
echo "removing old source"
   rm -vrf libogg*
   wget $SOURCE_URL/$libogg_source 
   tar -xvzf libogg-1.1.3.tar.gz
   cd libogg-1.1.3/
   ./configure --prefix=/usr/
sleep 5
   make -j$cpu
sleep 5
   make install
echo -e $RED"libogg....................completed"$RESET
sleep 5
#install libvorbis
   cd $INSTALL_SDIR
clear
sleep 5
echo -e $RED"Installing  libvorbis......."$RESET
echo "removing old source"
   rm -vrf libvorbis*
   wget $SOURCE_URL/$libvorbis_source
   tar -xvzf libvorbis-1.1.2.tar.gz
   cd libvorbis-1.1.2
   ./configure --prefix=/usr
sleep 5
   make -j$cpu
sleep 5
   make install
echo $RED"libvorbis....................completed"$RESET
sleep 5
#install ffmpeg
   cd $INSTALL_SDIR
clear
sleep 5

echo -e $RED"Installing  ffmpeg......."$RESET   
echo "removing old source"
   rm -vrf ffmpeg*
   wget $SOURCE_URL/$ffmpeg_source
   gunzip ffmpeg_source.tgz
   tar -xvf ffmpeg_source.tar
   cd ffmpeg
   ./configure --prefix=/usr --enable-libmp3lame --enable-libogg --enable-libvorbis --disable-mmx --enable-shared
sleep 15
   make -j$cpu
sleep 10
   make install
echo -e $RED"ffmpeg....................completed"$RESET
sleep 5
echo "		###########################IMPORTENT###############################"
echo "		SETUP IS NOW COMPLETE - YOU SHOULD RUN TESTS TO SEE IF IT WENT OK "
echo "		END"
echo "		###########################IMPORTENT###############################"
echo -e "$RESET"
