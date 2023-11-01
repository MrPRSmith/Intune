Start-Transcript -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\OA3xOriginalProductKey.log" -Append

Write-Host "-----------------------------------------------------------------------------------------------------------"
Write-Host "If you are running Windows 10, version 1803 or later, Subscription Activation will automatically pull"
Write-Host "the firmware-embedded Windows 10 activation key and activate the underlying Pro License. The license"
Write-Host "will then step-up to Windows 10/11 Enterprise using Subscription Activation. This automatically migrates"
Write-Host "your devices from KMS or MAK activated Enterprise to Subscription activated Enterprise."
Write-Host ""
Write-Host "If the computer has never been activated with a Pro key, this will not happen automatically. This script"
Write-Host "will resolve the issue by extracting the Windows product key from the firmware and applying it."
Write-Host ""
Write-Host "For more information please refer to the following link:"
Write-Host "https://docs.microsoft.com/en-us/windows/deployment/windows-10-subscription-activation"
Write-Host "-----------------------------------------------------------------------------------------------------------"

# Get current system licencing information
$SoftwareLicensingProduct = Get-WmiObject SoftwareLicensingProduct -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f' AND PartialProductKey <> null" | Select-Object Name, Description, LicenseStatus, PartialProductKey
$LicenseStatus = switch ($SoftwareLicensingProduct.LicenseStatus) {    
    0 {"Unlicensed"}
    1 {"Licensed"}
    2 {"Out-Of-Box Grace Period"}
    3 {"Out-Of-Tolerance Grace Period"}
    4 {"Non-Genuine Grace Period"}
    5 {"Notification"}
    6 {"Extended Grace"}
    default {"Unknown value"}
}

# Get Computer System Information
$ComputerSystem = $(Get-WmiObject win32_computersystem)

# Get firmware-embedded Product Key
$FirmwareProductKey = $(Get-WmiObject SoftwareLicensingService).OA3xOriginalProductKey

# Determine if system is a VM or Physical
$IsVirtual = ($ComputerSystem.Model -eq 'VMware Virtual Platform' -or $ComputerSystem.Model -eq 'Virtual Machine')

# Output details to transcript
Write-Host ""
Write-Host "Computer Name:" $ComputerSystem.Name
Write-Host "Windows Licensing Status"
Write-Host " -> Name:" $SoftwareLicensingProduct.Name
Write-Host " -> Description:" $SoftwareLicensingProduct.Description
Write-Host " -> Activation Status:" $SoftwareLicensingProduct.LicenseStatus - $LicenseStatus
Write-Host " -> PartialProductKey:" $SoftwareLicensingProduct.PartialProductKey

If (!$IsVirtual) {
    # System executing the script is NOT a Virtual Machine (VM)
    foreach ($ProductKey in $FirmwareProductKey) {                  
        Write-Host " -> Key from Firmware:" $ProductKey
        Write-Host ""
        If($ProductKey.Length -gt 25) {
            # Product Key found in Firmware
            If($SoftwareLicensingProduct.PartialProductKey -eq $ProductKey.Substring($ProductKey.Length - 5, 5)) {
                # The Product Key in Firmware matches what has already been applied
                Write-Host "The firmware-embedded Product Key has already been applied. No changes have been made and no action is required."
            }
            elseif ($SoftwareLicensingProduct.PartialProductKey -eq "3V66T") {
                # The last 5 charcters of $ProductKey ARE the generic 3V66T Actived Windows "Pro" Edition
                Write-Host "The Partial Product Key is as expected. No changes have been made and no action is required." 
            }
            Else {
                # Apply the Product Key found in Firmware to the OS
                Write-Host "Installing Product Key:" $ProductKey
                &cscript.exe $env:windir\system32\slmgr.vbs /ipk $ProductKey
            }            
        }
        else {
            # No Product Key found in Firmware
            Write-Host "!! ERROR !! No firmware-embedded Product Key Present. No changes have been made as no action is possible."
        }
    }   
}
else {
    Write-Host "This system is a Virtual Machine. No firmware-embedded Product Key available. No action taken or required."
}

Write-Host ""
Stop-Transcript
