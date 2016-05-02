#!/bin/bash

#################################################################
#
# TNC Pi Build Script
#	vr 0.5
#
# Written by Corey Reichle
# 05/01/2016
# Copyright (c) 2016 by Corey Reichle.  Released under GPL 3 or later.
#
# Version History:
#
# 0.5			Initial release verion on Jessie
#
#################################################################

cd /home/pi

cat << '_EOF'
This is a build script for the Raspberry Pi, that turns your Pi into a wifi
enabled TNC, with GPS support.

For this script to run correctly, it must be executed as root, or with sudo.  It
cannot be ran as a non-privileged user.  It is assumed you'll have a USB sound
device connected eventually, along with VOX for PTT.  You must have an active
internet connection for this script to complete, preferably, over ethernet.
_EOF

echo "Ensuring your pi is up-to-date..."
apt-get update ; sudo apt-get upgrade -y

echo "Installing required packages..."
apt-get install gpsd-clients git libasound2-dev gpsd libgps-dev build-essential automake libtool texinfo git wget libhamlib-dev

echo "Cloning in repos..."
git clone https://www.github.com/wb2osz/direwolf
git clone git://hamlib.git.sourceforge.net/gitroot/hamlib/hamlib

echo "Building hamlib..."
cd hamlib ; sh autogen.sh && make && make check
make install


cd ../direwolf/
echo "Adding hamlib support to direwolf..."
sed -i 's/\#CFLAGS += -DUSE_HAMLIB/CFLAGS += -DUSE_HAMLIB/g' Makefile.linux
sed -i 's/\#LDFLAGS += -lhamlib/LDFLAGS += -lhamlib/g' Makefile.linux

echo "Building direwolf..."
make

echo "Configuring gpsd to allow network connections..."
sed 's/ListenStream=127.0.0.1:2947/ListenStream=0.0.0.0:2947/g' /lib/systemd/system/gpsd.socket > /etc/systemd/system/gpsd.socket
sed 's/GPSD_OPTIONS=\"\"/GPSD_OPTIONS=\"-G\"/g' /etc/default/gpsd > /etc/default/gpsd
cp /lib/systemd/system/gpsd.service /etc/systemd/system/gpsd.service

echo "Reloading new gpsd settings..."
sudo systemctl daemon-reload
sudo service gpsd restart

echo "Building your Wifi Access Point..."
echo "Hit <CTRL><C> if you want to skip this step.  Otherwise, hit any key to continue..."
read line

cd /home/pi
echo "Getting the wifipi.sh script..."
wget https://github.com/coreyreichle/wifi_pi/blob/master/wifipi.sh
echo "Customizing it, to remove the giant apt purge..."
sed -i '51,82d' wifipi.sh
chmod +x wifipi.sh
./wifipi.sh
