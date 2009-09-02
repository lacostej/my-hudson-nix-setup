#!/bin/bash
#
# Small script to identify if there's a newer hudson.war release and download it 
#
# $Id: upgrade_hudson.sh 22788 2008-12-18 09:39:38Z jerome $
# 
PATH=/usr/local/bin:/usr/bin:/bin

#
# potential improvements
# * redirect output into a log file, make output cleaner
# 
install_dir=/opt/hudson
tmp_file=hudson.war.tmp

cd $install_dir

# need to update ?
rm -f changelog.html
#http_proxy="http://proxy:8080"  wget --no-check-certificate https://hudson.dev.java.net/changelog.html
wget --no-check-certificate https://hudson.dev.java.net/changelog.html
new_version=`grep "<a name=v" changelog.html  | head -2 | tail -1 | sed -e 's/.*a name=v\([^>]*\).*/\1/'`

rm -rf META-INF
jar xvf hudson.war META-INF/MANIFEST.MF
current_version=`grep Implementation-Version META-INF/MANIFEST.MF  | sed -e 's/.*: \([0-9\.]*\).*/\1/'`
rm -rf META-INF

if [ -z $new_version ]; then
  echo "couldnt identify version of downloaded hudson.war. Aborting update"
  exit 
fi

if [ $new_version == $current_version ]; then
  echo "No new version of hudson detected. Staying at $current_version."
  exit
fi

echo "Upgrading hudson from $current_version to $new_version"

rm -f $tmp_file
#http_proxy="http://proxy:8080"  wget --no-check-certificate http://hudson.gotdns.com/latest/hudson.war -O $tmp_file
wget --no-check-certificate http://hudson.gotdns.com/latest/hudson.war -O $tmp_file

if [ ! -f $tmp_file ]; then
  echo "couldn't download latest hudson release. Aborting..."
  exit
fi

if [ -h hudson.war ]; then
  rm hudson.war
fi
mv $tmp_file hudson.war_$new_version
ln -s hudson.war_$new_version hudson.war

echo "Upgraded hudson from $current_version to $new_version"
echo "Restart hudson for being effective"
ps -aef | grep java | grep hudson
