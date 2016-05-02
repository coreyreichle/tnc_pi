tncpi.sh is a small script to deploy a wifi-enabled TNC, utilizing direwolf on Raspbian Jessie.

Once completed, and rebooted, the Pi will act as both a TNC and an access point.

# Technical Details
The TNC's address is 192.168.42.1, and it broadcasts an AP named "Pi_AP" with a key of "Raspberry".  The device will also
use any GPS device connected, and detected by gpsd (Most USB devices autodetect).  If connected to ethernet as well, it will
route traffic as well!

Direwolf (The soundcard modem used) must be configured by hand (For now).  It's config file is located at 
/home/pi/direwolf.conf.  Direwolf must be started by hand (For now).
