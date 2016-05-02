tncpi.sh is a small script to deploy a wifi-enabled TNC, utilizing direwolf on Raspbian Jessie.

Once completed, and rebooted, the Pi will act as both a TNC and an access point.

# Technical Details
The TNC's address is 192.168.42.1, and it broadcasts an AP named "Pi_AP" with a key of "Raspberry".  The device will also use any GPS device connected, and detected by gpsd (Most USB devices autodetect).  If connected to ethernet as well, it will route traffic as well!

Direwolf (The soundcard modem used) must be configured by hand (For now).  It's config file is located at /home/pi/direwolf.conf.  Direwolf must be started by hand (For now).

# Installation
To begin the installation, install a fresh copy of Raspbian Jessie Lite on the SD card.  Boot the Pi up, and connect to it via SSH.

Once there, ensure your soundcard is detected as is your wifi adapter.  Please, during the installation, leave the Pi connected to ethernet, and not wifi (The interfaces for wifi are manipulated during the setup, and you could soft-brick the Pi).

After you've verified the above, you can execute either:

* git clone git@github.com:coreyreichle/tnc_pi.git ; cd tnc_pi; chmod +x tncpi.sh; sudo ./tncpi.sh
* wget https://github.com/coreyreichle/tnc_pi/blob/master/tncpi.sh ; chmod +x tncpi.sh ; sudo ./tncpi.sh

Or, lastly, copy the tncpi.sh script to the sd card in whatever manner you choose.  Sit back, grab a cup of coffee.  The only time you'll need to check on it, is when it gets to the wifi AP portion.  You can either choose to abort now, and just use your TNC as is, or enable the wifi AP.
