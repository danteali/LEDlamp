#!/usr/bin/python
# Tweaked from here: http://piplay.org/forum/discussion/564/shutdown-button-using-gpio-pin/p1
# Connect button to any ground and GPIO pin 23 (board pin 15) - change these below if you want to.

# I'm using a switch that came with a Sunfounder Raspberry Pi project kit I got when I was 
# first starting out. Here's the kit:
# http://www.amazon.co.uk/Sunfounder-Project-Raspberry-Extension-7-Segment/dp/B00P2E9W30
# And the switch is one of these (or similar):
# http://www.amazon.co.uk/TaylorRoco-Tactile-Button-Switch-Momentary/dp/B011AVHII4
# Really any push switch would work.

# Note that we use GPIO numbering for pins by setting this below: GPIO.setmode(GPIO.BCM)
# You could use board numbering by setting: GPIO.setmode(GPIO.BOARD)
# More info at: https://raspberrypi.stackexchange.com/questions/12966/what-is-the-difference-between-board-and-bcm-for-gpio-pin-numbering

import RPi.GPIO as GPIO    #to use board pin numbering: 'import RPi.GPIO as BOARD'
import time
import os
import subprocess

#adjust for where your switch is connected
buttonPin = 23

#set to location of the downloaded hyperion scripts
hyperion_dir="/root/RaspPi/Setup/hyperion"

GPIO.setmode(GPIO.BCM)

GPIO.setup(buttonPin, GPIO.IN,pull_up_down=GPIO.PUD_UP)
while True:
    print GPIO.input(buttonPin)
    if(GPIO.input(buttonPin) == False):
        subprocess.call(hyperion_dir +"/hyperion_effect_scroll.sh", shell=False)
        #os.system("sudo echo hello_world") # Alternatively this also works to run a command
    #slight pause to debounce
    time.sleep(0.1)