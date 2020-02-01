#!/bin/bash
#***************************************************************************************************************#
# This Script uses iptables to block all traffic except to and from the IP of the selected VPN.			#
# When disconnected it asks if the normal setting shall be restore again.					#
#														#
# In case you want to manually restore the settings run 'iptables-restore iptables_BackUp_temp' (file is 	#
# located in the user directory).										#
#														#
# This script uses 'dns_nordvpn_0.sh', 'dns_nordvpn_1.sh', 'ipv6_diable.sh' and 'ipv6_enable.sh'.		#
#***************************************************************************************************************#

# Setting up paths
USER="tobias"
PATH_USER="/home/$USER"
PATH_OVPN="/home/$USER/.ovpn"

# Check if run as root
if [ $(id -u) -ne 0 ]; then
	echo "Please run as root!"
	exit
fi

# Set DNS servers and disable ipv6
dns_nordvpn_1.sh
ipv6_disable.sh

# Get and print local network IP range
LOCAL_IPS=$(ip a | awk '/inet 192.*/ {print $2}' | awk -F'.' '{print $1"."$2"."$3".0/24"}')
echo "Local network IP range is: $LOCAL_IPS"

read -p "Enter NordVPN server to connect to (e.g. de33): " VPN_ID
read -p "Enter connection protocol (tcp/udp, only lower case letters!) [default: tcp]: " VPN_PROTOCOL

if [ -z $VPN_PROTOCOL ]; then
	VPN_PROTOCOL="tcp"
fi

# Get VPN
VPN_IP=$(awk '/remote / {print $2}' $PATH_OVPN/$VPN_PROTOCOL/$VPN_ID.nordvpn.com.$VPN_PROTOCOL.ovpn)

# Backup current iptables config
iptables-save -f $PATH_USER/iptables_BackUp_temp

# Flush iptables
iptables -F

# Allow loopback device (internal communication)
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow all local traffic.
iptables -A INPUT -s $LOCAL_IPS -j ACCEPT
iptables -A OUTPUT -d $LOCAL_IPS -j ACCEPT

# Allow traffic to VPN
iptables -A INPUT -s $VPN_IP -j ACCEPT
iptables -A OUTPUT -d $VPN_IP -j ACCEPT

# Allow traffic to NordVPN DNS servers (Does not seem to be nescessary)
#iptables -A INPUT -s 103.86.96.100 -j ACCEPT
#iptables -A OUTPUT -d 103.86.96.100 -j ACCEPT
#iptables -A INPUT -s 103.86.99.100 -j ACCEPT
#iptables -A OUTPUT -d 103.86.99.100 -j ACCEPT

# Accept all TUN connections (tun = VPN tunnel)
iptables -A OUTPUT -o tun+ -j ACCEPT
iptables -A INPUT -i tun+ -j ACCEPT

# Set default policies to drop all communication unless specifically allowed
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Connect to VPN
openvpn $PATH_OVPN/$VPN_PROTOCOL/$VPN_ID.nordvpn.com.$VPN_PROTOCOL.ovpn

# Ask if setting shall be restored
echo "Disconnected from VPN!"
read -p "Shall traffic be allowed again? [y/N]" restore

if [[ "$restore" == "y" || "$restore" == "Y" ]]; then

	iptables-restore $PATH_USER/iptables_BackUp_temp
	dns_nordvpn_0.sh
	ipv6_enable.sh

	echo "All settings restored and normal traffic allowed again!"
else

	echo "Keep traffic forbidden!"

fi
