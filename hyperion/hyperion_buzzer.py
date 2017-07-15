#!/usr/bin/python

# Note that this functionality is entirely pointless and I just did it to learn more about 
# wiring things up to the Pi and making them work with python scripts.
# I used an active buzzer which came with a Sunfounder Raspbery Pi starter kit.
# Connect positive from buzzer to gpio pin 18 and negative to any ground pin.
# The buzzer's volume can be adjusted with a resistor in series. I suggest you play 
# about with which one you want to use but I tried a 1K ohm to good effect.

# Tweaked from here: http://www.linuxcircle.com/2015/04/12/how-to-play-piezo-buzzer-tunes-on-raspberry-pi-gpio-with-pwm/

# Note that we use GPIO numbering for pins by setting this below: GPIO.setmode(GPIO.BCM)
# You could use board numbering by setting: GPIO.setmode(GPIO.BOARD)
# More info at: https://raspberrypi.stackexchange.com/questions/12966/what-is-the-difference-between-board-and-bcm-for-gpio-pin-numbering

import RPi.GPIO as GPIO   #import the GPIO library
import time               #import the time library
from sys import argv      #to get command line arguements


class Buzzer(object):
 def __init__(self):
  GPIO.setmode(GPIO.BCM)  
  self.buzzer_pin = 16 #set to GPIO pin 
  GPIO.setup(self.buzzer_pin, GPIO.IN)
  GPIO.setup(self.buzzer_pin, GPIO.OUT)
  #print("buzzer ready")
  
 def __del__(self):
  class_name = self.__class__.__name__
  #print (class_name, "finished")

 def buzz(self,pitch,duration):   #create the function "buzz" and feed it the pitch and duration)
 
  if(pitch==0):
   time.sleep(duration)
   return
  period = 1.0 / pitch     #in physics, the period (sec/cyc) is the inverse of the frequency (cyc/sec)
  delay = period / 2     #calcuate the time for half of the wave  
  cycles = int(duration * pitch)   #the number of waves to produce is the duration times the frequency

  for i in range(cycles):    #start a loop from 0 to the variable "cycles" calculated above
   GPIO.output(self.buzzer_pin, True)   #set pin to high
   time.sleep(delay)    #wait with pin high
   GPIO.output(self.buzzer_pin, False)    #set pin to low
   time.sleep(delay)    #wait with pin low

 def play(self, tune):
  GPIO.setmode(GPIO.BCM)
  GPIO.setup(self.buzzer_pin, GPIO.OUT)
  x=0

  #print("Playing tune ",tune)
  if(tune==1):
    pitches=[262,294,330,349,392,440,494,523, 587, 659,698,784,880,988,1047]
    duration=0.1
    for p in pitches:
      self.buzz(p, duration)  #feed the pitch and duration to the function, "buzz"
      time.sleep(duration *0.5)
    for p in reversed(pitches):
      self.buzz(p, duration)
      time.sleep(duration *0.5)

  elif(tune==2):
    pitches=[262,330,392,523,1047]
    duration=[0.2,0.2,0.2,0.2,0.2,0,5]
    for p in pitches:
      self.buzz(p, duration[x])  #feed the pitch and duration to the function, "buzz"
      time.sleep(duration[x] *0.5)
      x+=1
  elif(tune==3):
    pitches=[392,294,0,392,294,0,392,0,392,392,392,0,1047,262]
    duration=[0.2,0.2,0.2,0.2,0.2,0.2,0.1,0.1,0.1,0.1,0.1,0.1,0.8,0.4]
    for p in pitches:
      self.buzz(p, duration[x])  #feed the pitch and duration to the func$
      time.sleep(duration[x] *0.5)
      x+=1

  elif(tune==4):
    pitches=[1047, 988,659]
    duration=[0.1,0.1,0.2]
    for p in pitches:
      self.buzz(p, duration[x])  #feed the pitch and duration to the func$
      time.sleep(duration[x] *0.5)
      x+=1

  elif(tune==5):
    pitches=[1047, 988,523]
    duration=[0.1,0.1,0.2]
    for p in pitches:
      self.buzz(p, duration[x])  #feed the pitch and duration to the func$
      time.sleep(duration[x] *0.5)
      x+=1

  elif(tune==6):
    pitches=[1400]
    duration=[0.1]
    for p in pitches:
      self.buzz(p, duration[x])  #feed the pitch and duration to the func$
      time.sleep(duration[x] *0.5)
      x+=1
      
  GPIO.setup(self.buzzer_pin, GPIO.IN)

if __name__ == "__main__":
  # This line allows user selection of the tunes above. I'm commenting out 
  # and setting tune = 6 for my own user defined 'tune'.
  #a = input("Enter Tune number 1-5:")
  if len(argv) == 1:
    tunes = 6
  else:
    firstarg = argv[1]

  print "Playing tune defn: ",tunes
  GPIO.setwarnings(False)
  buzzer = Buzzer()
  buzzer.play(int(tunes))
