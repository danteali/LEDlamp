#!/bin/sh
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

## This is the location where you copy these project files
HYPERION_DIR="/root/RaspPi/Setup/hyperion"    

#Hyperion setup
  echo "\n${green}Setting up Hyperion - downloading...${reset}"
# Create new folder in the pi user home 
  mkdir ~/hyperion && cd ~/hyperion
# Download hyperion installation script
  wget -N https://raw.githubusercontent.com/tvdzwan/hyperion/master/bin/install_hyperion.sh
# Make the install script executable
  sudo chmod +x ~/hyperion/install_hyperion.sh
# Make sure boblight is not running in the background, you probably won't have installed boblight previously in any case.
  sudo /sbin/initctl stop boblight


echo "\n${green}Setting up Hyperion - installing...${reset}"
# Install all necessary packages for hyperion
  sudo apt-get -y install libqtcore4 libqtgui4 libqt4-network libusb-1.0-0 ca-certificates
# Hyperion requires use of SPI ouput pins. Comment out line in SPI blacklist file to enable SPI if the file exists
  if [ -f /etc/modprobe.d/raspi-blacklist.conf ]; then sed -i '/blacklist spi-bcm2708/s/^/#/g' /etc/modprobe.d/raspi-blacklist.conf; fi
# Uncomment line in config.txt to enable SPI interface
  sed -i '/dtparam=spi=on/s/^#//g' /boot/config.txt
# Run hyperion installer
  sudo sh ~/hyperion/install_hyperion.sh
# Hyperion should be running now, but restart it just in case
  sudo /usr/sbin/service hyperion restart

# Hyperion will by default look for the configuration at "/etc"
# Sample config file is in this git project folder. 
# Copy it if required but hyperion should install a default config file anyway.
# cp $HYPERION_DIR/hyperion_config_example.txt /etc/hyperion.config.json
# Restart Hyperion
# sudo /usr/sbin/service hyperion restart

echo "Testing hyperion...\n"
  hyperion-remote --priority 50 --color red --duration 5000
  hyperion-remote --priority 50 -x

# This will install the hyperion web app on the pi. You should already have Apache installed if you want this to work.
# If you don't have apache installed already I would recommend using nginx as a lighter weight webserver and following 
# the web app installation guide here: https://github.com/tvdzwan/hyperion/wiki/Web-app
# I use the excellent Android hyperion app to control the lights but this web app is a good backup option.
echo "\n${green}Setting up Hyperion - installing web app (apache based)...${reset}"
  mkdir /var/www/html/hyperion 
  git clone https://github.com/poljvd/hyperion-webapp.git /var/www/html/hyperion
  chmod -R 775 /var/www/html/hyperion
  sudo chown -R www-data:www-data /var/www/html/hyperion
  sudo /etc/init.d/apache2 restart

echo "\n${green}You may now need to reboot the RPi to enable SPI interface...${reset}"


### Rotary Encoder ###

# 



########################
### DHT Temp Monitor ###
########################
#
# I had a DHT temperature/humidity probe which I had left over from a different project I had been planning
# but never got round to doing. The original plan was to monitor the temp in the house and activate a stepper 
# motor with an arm to push the 'on/off' button on the house thermostat. I was going to write a web page to monitor
# the house temperature and allow me to turn on/off the heating remotely (useful in the Scottish climate!). Or to 
# turn on/off the heating based on certain criteria (temperature, time of day). Maybe throw in a second probe wired
# to the outside of the house too. I got about halfway through this project then it just kind of fizzled out.
# Anyway, I have this probe lying around now so thought it would be fun to wire it up to the lamp anyway just 
# because I could! And it makes another interesting output for the LCD.
#
# The script /dht11/Temp_Hum_Monitor.py will run at boot to call a second script /dht11/Temp_Hum.py every 30 seconds
# This records current temp and humidity in a text file in the same directory. Details of GPIO connecting pins are
# in that script. Just connect the component to the pins, run the Adafruit setup (details in other file too),
# add the monitor script to startup jobs (detailed below) and you're good to go.
#
# The LCD script (see commands below and read script comments at /lcd/Time_RotateMsg.py) then pulls this temp/hum 
# data to display on the 16x2 screen.



##########################################################
### Start up jobs, LCD output, button & rotary encoder ###
##########################################################
#
# There are a number of actions you should now take if you want a set up exactly like mine.
# Add these lines to the end of your /etc/rc.local file so that they run every time the pi boots.
# 
# These will:
# - Check that hyperion has been installed. Then restart the service to make sure it is running.
# - Then set a starting colour. Then the 'fun' stuff happens...
# - It creates a file '/hyperion.boot' which the hyperion Effect Rotator script (hyperion_effect_scroll.sh)
#   looks for to see if the pi has been rebooted. This allows the Effect Rotator script to start at last
#   used effect when it is run.
# - The next command starts the monitor script (hyperion_button_monitor.py) to watch for the physical button press. 
#   Read this script to see which GPIO pins to connect your button to. Remember all GND pins can be connected 
#   to same GND GPIO.
# - The next command will run the Effect Rotator script to allow cycling through the effects using a dial. 
#   Read this script to see which GPIOs to connect your rotary encoder to.
# - The next command runs a script to display the date/time, the current effect name, and the Pi's local IP address 
#   on the LCD. Again, read this script to see the detail of how it works and which GPIOs to use.
#
# Add this to /etc/rc.local above the 'exit 0' line:
# if [ -f /etc/init.d/hyperion ]; then
#   sudo service hyperion restart
#   sleep 5
#   # Set starting colour to whitey-blue
#   hyperion-remote --priority 50 --color A5EFFA
#   touch /hyperion.boot
#   python /root/RaspPi/Setup/hyperion/hyperion_button_monitor.py &    # Change this to where ever you saved the downloaded scripts
#   python /root/RaspPi/Setup/hyperion/hyperion_rotary_encoder.py &    # Change this to where ever you saved the downloaded scripts
#   python /root/RaspPi/Setup/lcd/Time_RotateMsg.py &    # Change this to where you saved the downloaded lcd scripts
# fi


# Something else you can do...

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