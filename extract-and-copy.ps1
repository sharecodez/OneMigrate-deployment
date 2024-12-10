param (
    [string]$zipUrl
)

# Define paths
$wwwroot = "C:\home\site\wwwroot"
$tempFile = "C:\local\Temp\app.zip"

# Download ZIP file
Write-Host "Downloading ZIP from $zipUrl"
Invoke-WebRequest -Uri $zipUrl -OutFile $tempFile

# Extract ZIP file to wwwroot
Write-Host "Extracting ZIP to $wwwroot"
Expand-Archive -Path $tempFile -DestinationPath $wwwroot -Force

# Cleanup
Remove-Item $tempFile -Force

Write-Host "Deployment complete."
