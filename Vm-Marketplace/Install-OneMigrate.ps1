
Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $BlobPath,

         [Parameter(Mandatory=$true, Position=1)]
         [string] $StorageConnectionString,

         [Parameter(Mandatory=$true, Position=2)]
         [string] $DebugLog
    )

$BlobPath=$BlobPath.Replace('"',"")

# Check if Debug is true
if ($DebugLog -eq "true") {
    # Log the StorageConnectionString for debugging purposes
    Add-Content -Path C:\Temp\Log.txt -Value "BlobPath: $BlobPath"
    Add-Content -Path C:\Temp\Log.txt -Value "StorageConnectionString: $StorageConnectionString"
}


Install-WindowsFeature -Name Web-Server -IncludeManagementTools

# Create Temp directory if it doesn't exist
if (!(Test-Path -Path "C:\Temp")) {
    New-Item -ItemType Directory -Path "C:\Temp"
}

$WebappPath="C:\Temp\OneMigrate.zip"
$destinationPath = "C:\inetpub\wwwroot\"

# Download and copy to innetpub
Invoke-WebRequest -Uri $BlobPath -OutFile $WebappPath
Expand-Archive $WebappPath  -DestinationPath $destinationPath

# Path to the appsettings.json file
$appSettingsPath ="C:\inetpub\wwwroot\appsettings.json"

# Read and parse the JSON file
$appSettings = Get-Content -Path $appSettingsPath -Raw | ConvertFrom-Json

# Access specific values
$appSettings.StorageConnectionString= $StorageConnectionString

# Convert the updated object back to JSON
$jsonOutput = $appSettings | ConvertTo-Json -Depth 10 -Compress

# Save the updated JSON back to the file
$jsonOutput | Set-Content -Path $appSettingsPath

# Output a message
Write-Host "Appsettings.json updated successfully."


# Install .net 8
$dotneturl="https://download.visualstudio.microsoft.com/download/pr/4956ec5e-8502-4454-8f28-40239428820f/e7181890eed8dfa11cefbf817c4e86b0/dotnet-hosting-8.0.11-win.exe"
$dotnetTemp="C:\Temp\dotnet.exe"
Invoke-WebRequest -Uri $dotneturl -OutFile $dotnetTemp
Start-Process -FilePath $dotnetTemp -ArgumentList "/quiet", "/norestart" -Wait

Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
# Restart IIS
iisreset