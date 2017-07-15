#!/bin/sh

# See OneNote for newest installation commands

# Source(s):
# Hyperion git: https://github.com/tvdzwan/hyperion/wiki
# Reddit thread: https://www.reddit.com/r/raspberry_pi/comments/2p6d1c/inspired_by_the_pipowered_led_lamp_posted_by_by/
#                -> vid from reddit project: https://www.youtube.com/watch?v=WpM1aq4B8-A
# LEDs: http://www.ebay.co.uk/itm/50pcs-12mm-IP65-Waterproof-Full-Color-Digital-RGB-LED-Pixel-with-WS2801-Arduino-/171215116370?ssPageName=ADME:L:OC:GB:3160
# Other lamp vids: https://www.youtube.com/watch?v=julETnOLkaU&feature=youtu.be & https://www.youtube.com/watch?v=julETnOLkaU&feature=youtu.be
# How to build lampshade: https://www.youtube.com/watch?v=YP_YLcYEcoc

# Note - for this project I'm using a USB power pack to run the pi. It seems to
# work fine to power both the pi and the LEDs. I think that's because it has a 3A
# output. If you're following my guide you'll see that there is also a DC jack
# input connected to the LEDs which can be used also.
# The power pack I'm using is this one:
# https://www.amazon.co.uk/Anker-13000mAh-Portable-External-Technology/dp/B00BQ5KHJW

# Make sure the hyperion_config_example.txt file is set up for your specific LED configuration.

# Note also that the wifi dongle I'm using is this one:
# http://www.amazon.co.uk/Edimax-EW-7811UN-150Mbps-Wireless-Adapter/dp/B003MTTJOY

#----------------------------------------------------------
# Header to easily change command line output colours and
# use an error catching routine.
#----------------------------------------------------------
# Change colours of output text:
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
# e.g. echo "${red}red text ${green}green text${reset}"
#----------------------------------------------------------
# Source: https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
# If an error occurs, the abort() function will be called.
# Source: http://stackoverflow.com/a/22224317
#----------------------------------------------------------
abort()
{
    tput setaf 1
    echo >&2 '
***************
*** ABORTED ***
***************
'
    echo "An error occurred. Exiting..." >&2
    exit 1
}

trap 'abort' 0

set -e
# Add your script below...
#==========================================================
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# To be honest, I created this script for myself to easily automate the install.
# You should probably walk through each command and run them one by one to understand what is happening.

## Set directory variables (where these files are stored + lcd scripts if needed)
# Remember to update location variables in other bash and python scripts too.
export HOME_DIR="/home/pi"
export SETUP_DIR="$HOME_DIR/Setup/Guides"
export HYPERION_DIR="$SETUP_DIR/hyperion"


#Hyperion setup
  echo "\n${green}Setting up Hyperion - downloading...${reset}"
# Download hyperion installation script
  wget -N https://raw.githubusercontent.com/hyperion-project/hyperion/master/bin/install_hyperion.sh -O ~/install_hyperion.sh
# Make the install script executable
  sudo chmod +x ~/install_hyperion.sh
# Make sure boblight is not running in the background, you probably won't have installed boblight previously in any case.
  #sudo /sbin/initctl stop boblight   #initctl for older versions of Raspbian
  #sudo systemctl stop boblight


echo "\n${green}Setting up Hyperion - installing...${reset}"
# Install all necessary packages for hyperion
  sudo apt-get -y install libqtcore4 libqtgui4 libqt4-network libusb-1.0-0 ca-certificates
# Hyperion requires use of SPI ouput pins. Comment out line in SPI blacklist file to enable SPI if the file exists
  if [ -f /etc/modprobe.d/raspi-blacklist.conf ]; then sudo sed -i '/blacklist spi-bcm2708/s/^/#/g' /etc/modprobe.d/raspi-blacklist.conf; fi
# Uncomment line in config.txt to enable SPI interface
  sudo sed -i '/dtparam=spi=on/s/^#//g' /boot/config.txt
# Run hyperion installer
  sudo apt-get update
  sudo sh ~/hyperion/install_hyperion.sh

# Hyperion will by default look for the configuration at "/etc"
# Sample config file is in this git project folder.
# Sometimes hyperion installation doesn't copy over example config file. Let's grab it in case we need to reference it later.
sudo wget https://raw.githubusercontent.com/hyperion-project/hyperion/master/config/hyperion.config.json.example -O /etc/hyperion/hyperion.config.json.example
# Copy our config file to correct location
cp $HYPERION_DIR/hyperion_config_example.txt /etc/hyperion/hyperion.config.json
# Restart Hyperion
sudo systemctl stop hyperion && sudo systemctl start hyperion

echo "Testing hyperion...\n"
  hyperion-remote --priority 30 --color red --duration 5000
  hyperion-remote --priority 50 -x

# This will install the hyperion web app on the pi. You should already have Apache installed if you want this to work.
# If you don't have apache installed already I would recommend using nginx as a lighter weight webserver and following
# the web app installation guide here: https://github.com/tvdzwan/hyperion/wiki/Web-app
# I use the excellent Android hyperion app to control the lights but this web app is a good backup option.
#echo "\n${green}Setting up Hyperion - installing web app (apache based)...${reset}"
#  mkdir /var/www/html/hyperion
#  git clone https://github.com/poljvd/hyperion-webapp.git /var/www/html/hyperion
#  chmod -R 775 /var/www/html/hyperion
#  sudo chown -R www-data:www-data /var/www/html/hyperion
#  sudo /etc/init.d/apache2 restart

echo "\n${green}You may now need to reboot the RPi to enable SPI interface...${reset}"

# There are a number of actions you should now take if you want a set up exactly like mine.
# Add lines below to the end of your /etc/rc.local file so that they run every time the pi boots.
# These do...
# 1. Check that hyperion has been installed. Then restart the service to make sure it is running.
# 2. Then set a starting colour.
# 3. Create a file '/hyperion.boot' which the hyperion Effect Rotator script (hyperion_effect_scroll.sh)
#    looks for to see if the pi has been rebooted. This allows the Effect Rotator script to start at last
#    used effect when it is run.
# 4. Start the monitor script (hyperion_button_monitor.py) to watch for the physical button press.
# 5. Run the Effect Rotator script to allow cycling through the effects using a dial.
# 6. Runs a script to display the date/time, the current effect name, and the Pi's local IP address.
# Look at the content of all scripts for more details on how they work and how to use them.

# Add this to /etc/rc.local above the 'exit 0' line:
if [ -f /etc/init.d/hyperion ]; then
  sudo cp /etc/rc.local /etc/rc.local
  sudo sed -i '/exit 0/d' /etc/rc.local
  echo "" | sudo tee -a /etc/rc.local
  echo "### HYPERION LED SECTION ###" | sudo tee -a /etc/rc.local
  echo "sudo systemctl stop hyperion" | sudo tee -a /etc/rc.local
  echo "sudo systemctl start hyperion" | sudo tee -a /etc/rc.local
  echo "#sleep 5" | sudo tee -a /etc/rc.local
  echo "# Set starting colour to whitey-blue" | sudo tee -a /etc/rc.local
  echo "hyperion-remote --priority 50 --color A5EFFA" | sudo tee -a /etc/rc.local
  echo "touch $HOME_DIR/hyperion.boot" | sudo tee -a /etc/rc.local
  echo "python $HYPERION_DIR/hyperion_button_monitor.py &    # Change this to where ever you saved the downloaded scripts" | sudo tee -a /etc/rc.local
  echo "python $HYPERION_DIR/hyperion_rotary_encoder.py &    # Change this to where ever you saved the downloaded scripts" | sudo tee -a /etc/rc.local
  echo "#python $SETUP_DIR/lcd/Time_RotateMsg.py &    # Change this to where you saved the downloaded lcd scripts" | sudo tee -a /etc/rc.local
  echo  "exit 0" | sudo tee -a /etc/rc.local
fi
#Make effect scroll bash script executable
chmod +x $HYPERION_DIR/hyperion_effect_scroll.sh

# To do...



#############################################
### DHT Temp Monitor (Still to implement) ###
#############################################

# I had a DHT temperature/humidity probe which I had left over from a different project I had been planning
# but never got round to doing. The original plan was to monitor the temp in the house and activate a stepper
# motor with an arm to push the 'on/off' button on the house thermostat. I was going to write a web page to monitor
# the house temperature and allow me to turn on/off the heating remotely (useful in the Scottish climate!). Or to
# turn on/off the heating based on certain criteria (temperature, time of day). Maybe throw in a second probe wired
# to the outside of the house too. I got about halfway through this project then it just kind of fizzled out.
# Anyway, I have this probe lying around now so thought it would be fun to wire it up to the lamp anyway just
# because I could! And it makes another interesting output for the LCD.
#
# Aaaaagh! I connected up my DHT11 the wrong way round and reversed the polarity. The power going the wrong way fried the component.
#
# Helpful Links:
# •	Mushroom monitot but should be good basis for my build: http://kylegabriel.com/projects/2015/04/mushroom-cultivation-revisited.html#software-setup
# •	Instructables guide for whole pi build and temp/humid logging and web interface: http://www.instructables.com/id/Raspberry-Pi-Temperature-Humidity-Network-Monitor/?ALLSTEPS
# •	Adafruit guide for taking temp/humidity readings: https://learn.adafruit.com/dht-humidity-sensing-on-raspberry-pi-with-gdocs-logging/overview
# •	How to amend the adafruit script to log temp humidity to mysql DB instead of screen: https://www.youtube.com/watch?v=Rbl0yj9Q3Zs
# •	Temp/humit set up with simple web graph – writes to txt log and html draws basic graph: https://chrisbaume.wordpress.com/2013/02/10/beer-monitoring/
# •	Other potential help: http://jartweb.net/blog/wp-content/uploads/2013/12/Raspberry-Pi-Logger-with-LCD.pdf


###############################
### Spotify Headless Client ###
###############################

# Another old project I did was to turn the Pi into a headless Spotify player using 'mopidy'. If I get time I'll
# add that to this lamp too as it would be pretty cool to be able to have some music playing. Especially as this
# lamp is going in my 'reading corner'.
# I have just implemented this functionality but that's a 'how to' all on it's own. Some googling will easily get
# you to any number of guides on how to do this.



#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#----------------------------------------------------------
trap : 0

tput setaf 2
echo >&2 '
**************
**** DONE ****
**************
'
#----------------------------------------------------------

