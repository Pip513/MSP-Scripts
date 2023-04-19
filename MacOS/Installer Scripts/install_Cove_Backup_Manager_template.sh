#!/bin/sh

#This is used to install Cove Backup Manager onto MacOS 

#PPPC Payload for Cove Backup Manager must be deployed via MDM for successful install. 

#HOW TO USE:    

#############  Variables to set  #############
cove_pkg_name="#CHANGE TO PKG NAME"

#############  Script Variables.  #############
log_file="/tmp/ST_Cove_Installer.log"
cove_installation=/Applications/
cove_installation_string="Backup Manager"
cove_pkg_link="https://cdn.cloudbackup.management/maxdownloads/mxb-macosx-x86_64.pkg"


echo "Running install script" | tee -a $log_file

# Check for root
if [ $EUID -ne 0 ]; then
    logger "Fail, must be running as root"
    exit 1
fi

#Checking if Backup Manager application is installed
mdfind "kMDItemKind == 'Application'" | grep -iq "$cove_installation_string"
if [ $? -ne 1 ]; then
    echo "Backup Manager exists. Skipping install" | tee -a $log_file 2>&1
else 
    echo "Could not find Backup Manager. Attempting install" | tee -a $log_file 2>&1
    #Backup Manager not detecting, beginning download. 
    #Make Temp Directory
    mkdir -p /tmp/temp
    #Go to temp directory
    cd /tmp/temp
    #Download Backup Manager package.
    curl -o $cove_pkg_name -f --connect-timeout 30 --retry 3 --retry-delay 30 -L -J -O "$cove_pkg_link" | tee -a $log_file 2>&1
    if [ $? -ne 0 ]; then
        echo "Failed to download Backup Manager" | tee -a $log_file 2>&1
        exit 1
    fi
    #Install Connectwise Control Client
    installer -allowUntrusted -verboseR -pkg $cove_pkg_name -target / | tee -a $log_file 2>&1
    if [ $? -ne 0 ]; then
        echo "Failed to install Backup Manager .pkg" | tee -a $log_file 2>&1
        exit 1
    fi
fi

#wait for installers to complete
sleep 900

#Cleanup
rm -rf /tmp/temp

exit 0