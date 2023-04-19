#!/bin/sh

#This is used to install the Connectwise Command RMM tool onto MacOS 10.14+

#PPPC Payload for both ITSPlatform/RMM and Screenconnect/control must be deployed via MDM for successful install. 

#HOW TO USE:
    #Change RMM_pkg_name variable to the downloaded file name in ITSPortal. REPLACE ANY SPACES IN NAME WITH "%20"
        #Example: Company name is: Florida Company
        #RMM_pkg_name="Florida%20Company__macOS_ITSPlatform_TKN12345-6789123-456789.pkg"
    #Change installer link to the pkg copy url
        #Example: RMM_pkg_link="https://prod.setup.itsupport247.net/darwin/DPMA/64/RMM_pkg_name="florida%20company__macOS_ITSPlatform_TKN12345-6789123-456789/PKG/setup"
    #This control installer in MacOS 13 can be installed alongside to speed up install time and issues that come with it.
    #From the control dashboard, click build, select a site, select a type (MacOS .pkg), copy URL and past into $control_pkg_link
    

#############  Variables to set  #############
RMM_pkg_name="COPY ITS PLATFORM PORTAL **FILE** NAME HERE CHECK FOR SPACES"
RMM_pkg_link="COPY ITS PLATFORM PORTAL LINK HERE"
control_pkg_link="COPY CONNECTWISE CONTROL LINK HERE"

#############  Script Variables.  #############
log_file="/tmp/ST_RMM_Installer.log"
control_pkg_name="ConnectWiseControl.ClientSetup.pkg"
controlinstallation=/Applications/
controlinstallationstring="connectwisecontrol"
Connectwise_Agent=/opt/ITSPlatform/agentcore/platform-agent-core

echo "Running install script" | tee -a $log_file

# Check for root
if [ $EUID -ne 0 ]; then
    echo "not running as root" | tee -a $log_file 2>&1
    exit 1
fi

#Checking if RMM is installed
if [ -f "$Connectwise_Agent" ]; then
    echo "Connectwise Agent exists. Skipping install" | tee -a $log_file 2>&1
else 
    echo "Connectwise Agent does not exist. Attempting to install" | tee -a $log_file 2>&1
    #RMM was not detected, beginning installation
    #Make Temp Directory
    mkdir -p /tmp/temp
    #Go to temp directory
    cd /tmp/temp
    #Download installer and rename to provide token
    curl -o $RMM_pkg_name -f --connect-timeout 30 --retry 3 --retry-delay 30 -L -J -O "$RMM_pkg_link" | tee -a $log_file 2>&1
    if [ $? -ne 0 ]; then
        echo "Failed to download RMM" | tee -a $log_file 2>&1
    fi
    #Install downloaded RMM pkg 
    installer -allowUntrusted -verboseR -pkg $RMM_pkg_name -target / | tee -a $log_file 2>&1
    if [ $? -ne 0 ]; then
        echo "Failed to install RMM .pkg" | tee -a $log_file 2>&1
    fi
fi

#Checking if control component is installed
mdfind "kMDItemKind == 'Application'" | grep -iq "connectwisecontrol-"
if [ $? -ne 1 ]; then
    echo "Connectwise Control client exists. Skipping install" | tee -a $log_file 2>&1
else 
    echo "Could not find Connectwise Control client. Attempting install" | tee -a $log_file 2>&1
    #Connectwise control not detecting, beginning download. 
    #Make Temp Directory
    mkdir -p /tmp/temp
    #Go to temp directory
    cd /tmp/temp
    #Download connectwise package.
    curl -o $control_pkg_name -f --connect-timeout 30 --retry 3 --retry-delay 30 -L -J -O "$controllink" | tee -a $log_file 2>&1
    if [ $? -ne 0 ]; then
        echo "Failed to download connectwise control" | tee -a $log_file 2>&1
        exit 1
    fi
    #Install Connectwise Control Client
    installer -allowUntrusted -verboseR -pkg $control_pkg_name -target / | tee -a $log_file 2>&1
    if [ $? -ne 0 ]; then
        echo "Failed to install connectwise control client .pkg" | tee -a $log_file 2>&1
        exit 1
    fi
fi

#wait for installers to complete
sleep 900

#Cleanup
rm -rf /tmp/temp

exit 0