#!/bin/bash
# Standard crack for an easy to medium password
# Will be placed in host payloads so device can be left in a plug overnight
# Typical formats: Raw-MD5, Raw-SHA1, wpapsk, nt
# Use john --list=formats to show the formats 
if [ "$1" == "" ]; then
  echo "John is identifying hash"
  john --wordlist=/usr/share/wordlists/rockyou.txt --rule=best126 /home/johnhost/target.txt > solved.txt
else
  echo "Using specified format: $1"
  john --wordlist=/usr/share/wordlists/rockyou.txt --rule=best126 --format=$1 /home/johnhost/target.txt > solved.txt
fi
# Stop LED to show complete
modprobe ledtrig_gpio
echo gpio >/sys/class/leds/LED/trigger


