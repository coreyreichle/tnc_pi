#!/bin/bash

#################################################################
#
# TNC Pi Build Script
#	vr 0.9
#
# Written by Corey Reichle
# 05/01/2016
# Copyright (c) 2016 by Corey Reichle.  Released under GPL 3 or later.
#
# Version History:
#
# 0.5			Initial release verion on Jessie
# 0.6     Fixed up some bugs
# 0.9     Added cron job to start direwolf
#         Added intake option for callsign-{sid}
#         Added direwolf config
# 0.9.5	 Added direwolf management page
#
#################################################################

export CALLSIGN=$1

cd /home/pi

cat << '_EOF'
This is a build script for the Raspberry Pi, that turns your Pi into a wifi
enabled TNC, with GPS support.

For this script to run correctly, it must be executed as root, or with sudo.  It
cannot be ran as a non-privileged user.  It is assumed you'll have a USB sound
device connected eventually, along with VOX for PTT.  You must have an active
internet connection for this script to complete, preferably, over ethernet.

You must supply the callsign for auto-configuration.
_EOF

echo "Hit <CTRL><C> to cancel, otherwise, hit any key to continue..."
read line

if [[ ${CALLSIGN} == "" ]]; then
  echo "No Callsign provided.  Please provide a callsign"
  exit 1
fi

echo "Ensuring your pi is up-to-date..."
apt-get update ; sudo apt-get upgrade -y

echo "Installing required packages..."
apt-get -y install gpsd-clients git libasound2-dev gpsd libgps-dev build-essential automake libtool texinfo git wget libhamlib-dev apache2 php5 libapache2-mod-php5 php5-mcrypt apache2

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
make && make install

echo "Configuring gpsd to allow network connections..."
sed 's/ListenStream=127.0.0.1:2947/ListenStream=0.0.0.0:2947/g' /lib/systemd/system/gpsd.socket > /etc/systemd/system/gpsd.socket
sed 's/GPSD_OPTIONS=\"\"/GPSD_OPTIONS=\"-G\"/g' /etc/default/gpsd > /etc/default/gpsd
cp /lib/systemd/system/gpsd.service /etc/systemd/system/gpsd.service

echo "Reloading new gpsd settings..."
sudo systemctl daemon-reload
sudo service gpsd restart

echo "Installing cron job to keep direwolf running..."
cat > /home/pi/dw-start.sh <<'_EOF'
#!/bin/bash

#
# Nothing to do if it is already running.
#

a=`ps -ef | grep direwolf | grep -v grep`
if [ "$a" != "" ] 
then
  #date >> /tmp/dw-start.log
  #echo "Already running." >> /tmp/dw-start.log
  exit
fi

echo "---begin--------------------" >> /tmp/dw-start.log
date >> /tmp/dw-start.log
echo "Direwolf not running." >> /tmp/dw-start.log
echo "Start up application." >> /tmp/dw-start.log

/usr/local/bin/direwolf -c /home/pi/direwolf.conf -l /home/pi/dwlogs -t 0

echo "---end--------------------" >> /tmp/dw-start.log
_EOF

chmod +x /home/pi/dw-start.sh
chown pi:pi /home/pi/dw-start.sh

(crontab -l -u pi 2>/dev/null; echo "* * * * * /home/pi/dw-start.sh >/dev/null  2>&1") | crontab -u pi -

echo "Writing direwolf config..."

cat > /home/pi/direwolf.conf <<_EOF
ADEVICE plughw:1,0
ACHANNELS 1
CHANNEL 0
MYCALL $CALLSIGN
MODEM 1200
# This is where you must configure your PTT.  You can leave it alone if you're planning to use VOX.
# The line below is an example of an FT-817ND (120 in rigctl), using ttyUSB0.
#PTT RIG 120 /dev/ttyUSB0
AGWPORT 8000
KISSPORT 8001

TBEACON DELAY=0:30 EVERY=2:00 VIA=WIDE1-1 SYMBOL=car
SMARTBEACONING
_EOF

chmod 766 /home/pi/direwolf.conf
echo "Creating direwolf config management page..."

cat > /var/www/html/index.php << '_EOF'
<?php 
$fn = "/home/pi/direwolf.conf"; 

if (isset($_POST['addition'])) {
$file = fopen($fn, "w");
fwrite($file, $_POST['addition']); 
fclose($file);
}

if (isset($_POST['restart'])) {
$command = "pkill -9 direwolf";
$output = system($command);
print("Direwolf killed.  Process will respawn in the next few minutes.");
}

$file = fopen($fn, "r");
$size = filesize($fn);
$text = fread($file, $size); 
fclose($file); 
?> 

<form action="<?php $_SERVER['PHP_SELF']; ?>" method="post">
<input type="submit" value="Restart Direwolf" name="restart">
</form>

<form action="<?php $_SERVER['PHP_SELF']; ?>" method="post"> 
<h3>Current configuration for direwolf:</p></h3>
<textarea rows="20" cols="80"><?=$text?></textarea><br/>
<h3>New Configuration for direwolf </p></h3> 
<textarea rows="20" cols="80" name="addition"><?=$text?></textarea>
<input type="submit"/>
</form>
_EOF
rm /var/www/html/index.html

echo "Building your Wifi Access Point..."
echo "Hit <CTRL><C> if you want to skip this step.  Otherwise, hit any key to continue..."
read line

cd /home/pi
echo "Getting the wifipi.sh script..."
wget -O https://raw.githubusercontent.com/coreyreichle/wifi_pi/master/wifipi.sh
echo "Customizing it, to remove the giant apt purge..."
sed -i '51,82d' wifipi.sh
chmod +x wifipi.sh
./wifipi.sh
