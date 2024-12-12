
Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $BlobPath
    )

#$BlobPath=$BlobPath.Replace('"',"")

#Add-Content -Path C:\Temp\Log.txt $BlobPath

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


# Install .net 8
$dotneturl="https://download.visualstudio.microsoft.com/download/pr/4956ec5e-8502-4454-8f28-40239428820f/e7181890eed8dfa11cefbf817c4e86b0/dotnet-hosting-8.0.11-win.exe"
$dotnetTemp="C:\Temp\dotnet.exe"
Invoke-WebRequest -Uri $dotneturl -OutFile $dotnetTemp
Start-Process -FilePath $dotnetTemp -ArgumentList "/quiet", "/norestart" -Wait

# Restart IIS
iisreset