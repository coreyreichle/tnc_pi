Have you ever wanted to sit on your couch, and remotely access your TNC over wifi, and not in the shack?  If so, tncpi.sh is a small script to deploy a wifi-enabled TNC, utilizing direwolf on Raspbian Jessie.

Once completed, and rebooted, the Pi will act as both a TNC and an access point.

# Technical Details
The TNC's address is 192.168.42.1, and it broadcasts an AP named "Pi_AP" with a key of "Raspberry".  The device will also use any GPS device connected, and detected by gpsd (Most USB devices autodetect).  If connected to ethernet as well, it will route traffic as well!

Direwolf (The soundcard modem used) is configured intially for VOX PTT, and beacons a position using a fixed interval, along with smartbeaconing.  If you want to use another method for PTT, or adjust the beaconing, that will need to be done by hand.

# Installation
To begin the installation, install a fresh copy of Raspbian Jessie Lite on the SD card.  Boot the Pi up, and connect to it via SSH.

Once there, ensure your soundcard is detected as is your wifi adapter.  Please, during the installation, leave the Pi connected to ethernet, and not wifi (The interfaces for wifi are manipulated during the setup, and you could soft-brick the Pi).

After you've verified the above, you can execute either:

* git clone git@github.com:coreyreichle/tnc_pi.git ; cd tnc_pi; chmod +x tncpi.sh; sudo ./tncpi.sh {MY CALLSIGN-SID}
* wget https://github.com/coreyreichle/tnc_pi/blob/master/tncpi.sh ; chmod +x tncpi.sh ; sudo ./tncpi.sh {MY CALLSIGN-SID}

Or, lastly, copy the tncpi.sh script to the sd card in whatever manner you choose.  Sit back, grab a cup of coffee.  The only time you'll need to check on it, is when it gets to the wifi AP portion.  You can either choose to abort now, and just use your TNC as is, or enable the wifi AP.

This script also installs a webpage for managing direwolf's config, and to also force a reload (via killing the process).  Be warned, this should not be installed on a publicly acccesible machine, there's 0, zero, nada, none, nothing in the way of security.  Anyone can reconfigure the direwolf process, if they have access to the web UI.

Once some display of logging is in the UI for the direwolf instance, version will get bumped to 1.0, and could be considered ready for general deployment.

# ToDo
* ~~Build a management interface for direwolf~~
* ~~Enable direwolf startup on boot~~
* Add install-time option to configure a BBS on board (JNOS or something similar)
