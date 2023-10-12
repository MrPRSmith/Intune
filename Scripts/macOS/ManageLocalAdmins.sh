#!/usr/bin/env bash
#set -x

############################################################################################
##
## Script to downgrade all users to Standard Users
##
############################################################################################

##
##  Initial idea taken from https://github.com/microsoft/shell-intune-samples/tree/master/macOS/Config/Manage%20Accounts
## 
##
##  PLEASE NOTE:
##
##  1. This script can set all existing Admin accounts to be Standard user accounts. 
##  2. If no local Admin accounts exist or will be created, you could leave the system without any Admin accounts.
##  3. The account specified in the LocalAdminAccounName variable will not be changed if it is found to exist.
##  4. If you choose to create a new Admin account, remember to change the password afterwards.
##  5. Changes to a user account already logged on will take effect on their next log on.
##
##  WARNING: 
## 
##  !! This script could leave your Mac will no Admin accounts configured or with an easy to guess Admin account password !!


# Variables - Customise as you require

LocalAdminAccounName="localadmin"       # This is the account name of the local Admin 
LocalAdminAccounFullname="Local Admin"  # This is the full name to use for the new Admin account (if to be created)
ABMCheck=true                           # True = Only perform script actions if the Mac is ABM managed
CreateAdmin=false                       # True = Create a local Admin account but only if LogOnly=False
LogOnly=true                            # True = the script will not make any changes

LocalAdminAccounNameExists=false        # DO NOT CHANGE.

ScriptName="Manage Local Admins"        # Name of the Script

LogAndMetaDir="/Library/IntuneScripts"          # Log folder path
LogFile="$LogAndMetaDir/ManageLocalAdmins.log"  # Log name

## Check if the log directory has been created and start logging
if [ -d $LogAndMetaDir ]; then
    ## Already created
    echo "# $(date) | Log directory already exists - $LogAndMetaDir"
else
    ## Creating Metadirectory
    echo "# $(date) | creating log directory - $LogAndMetaDir"
    mkdir -p $LogAndMetaDir
fi

# START LOGGING

exec 1>> $LogFile 2>&1

echo ""
echo "##############################################################################"
echo "# $(date) | Starting $ScriptName"
echo "##############################################################################"
echo ""

# Is this a ABM DEP device?
if [ "$ABMCheck" = true ]; then
  echo "Checking MDM Profile Type"
  profiles status -type enrollment | grep "Enrolled via DEP: Yes"
  if [ ! $? == 0 ]; then
    echo "This device is not ABM managed"
    echo "Script execution complete"
    exit 0;
  else
    echo "This device is ABM Managed"
  fi
fi

# Downgrade all accounts to being a Standard user
echo "Changing all local accounts to be Standard users (with the exception of $LocalAdminAccounName)"
while read UserAccount; do
    if [ "$UserAccount" == "$LocalAdminAccounName" ]; then
        if [ $LogOnly = true ]; then
            # Log Only - Make no Change
            echo "Report Only. Script would leave $LocalAdminAccounName account as Admin"
        else
            # Make the change
            echo "Leaving $LocalAdminAccounName account as Admin. No changes have been made to this account"
        fi
        LocalAdminAccounNameExists=true
    else        
        if [ $LogOnly = true ]; then
            # Log Only - Make no Change
            echo "Report Only. Script would make $UserAccount a Standard user (Admin rights to be removed)"
        else
            # Make the change
            echo "Making $UserAccount a Standard user (Admin rights to be removed)"
            /usr/sbin/dseditgroup -o edit -d $UserAccount -t user admin
        fi
    fi
  done < <(dscl . list /Users UniqueID | awk '$2 >= 501 {print $1}')

# Create a local Admin account if one does not already exist.
# CAUTION REQUIRED. The default passsword will be the devices serial number. Log in and change accordingly afterwards if this feature is used.
if [ "$CreateAdmin" = true ] && [ $LocalAdminAccounNameExists = false ]; then
    if [ $LogOnly = true ]; then
        # Log Only - Make no Change
        echo "Report Only. Script would create a new local Admin account $LocalAdminAccounName ($LocalAdminAccounFullname)"
    else   
        echo "Creating a new local Admin account $LocalAdminAccounName ($LocalAdminAccounFullname)"
        p=`system_profiler SPHardwareDataType | awk '/Serial/ {print $4}' | tr '[A-Z]' '[K-ZA-J]' | tr 0-9 4-90-3`
        waitforSetupAssistant
        echo "Adding $LocalAdminAccounName to hidden users list"
        sudo defaults write /Library/Preferences/com.apple.loginwindow HiddenUsersList -array-add "$LocalAdminAccounName"
        sudo sysadminctl -deleteUser "$LocalAdminAccounName" # Removes the existing admin account if it exists
        sudo sysadminctl -adminUser "$LocalAdminAccounName" -adminPassword "$p" -addUser "$LocalAdminAccounName" -fullName "$LocalAdminAccounFullname" -password "$p" -admin
    fi
fi

if [ "$CreateAdmin" = true ] && [ $LocalAdminAccounNameExists = true ]; then
    echo "Skipping the creation of $LocalAdminAccounName as it already exists. No changes have been made"
fi  

# END
echo "Script execution complete"