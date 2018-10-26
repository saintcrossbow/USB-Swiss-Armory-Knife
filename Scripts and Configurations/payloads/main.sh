#!/bin/bash

#Copyright(C) 2018  saintcrossbow@gmail.com

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.If not, see http://www.gnu.org/licenses/

# Main call to payloads from rc.local on boot
logFile="/var/log/armory.log"

# Network interfaces; set to ON by setting value to 1
startWifi='0'
startEth='0'

# Determine what network we are going to use
value="$(</payloads/interface)"

# Start interface as needed
case $value in
  "wifi")
    echo "Wifi interface specified" >> $logFile
    startWifi='1'
    ;;
  "ether")
    echo "Ethernet interface specified" >> $logFile
    startEth='1'
    ;;
  *)
    echo "No interface specified" >> $logFile
    ;;
esac

# Specific mode settings
# John format - use empty to let John identify (not recommended) or use a
# standard format, e.g.: Raw-MD5, Raw-SHA1, wpapsk, nt
# Use john --list=formats to show the formats
if [ -f /payloads/johnformat ]
then
  johnHostFormat="$(</payloads/johnformat)"
else
  johnHostFormat=""
fi
echo "Initial john format set to: $johnHostFormat" >> $logFile

# Host startup
echo "Host mode started" > /root/last_host.txt
modprobe ledtrig_timer
echo timer >/sys/class/leds/LED/trigger

# Start up WiFi for those payloads that need them
if (((startWifi=='1'))); then
  ip addr flush wlan0
  systemctl restart networking
  ifup wlan0 >> $logFile
  ip addr show > /root/host_ip.last
fi

# Start up Ethernet (exclusive from Wifi)
if (((startEth=='1'))); then
  #cp /etc/network/interfaces.eth /etc/network/interfaces
  ip addr flush eth0
  systemctl restart networking
  ifup eth0 >> $logFile
  ip addr show > /root/host_ip.last
fi

value="$(</payloads/attack)"
echo "Attack set to: $value" >> $logFile
case $value in
  "kismet")
      # Kismet server start
      echo "$(date): starting Kismet" >> $logFile
      # Record wireless settings
      iwconfig 1> /kismet/wireless.txt 2>&1
      ifquery --list --allow=hotplug >> /kismet/wireless.txt

      # Try to get wlan0 up
      sleep 5
      ifup wlan0 1> /kismet/wlan0up.txt 2>&1

      # Start kismet headless
      /usr/bin/kismet_server --daemonize
    ;;
  "besside")
      # Besside attack everything and record caps for later crack
      # Logs are kept in home directory
      # Not the nicest thing to do. It can be limited by:
      # -b   Attacking a specific BSSID
      # -W   Attack only WPA
      # -c   Lock on specific channel
      # Extract using:
      # aircrack-ng -J filebase capturefile.cap
      # Besside server start
      echo "$(date): starting besside-ng" >> $logFile

      # Try to get wlan0 up
      sleep 5
      ifup wlan0 1> /kismet/wlan0up.txt 2>&1

      # Start besside
      if [ -f /payloads/nettarget ]
      then
        netTarget="$(</payloads/nettarget)"
        echo "$(date): besside target: $netTarget" >> $logFile
        besside-ng -b $netTarget wlan0
      else
        echo "$(date): besside target: all" >> $logFile
        besside-ng wlan0
      fi

      # If there are issues, shutdown and LED off
      sync
      modprobe ledtrig_gpio
      echo gpio >/sys/class/leds/LED/trigger
      sleep 1
      shutdown -P now
    ;;
  "tcpdump")
    echo "$(date): starting tcpdump" >> $logFile
    sleep 5
    ifup eth0 1> /home/loot/eth0up.txt 2>&1

    # Same as squirrel format - write for later analysis
    tcpdump -i eth0 -s0 -w /home/loot/tcpdump_$(date +%Y-%m-%d-%H%M%S).pcap &>/dev/null &


    # If issues, shutdown and LED off
    sync
    modprobe ledtrig_gpio
    echo gpio >/sys/class/leds/LED/trigger
    sleep 1
    shutdown -P now
    ;;
  "john")
    if [ "$johnHostFormat" == "" ]; then
      echo "John is identifying hash" >> $logFile
      john --wordlist=/usr/share/wordlists/rockyou.txt --rule=best126 /home/johnhost/target.txt >> /home/johnhost/solved.txt
    else
      echo "John is using $johnHostFormat" >> $logFile
      john --wordlist=/usr/share/wordlists/rockyou.txt --rule=best126 --format=$johnHostFormat /home/johnhost/target.txt >> /home/johnhost/solved.txt
    fi
    sync
    # Stop LED to show complete
    modprobe ledtrig_gpio
    echo gpio >/sys/class/leds/LED/trigger
    sleep 1
    shutdown -P now
    ;;
  *)
    echo No interface specified
    ;;
esac

