# Install IIS
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

# Extract and deploy web application
$webAppZip = "C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\Downloads\1\webapp.zip"
$destinationPath = "C:\inetpub\wwwroot"

Expand-Archive -Path $webAppZip -DestinationPath $destinationPath -Force

# Restart IIS
iisreset
