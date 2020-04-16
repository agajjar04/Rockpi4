#!/bin/sh

rfkill unblock all
ifconfig wlan0 up
iw dev wlan0 connect 'Internet hub jio'
killall wpa_supplicant
sleep 1
wpa_supplicant -i wlan0 -c wpa_supplicant.conf
udhcpc -i wlan0

# systemctl stop getty.target
# systemctl stop getty@ttymxc0.service
