
# Shell Scripts for managing macOS from Intune

Please refer to [Use shell scripts on macOS devices in Intune](https://learn.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) for details on how to deploy and use shell scripts.

- [Manage Local Admins](#manage-local-admins)

## Manage Local Admins

The script [ManageLocalAdmins.sh](/Scripts/macOS/ManageLocalAdmins.sh) will downgrade all user accounts to be Standard Users, removing local admin rights from all accounts.

To ensure you maintain admin access to the macOS environment, be sure to exclude the name of your desired local admin account. If you do not have one this script can be used to create one for you, but you **must** ensure you change the password after the script has been run.

The table below details the script variables to provide understanding of how it works.

| Variable                    | Purpose / Function |
|-----------------------------|--------------------|
| `LocalAdminAccountName`     |  The name of an account that should have local administrator privileges on the macOS system. An existing user account on the system with this username will not be modified by the script. Where `"CreateAdmin"` is set to **TRUE** a new admin account with this name will be created if the account does not already exist. **`Default value = "ITAdmin"`** |
| `LocalAdminAccountFullname` | Where `"CreateAdmin"` is set to **TRUE** the new admin account created will use this as the full name. **`Default value = "IT Admin"`** |
| `ABMCheck`                  | Specifies if the script should validate that the macOS executing the script is enrolled via Apple Business Manager (ABM). **TRUE** = The script will execute and make changes only where macOS is enrolled via ABM.  Where not ABM enrolled, the script will exit without making any changes. **FALSE** = The script will execute and attempt to make changes regardless of ABM enrolment status. **`Default value = TRUE`** |
| `CreateAdmin`               | Specifies if the script should create a new local admin account. **TRUE** = If an account does not already exist, a new admin account will be created based on the values of `LocalAdminAccountName` and `LocalAdminAccountFullname`. The password will be set to the devices serial number in uppercase. **Remember, you must login as this account and change the password after deploying this script.** Set as **FALSE** = No admin account will be created. **`Default value = FALSE`** |
| `LogOnly`                   | Specifies if the script should make changes or create the output logs only. **TRUE** = The script will not make any changes, but will output to the logfile what would happen. **FALSE** = The script will perform the changes and output to the logfile. **`Default value = TRUE`** |
| `LogAndMetaDir`             | Folder to store the log file. **`Default value = "/Library/Logs/IntuneScripts"`** |
| `LogFile`                   | Name of the log file. **`Default value = "$LogAndMetaDir/ManageLocalAdmins.log"`** |

### PLEASE NOTE
When scripting the creation of a new Admin account, unless this is done interactively the new account will NOT have a Secure Token. As per [Use secure token, bootstrap token and volume ownership in deployments](https://support.apple.com/en-gb/guide/deployment/dep24dbdcf9e/web), if an account is not granted a Secure Token at the time of creation, in macOS 11 or later, a local user logging in to a Mac computer is automatically granted a Secure Token during login if a bootstrap token is available from MDM. 

Given the expectation is that a Mac executing this script is Intune enrolled via ABM/ADE and you will be logging in afterwards to change the password, this should not be an issue.

For more information please see:
- https://www.hexnode.com/blogs/mac-secure-token-everything-it-admins-should-know/
- https://krypted.com/mac-security/using-sysadminctl-macos/ 
- https://blog.kandji.io/secure-token-bootstrap-token-mac-security 

### Example Screenshots

An example log file output where the script is being executed and a local admin account is being created.

![Example log output where the script is being executed and a local admin account is being created](/Scripts/Assets/ManageLocalAdmins/LogOutput1.png)

An example log file output of subsequent scripy executions where there are no changes being made to the specified local admin account.

![Example log output of subsequent scripy executions where there are no changes being made to the specified local admin account.](/Scripts/Assets/ManageLocalAdmins/LogOutput2.png)

