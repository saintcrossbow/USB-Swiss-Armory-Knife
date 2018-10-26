# USB Swiss Armory Knife
*An EDC security device for portable network and security testing*

The device at-a-glance:
* A Kali image for basic security testing tasks.
* Encrypted partition for findings; working filescopied  to and from a “burn basket” folder.
* Dual boot to quickly switch modes. Plugging in and out will toggle between two modes: from Kali to a variety of specialized utility modes:
* Responder. Places the USB armory act as a local USB network device to steal creds.
* Passive Network Discovery. Using Kismet and host mode, scans and logs networks for warwalking, wardriving, etc.
* Active Network Discovery and Attacks. Using besside-ng network keys are actively sought for later cracking in John. Specific IPs may be targeted
* Basic John password crack. Using Byepass and some specialized rules, a generalized (but non-optimized) attack is made on a password hash. 

Each of these modes are configurable with simple start commands.

This repository holds a guide on setting up a USB Armory into a InfoSec multitool as well as the scripts / configs to get you set up fast.
