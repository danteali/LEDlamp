#!/usr/bin/python

# Huge help from these webistes:
# https://github.com/adafruit/Adafruit-Raspberry-Pi-Python-Code/blob/master/Adafruit_CharLCD/Adafruit_CharLCD_IPclock_example.py

# Editted Adafruit's script from here:
# https://github.com/adafruit/Adafruit-Raspberry-Pi-Python-Code/blob/master/Adafruit_CharLCD/Adafruit_CharLCD_IPclock_example.py

# Making use of Adafruit's LCD python class which is also included in this directory (Adafruit_CharLCD.py).
# It should be saved in /home/pi or in any other location already in your python path.
# This code will automatically copy it to /home/pi for you if it isn't already there.
# Edit the class file to point to the correct GPIO pins which you used. Mine are set up as...
# The wiring for the LCD is as follows:
# 1 : GND
# 2 : 5V
# 3 : Contrast (0-5V)*
# 4 : RS (Register Select)
# 5 : R/W (Read Write)       - GROUND THIS PIN
# 6 : Enable or Strobe
# 7 : Data Bit 0             - NOT USED
# 8 : Data Bit 1             - NOT USED
# 9 : Data Bit 2             - NOT USED
# 10: Data Bit 3             - NOT USED
# 11: Data Bit 4
# 12: Data Bit 5
# 13: Data Bit 6
# 14: Data Bit 7
# 15: LCD Backlight +5V**
# 16: LCD Backlight GND
# GPIO pins used:
# LCD_RS = 20
# LCD_E  = 21
# LCD_D4 = 6
# LCD_D5 = 13
# LCD_D6 = 19
# LCD_D7 = 26

from subprocess import *
from time import sleep, strftime
from datetime import datetime
#from path import path
import signal
import sys
import os
import shutil
import RPi.GPIO as GPIO

#set to location of the downloaded lcd scripts
lcd_dir="/root/RaspPi/Setup/lcd"
#set to location of the downloaded hyperion scripts
hyperion_dir="/root/RaspPi/Setup/hyperion"
#set to location of the downloaded dht11 scripts
dht_dir="/root/RaspPi/Setup/dht11"


# Copy Adafruit's LCD class to /home/pi if not there already
if os.path.isfile("/home/pi/Adafruit_CharLCD.py"):
    print "Adafruit's LCD class already exists in /home/pi, not copying"
else:
    print "Copying Adafruit's LCD class to /home/pi"
    shutil.copy(lcd_dir+'/Adafruit_CharLCD.py','/home/pi/Adafruit_CharLCD.py')
   
from Adafruit_CharLCD import Adafruit_CharLCD

lcd = Adafruit_CharLCD()

# Output of this command will display on the LCD, change to eth0/wlan depending on use
cmd = "ip addr show | grep 192 | awk '{print $2}' | sort | cut -d/ -f1 | head -n 1"

# Set file locations of contents to read for display on LCD
# Set to file containing effect name
effectfile=hyperion_dir +"/hyperion_effect_scroll.effect"
# Set to file containing Temp & Humidity info
temphumfile=dht_dir+"/Temp_Hum.txt"

lcd.begin(16, 1)

def run_cmd(cmd):
    p = Popen(cmd, shell=True, stdout=PIPE)
    output = p.communicate()[0]
    return output

def main():
  # Set variable to allow rotating between messages every 'period' seconds.
  # I know this counter could totally have been done better but 
  # I'm brand new to python so this is the best I could 
  # come up with at short notice, I just wanted a quick 
  # and dirty way to counter display message every 3 seconds
  global counter
  counter = 0
  period = 3
  
  ipaddr = run_cmd(cmd)
  while 1:
    lcd.clear()
    
    # Print date/time on top row of LCD
    lcd.message(datetime.now().strftime('%b %d  %H:%M:%S\n'))
    
    # Rotate bottom row through different messages
    if (counter <= period):    
      
      # Get hyperion effect name
      if os.path.isfile(effectfile):
        effect = open(effectfile, 'r').read()
      else:
        effect = "No record found"
      
      lcd.message(effect)
      counter += 1
    elif (counter < (period*2)):
      # Display ip address
      lcd.message(ipaddr)
      counter += 1
    elif (counter < (period*3)):
      # Get temp humnidity info
      if os.path.isfile(temphumfile):
        temphum = open(temphumfile, 'r').read()
      else:
        temphum = "No temp found"
      
      lcd.message(temphum)
      counter += 1
    else:
      # Reset counter
      counter = 0
    sleep(1)
  
def stop():
  print "Pressed Ctrl+C, stopping cleanly."
  lcd.clear()
  GPIO.cleanup()
  
if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        stop()