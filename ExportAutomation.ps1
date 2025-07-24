# Intune reports and properties available using Graph API
# https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/reports-export-graph-available-reports


# Connect to Graph using System Managed Identity
Connect-MgGraph -Identity -NoWelcome

# Connect to Azure using System Managed Identity
Connect-AzAccount -Identity

# Create report request body as PS Object
$requestBody = @{
    reportName = "Devices"
    select = @(
        "DeviceId"
        "DeviceName"
        "SerialNumber"
        "ManagedBy"
        "Manufacturer"
        "Model"
        "GraphDeviceIsManaged"
    )
}

# Convert PS Object to JSON object
$requestJSONBody = ConvertTo-Json $requestBody

# Request the report
$reportRequest = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/deviceManagement/reports/exportJobs" -Body $requestJSONBody -ContentType "application/json"

# Check if the report request was successful
if (-not ($null -eq $reportRequest))
{
    # Grab the request ID from the response
    $reportID = $reportRequest.id

    # Wait for the report to be generated
    Write-Output ("Waiting for the report " + $reportID + " to be generated...")
    do {
        $Report = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/reports/exportJobs('$reportID')" -ContentType "application/json" 
        Start-Sleep -Seconds 10
    } while ($Report.status -ne "completed")

    # Download the report - its a ZIP file
    Invoke-WebRequest -Uri $Report.url -OutFile $env:TEMP"\report.zip"

    # Save file to Azure Blob storage in context of the System Managed Identity
    $stRG = "RG-INTUNE"                    # Resource Group
    $stName = "st"       # Storage Account Name
    $stContainer = "reports"            # Container Name

    #Get Storage Account
    $st = Get-AzStorageAccount -ResourceGroupName $stRG -Name $stName

    # Generate new filename for ZIP
    $fileName = (Get-Date -Format yyyy-MM-dd-hhmmss).ToString() + ".zip"

    # Upload to Storage Account
    Set-AzStorageBlobContent -File $env:TEMP"\report.zip" -Container $stContainer -Blob $fileName -Context $st.Context

    # FOR LATER EDITION

    # Extract ZIP
    #Expand-Archive -LiteralPath $env:TEMP"\report.zip" -DestinationPath $env:TEMP

    # Output content to validate
    #Get-Content $env:TEMP"\"$reportID".csv"
}
