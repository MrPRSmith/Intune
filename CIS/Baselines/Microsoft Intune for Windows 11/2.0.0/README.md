# CIS Intune for Windows 11 v2.0.0

Please refer to https://learn.microsoft.com/en-us/autopilot/policy-conflicts for details on potential Autoplot conflicts as some policy setting may need relaxing to support your scenario.

## Issues

The table below captures any issues I have witnessed and my resolution.

| Isssue                                      | Resolution         |
|---------------------------------------------|--------------------|
|During user driven Autopilot as the process transitions from device configuration to user configuration there is a prompt to press CTRL-ALT-DEL and sign-in. After entering credentials, the Autopilot process attempts to begin again and then stops with an error stating a device already exits. A Windows reinstallation is required to recover.| Remove 18.5.1 (L1) Ensure 'MSS: (AutoAdminLogon) Enable Automatic Logon (not recommended)' is set to 'Disabled' (Automated) from the Windows [CIS Intune for Windows 11 v2.0.0] - 18. Administrative Templates (Computer) (L1) policy configuration.