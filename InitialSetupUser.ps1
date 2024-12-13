function InitialSetupUser {
    param (
        [string]$ChromeInstallerUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe",
        [string]$ChromeInstallerPath = $env:TEMP,
        [string]$ChromeInstaller = "chrome_installer.exe",
        [string[]]$BlockedUrls = @("facebook.com", "instagram.com"),
        [string]$SoftwareFolderPath = "C:\path to your\folder"
    )

# Install Google Chrome

try{
Write-Host "Starting Google Chrome installation..." -ForegroundColor Cyan

#Installer path build
$installerPathFull=Join-Path -Path $ChromeInstallerPath -ChildPath $ChromeInstaller

# Download the Chrome installer
Invoke-WebRequest $ChromeInstallerUrl -OutFile $installerPathFull -ErrorAction Stop;

# Run the installer silently
Start-Process -FilePath $installerPathFull -Args "/silent /install" -Verb RunAs -Wait -ErrorAction Stop;

# Clean up the installer file after installation
Remove-Item $installerPathFull -Force -ErrorAction Stop

Write-Host "Google Chrome has been installed successfully." -ForegroundColor Green
}
catch {
    Write-Host "Failed to install Google Chrome." -ForegroundColor Red
}

try {
    Write-Host "Blocking URLs: $($BlockedUrls -join ', ')" -ForegroundColor Cyan
# Registry Path for Chrome URLBlocklist
$registryPath = "SOFTWARE\Policies\Google\Chrome\URLBlocklist"

# Open or create the registry key
$registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($registryPath, $true)
if ($registry) {
    # Set each blocked URL in the URLBlocklist
    $count = 0
    foreach ($url in $BlockedUrls) {
        $count++
        $registry.SetValue("$count", $url, [Microsoft.Win32.RegistryValueKind]::String)
        Write-Host "Blocked URL: $url" -ForegroundColor Green
    }
    $registry.Dispose()
    Write-Host "All URLs have been successfully blocked." -ForegroundColor Green
} else {
    Write-Host "Error: Failed to access or create Chrome registry key." -ForegroundColor Red
}
}
catch {
    Write-Host "Failed to block $BlockedUrls." -ForegroundColor Red
}

try{
# Get all exe files in the folder
$fileNames = Get-ChildItem -Path $SoftwareFolderPath -Recurse -Include *.exe
ForEach ($fileName in $fileNames) {
    $FilePath = $fileName.FullName
    Write-Host "Installing $FilePath"
    Start-Process -Wait -FilePath $FilePath -Args "/silent" -PassThru
}
}
catch {
    Write-Host "Failed to install software." -ForegroundColor Red
}

Write-Host "Function InitialSetupUser completed." -ForegroundColor Green
}