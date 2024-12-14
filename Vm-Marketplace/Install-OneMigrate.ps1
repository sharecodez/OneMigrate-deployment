# Path to the RuntimeSettings file
$runtimeSettingsPath = "C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\"

# Get the first file with a specific extension (.settings)
$files = Get-ChildItem -Path $runtimeSettingsPath -File -Recurse | Where-Object { $_.Extension -eq '.settings' } | Select-Object -First 1

$settingFile = ""
# Output the file path
$files | ForEach-Object { $settingFile = $_.FullName }

Write-Host "Found file: $settingFile"

# Ensure the RuntimeSettings file exists
if (Test-Path $settingFile) {
    # Load the runtime settings from the file
    $runtimeSettings = Get-Content -Path $settingFile | ConvertFrom-Json

    # Extract protected settings from the JSON
    $publicSettings = $runtimeSettings.runtimeSettings[0].handlerSettings.publicSettings

    # Extract specific settings (storageAccountKey, blobPath)
    $storageConnectionString = $publicSettings.storageConnectionString
    $blobPath = $publicSettings.blobPath
    $debugLog = $publicSettings.debugLog
    
    # Check if Debug is true
    if ($debugLog -eq "true") {
        # Log the StorageConnectionString for debugging purposes
        Add-Content -Path C:\Temp\Log.txt -Value "BlobPath: $blobPath"
        Add-Content -Path C:\Temp\Log.txt -Value "StorageConnectionString: $storageConnectionString"
    }


    Install-WindowsFeature -Name Web-Server -IncludeManagementTools

    # Create Temp directory if it doesn't exist
    if (!(Test-Path -Path "C:\Temp")) {
        New-Item -ItemType Directory -Path "C:\Temp"
    }

    $WebappPath="C:\Temp\OneMigrate.zip"
    $destinationPath = "C:\inetpub\wwwroot\"

    # Download and copy to innetpub
    Invoke-WebRequest -Uri $blobPath -OutFile $WebappPath
    Expand-Archive $WebappPath  -DestinationPath $destinationPath

    # Path to the appsettings.json file
    $appSettingsPath ="C:\inetpub\wwwroot\appsettings.json"

    # Read and parse the JSON file
    $appSettings = Get-Content -Path $appSettingsPath -Raw | ConvertFrom-Json

    # Access specific values
    $appSettings.StorageConnectionString= $storageConnectionString

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
    

} else {
    Write-Error "RuntimeSettings file not found at $settingFile."
}
