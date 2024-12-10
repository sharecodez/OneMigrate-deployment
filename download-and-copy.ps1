# Define source URL and destination folder
$sourceUrl = "https://example.com/path-to-your-file.zip"
$destinationPath = "D:\home\site\wwwroot"

# Create the wwwroot folder if it doesn't exist
if (!(Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Force -Path $destinationPath
}

# Download the file
$zipFilePath = Join-Path -Path $destinationPath -ChildPath "file.zip"
Invoke-WebRequest -Uri $sourceUrl -OutFile $zipFilePath

# Extract the ZIP file to wwwroot
Expand-Archive -Path $zipFilePath -DestinationPath $destinationPath -Force

# Clean up the ZIP file
Remove-Item -Path $zipFilePath -Force
