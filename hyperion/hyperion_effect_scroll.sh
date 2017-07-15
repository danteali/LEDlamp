#!/bin/bash
# Note important to use #!/bin/bash above instead of /bin/sh as setting the effect array below
# will only work if this script is run by bash.

# This script will rotate through the hyperion effects defined in the $EFFECTARR array below.
# It will start at the last used effect if you have rebooted since last use by looking for the
# temp file set in your rc.local file.
# If you have different effects or have added custom ones then amend the array definition below.

# This script can be run without arguments to rotate through the effects in order. By passing
# the argument 'down' you can scroll back to the previous effect. This is how the rotary encoder
# changes the effects. ['up' is not passed as this is the default behaviour of this script.]
# Note that pressing the encoder button turns on/off the effects and uses the same reboot 'flag' file
# noted below to enable picking up at the same effect it finished with.

# This script can be called in a number of ways...
# 1. Just run it from the command line
# 2. Using the 'hyperion_button_monitor.py' python script which starts running at boot time if you
#    followed that part of the set up guide. Pushing the button will trigger this script to scroll
#    to the next effect.
# 3. Using the 'hyperion_rotary_encoder.py' python script which starts at boot time if you
#    followed that part of the set up guide. Rotating the encoder will change the effect by passing
#    arguements to this script.
# Or you could write a simple web page with a button to trigger the script. It's pretty easy, just
# google 'raspberry pi run command from web page cgi-bin'

# Also, just for my own amusement (and cause I'm trying to teach myself to use various components)
# I connected up a buzzer and wrote a script to play a noise. The buzzer script is called at the bottom
# of this script. Please comment it out (if I haven't already) as it can get super annoying!
# Or just don't connect a buzzer, the buzzer script will run just fine with no buzzer connected so
# should be no problem.

# Allow easy changing of output text colour using these:
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

# Set this to the directory you have downloaded the git  project to, where the 'hyperion_button_monitor.py'
# and 'hyperion_effect_scroll.mem' files are.
HOME_DIR="/home/pi"
SETUP_DIR="$HOME_DIR/Setup/Guides"
HYPERION_DIR="$SETUP_DIR/hyperion"

echo -e "\n${green}<<<< HYPERION EFFECT ROTATOR >>>>\n${reset}"

# We use 'hyperion_effect_scroll.mem' to store the last used effect reference number.
# If it doesn't exist this will create one.
if [ ! -f $HYPERION_DIR/hyperion_effect_scroll.mem ]; then
  echo -e "Creating effect 'memory' file to store last used effect number"
  echo 0 > $HYPERION_DIR/hyperion_effect_scroll.mem
fi
EFFECT=$(cat $HYPERION_DIR/hyperion_effect_scroll.mem)
echo -e "Last used effect was number $EFFECT\n"

# Make array with all effects. You can find this list by running: 'hyperion-remote --list'
# Note also that the effect definition files are stored in '/opt/hyperion/effects'.
# You can check this folder to make sure below effect list is still accurate or in
# case any have been added to hyperion since this script was created.
#
# Effect list:
#"Knight rider"
#"Blue mood blobs"
#"Cold mood blobs"
#"Full color mood blobs"
#"Green mood blobs"
#"Red mood blobs"
#"Warm mood blobs"
#"Rainbow mood"
#"Rainbow swirl fast"
#"Rainbow swirl"
#"Snake"
#"Strobe blue"
#"Strobe Raspbmc"
#"Strobe white"
#"Cinema brighten lights"
#"Cinema dim lights"
#"Police Lights Single"
#"Police Lights Solid"
#"Random"
#"Running dots"
#"System Shutdown"
#"Sparks Color"
#"Sparks"
#"Color traces"
#"UDP multicast listener"
#"UDP listener"
#"X-Mas"
# Note: 'Strobe white' causes my pi to crash, i think it's due to power draw
# of LEDs (white draws the most power) so I won't use it. It would probably
# work fine if you were powering the LEDs from a dedicated source and not off
# the pi's 5v rail.
# I have set the 1st and second effects to 'off' and 'default'. I want
# 'effects off' to be one of the options as I scroll through. I also have a
# 'default' colour which I want to be included as one of my options. Feel free
# to tailor as you see fit.

declare -a EFFECTARR=(
  "off"
  "default"
  "Knight rider"
  "Blue mood blobs"
  "Cold mood blobs"
  "Full color mood blobs"
  "Green mood blobs"
  "Red mood blobs"
  "Warm mood blobs"
  "Rainbow mood"
  "Rainbow swirl fast"
  "Rainbow swirl"
  "Snake"
  "Strobe blue"
  "Strobe Raspbmc"
  "Cinema brighten lights"
  "Cinema dim lights"
  "Police Lights Single"
  "Police Lights Solid"
  "Random"
  "Running dots"
  "System Shutdown"
  "Sparks Color"
  "Sparks"
  "Color traces"
  "X-Mas" )

# Print effect list
echo "Effect List..."
j=0
for i in "${EFFECTARR[@]}"
do
   echo -e "$j: $i"
   j=$(expr $j + 1 )
done
echo ""

# Check for 'antic' argument passed by rotary encoder script. Amend $EFFECT to adjust for backwards rotation. Clockwise triggers is default action of moving to next effect
# if needed.
if [ $# -eq 0 ]; then
  echo -e "${red}No arguments supplied, progressing to next effect.\n${reset}"
elif [ $1 == "antic" ]; then
  echo -e "${red}Rotating to previous effect\n${reset}"
  if [ $EFFECT = 0 ]; then
    EFFECT=$(( ${#EFFECTARR[@]} - 2 ))    # Go back to end of list instead of using negative numbers. Note that negaitive numbers will still actually work given how array references function.
  else
    EFFECT=$(expr $EFFECT - 2 )    # Remember this gets increased by 1 later so need to take off 2 here
  fi
else
  echo -e "${red}Argument passed but not recognised\n${reset}"
fi

# Check for reboot 'flag' file so allow resume at last effect. This was set in
# your rc.local file if you added the command detailed at the end of
# 'hyperion_setup.sh'
# The rotary encoder script also uses this 'flag' file to enable the ability to
# pick up at the last effect used when clicking the button to turn on and off.
# If no reboot flag then increment effect by one to loop to next effect. Then
# write new effect to file.
# If no reboot flag then increment effect number by one and write back to
# storage file.
if [ -f /home/pi/hyperion.boot ]; then
  echo -e "Loading effect used before reboot/encoder-click-off, effect number $EFFECT\n"
  rm /home/pi/hyperion.boot  # Remove 'temp' file
else
  EFFECT=$(expr $EFFECT + 1 )
  echo -e "Loading effect number $EFFECT...\n"
  # Loop back to 0 once last effect is reached (using array length)
  if [ $EFFECT = ${#EFFECTARR[@]} ]; then
    EFFECT=0
    echo -e "Looping back to first effect, number $EFFECT...\n"
  fi
  echo -e $EFFECT > $HYPERION_DIR/hyperion_effect_scroll.mem
fi

# Start effects...
# The first one is just clearing all effects and colours from the
# LEDs. I want that as one of the options as I scroll through. The
# second is a 'default' colour which I like. It is the same colour
# as I set when the pi first boots. Change as you see fit - it's your pi!
if [ $EFFECT = 0 ]; then
  echo -e "${green}Turning off effects...\n${reset}"
  echo -e "======================\n"
  hyperion-remote --clearall
  echo -e "0.LEDs off" > $HYPERION_DIR/hyperion_effect_scroll.effect
elif [ $EFFECT = 1 ]; then
  echo -e "${green}Setting default colour: whitey-blue\n${reset}"
  echo -e "===================================\n"
  hyperion-remote --color A5EFFA
  echo -e "1.Default Colour" > $HYPERION_DIR/hyperion_effect_scroll.effect
else
  # Get effect from array to echo out
  EFFECT_NAME=${EFFECTARR[$EFFECT]}
  # Start effect
  echo -e "${green}Loading \"$EFFECT_NAME\"\n${reset}"
  echo -e "==========================================================\n"
  hyperion-remote --effect "$EFFECT_NAME"
  # Write effect name to file to display on LCD if being used
  echo -e "$EFFECT.$EFFECT_NAME" > $HYPERION_DIR/hyperion_effect_scroll.effect
fi

# This calls the script to play the buzzer every time you change effects
echo "Bleep!"
echo -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
echo -e "==========================================================\n\n"
python $HYPERION_DIR/hyperion_buzzer.py


