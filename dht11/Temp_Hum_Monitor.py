#!/usr/bin/python

#Before using this you need to install the Adafruit DHT library. Open a terminal, change directory to the Adafruit
#folder and run these commands...
#sudo apt-get update
#sudo apt-get install build-essential python-dev
#sudo python setup.py install

# This script simply runs another python script (Temp_Hum.py) every 30s to get current temp and humidity and output to a txt file.
# The GPIO pin settings are in the other script. For reference we are connecting '+' to 3.3v, '-' to GND, and '~' to pin 4.
# Add to rc.local or equivalent to run at boot: 

from subprocess import *
from time import sleep
import io

#set cmd to run:
cmd="/usr/bin/python /root/RaspPi/Setup/dht11/Temp_Hum.py"
#set file to output result to
outputfile="/root/RaspPi/Setup/dht11/Temp_Hum.txt"

def run_cmd(cmd):
    p = Popen(cmd, shell=True, stdout=PIPE)
    output = p.communicate()[0]
    return output

def main():
  while 1:
    temp_hum = run_cmd(cmd).rstrip()
    print temp_hum
    # Write LED off to file for display on LCD if in use
    f = io.open( outputfile, 'wb' )
    f.truncate()
    f.write(temp_hum)
    f.close()
    sleep(30)

def stop():
  print "Pressed Ctrl+C, stopping cleanly."

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        stop()
