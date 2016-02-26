#!/usr/bin/python

# I had a rotary encoder from a Sunfounder Raspberry Pi starter kit and thought I would use it to
# scroll through the hyperion effects. Here's the kit:
# http://www.amazon.co.uk/Sunfounder-Project-Raspberry-Extension-7-Segment/dp/B00P2E9W30
# The encoder is one of these or similar:
# http://www.amazon.co.uk/TaylorRoco-Encoder-Development-Adapter-Arduino/dp/B011AVHSYS
# You can also push in the encoder and use it as a button so
# I've configured that button press as an on/off switch for the LEDs.

# Rotary encoders have 5 pins. They are not always labelled consistently but with some trial and
# error you'll figure yours out. Mine are attached in this way (you can change pin inputs in the
# code below):
# CLK (clockwise) - pin 17
# DT (anti-clockwise) - pin 27
# SW (switch) - pin 22
# + (positive) - connected to one of the 3.3V pins, doesn't matter which one
# GND (ground) - connected to one of the ground pins, doesn't matter which one or even if you share with another component's ground.

# Script tweaker from one found here: https://volumio.org/forum/gpio-pins-control-volume-t2219.html
# It uses Bob Rathbone's rotary encoder class which can be downloaded from here: http://www.bobrathbone.com/raspberrypi_rotary.htm
# It should be saved in /home/pi. You don't HAVE to download it  as I've included it in this download
# you'll find it as file 'rotary_class.py'. It should be saved in /home/pi or in any other location
# already in your python path.
# This code will automatically copy it to /home/pi for you if it isn't already there.

import subprocess
import sys
import time
import os
import shutil
import io

#set to location of the downloaded hyperion scripts
hyperion_dir="/root/RaspPi/Setup/hyperion"

# Copy rotary class to /home/pi if it's not there already
if os.path.isfile("/home/pi/rotary_class.py"):
  print "Rotary class already exists in /home/pi, not copying"
else:
  print "Copying rotary class to /home/pi"
  shutil.copy(hyperion_dir+'/rotary_class.py','/home/pi/rotary_class.py')

# Import rotary class
from rotary_class import RotaryEncoder

# Define GPIO inputs (BCM) - rotary_class.py sets GPIO pin mode to BCM
# Change these to whatever you want to use
PIN_A = 17
PIN_B = 27     
BUTTON = 22    

# This is the event callback routine to handle events
def switch_event(event):
        if event == RotaryEncoder.CLOCKWISE:
              print "Clockwise"    # For testing - will dispaly if you run python script from command line
              subprocess.call(hyperion_dir +"/hyperion_effect_scroll.sh", shell=False)
              #slight pause to debounce
              time.sleep(0.3)
        elif event == RotaryEncoder.ANTICLOCKWISE:
              print "Anti-Clockwise"    # For testing - will dispaly if you run python script from command line
              subprocess.call([hyperion_dir +"/hyperion_effect_scroll.sh", " down"])
              #slight pause to debounce
              time.sleep(0.3)
        elif event == RotaryEncoder.BUTTONDOWN:
              print "Button pressed down"    # For testing - will dispaly if you run python script from command line
              # If the LEDs are on and you click the button it will turn them off and set the same temporary 
              # 'flag' file as used when we reboot the Pi. This will let the 'hyperion_effect_scroll.sh' script
              # pick up from where we left off when we turn it back on. To determine whether the LEDs are on or
              # not it checks for the existance of teh 'flag' file since this will have been set previously 
              # if we turned them off. Note that after a reboot the 'flag' file will exist too so the first click
              # of the encoder will turn on the LEDs at the last used effect from before reboot.
              if os.path.isfile("/hyperion.boot"):
                # LEDs are off so call 'hyperion_effect_scroll.sh' to turn them on
                subprocess.call(hyperion_dir +"/hyperion_effect_scroll.sh", shell=False)
              else:
                # LEDs are on so let's turn them off, and create the 'flag' file 
                subprocess.call("hyperion-remote "+"--priority 50 --clearall", shell=True)
                open('/hyperion.boot', 'a').close()
                # Write LED off to file for display on LCD if in use
                f = io.open( hyperion_dir +"/hyperion_effect_scroll.effect", 'wb' )
                f.truncate()
                f.write("0.LEDs off")
                f.close()
              #slight pause to debounce
              time.sleep(0.3)
        #elif event == RotaryEncoder.BUTTONUP:
              # No need to have activity on both down and up strokes of the switch unless you really want to
              #print "Button up"    # For testing
        return

## Define the switch
rswitch = RotaryEncoder(PIN_A,PIN_B,BUTTON,switch_event)

while True:
        time.sleep(0.1)