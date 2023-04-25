#!/bin/bash
YELLOW='\033[33m'
GREEN='\033[32m'
RESET='\033[0m'

# Check if csf is installed and uninstall if it is
if [ -f "/etc/csf/csf.conf" ]; then
    echo -e "${YELLOW} found. Uninstalling...${RESET}"
    cd /etc/csf
    sh uninstall.sh  > /dev/null 2>&1
fi

# Install csf if it is not installed
if ! [ -f "/etc/csf/csf.conf" ]; then
    echo -e "\e[32mCSF not found. Installing...\e[0m"
    cd /usr/src
    rm -fv csf.tgz
    wget https://download.configserver.com/csf.tgz
    tar -xzf csf.tgz
    cd csf
    sh install.sh  > /dev/null 2>&1
fi

# Get port number from user input
read -p "Enter port number to open: " PORT

# Disable csf testing
sed -i "s/TESTING = \"1\"/TESTING = \"0\"/g" /etc/csf/csf.conf

# Set RESTRICT_SYSLOG to 3
sed -i "s/RESTRICT_SYSLOG = \"0\"/RESTRICT_SYSLOG = \"3\"/g" /etc/csf/csf.conf

# Open port for incoming TCP traffic
sed -i "/^TCP_IN = /s/$PORT //g" /etc/csf/csf.conf

# Open port for outgoing TCP traffic
sed -i "s/TCP_OUT = \"20,21,22,25,53,853,80,110,113,443,587,993,995,2222\"/TCP_OUT = \"20,21,22,25,53,853,80,110,113,443,587,993,995,2222,$PORT\"/g" /etc/csf/csf.conf

# Update SSH port
/bin/sed -i "s/#Port 22/Port $PORT/g" /etc/ssh/sshd_config
/bin/sed -i "s/Port 22/Port $PORT/g" /etc/ssh/sshd_config

# Restart SSH
service sshd restart

# Restart csf
csf -r

echo -e "${YELLOW} $PORT opened successfully.${RESET}"
