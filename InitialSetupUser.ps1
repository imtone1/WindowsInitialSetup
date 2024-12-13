function InitialSetupUser {
    param (
        [string]$ChromeInstallerUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe",
        [string]$ChromeInstallerPath = $env:TEMP,
        [string]$ChromeInstaller = "chrome_installer.exe",
        [string[]]$BlockedUrls = @("facebook.com", "instagram.com"),
        [string]$SoftwareFolderPath = "C:\path to your\folder"
    )

# Install Google Chrome
# Download the Chrome installer
try{
Write-Host "Starting Google Chrome installation..." -ForegroundColor Cyan
Invoke-WebRequest $ChromeInstallerUrl -OutFile $ChromeInstallerPath$ChromeInstaller ;

# Run the installer silently
Start-Process -FilePath "$ChromeInstallerPath$ChromeInstaller " -Args "/silent /install" -Verb RunAs -Wait;

# Clean up the installer file after installation
Remove-Item $ChromeInstallerPath$ChromeInstaller 

Write-Host "Google Chrome has been installed successfully." -ForegroundColor Green
}
catch {
    Write-Host "Failed to install Google Chrome." -ForegroundColor Red
}

try{
Write-Host "Blocking $BlockedUrls" -ForegroundColor Cyan
$count = 0
    foreach ($url in $BlockedUrls) {
        $count++
        $settings = 
        [PSCustomObject]@{ # block facebook
            Path  = "SOFTWARE\Policies\Google\Chrome\URLBlocklist"
            Value = $url
            Name  = $count
        }
    } | group Path
Write-Host "Blocking $url" -ForegroundColor Cyan
Write-Host "blocking settings $settings" -ForegroundColor Cyan

foreach($setting in $settings){
    $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
    }
    $setting.Group | %{
        $registry.SetValue($_.name, $_.value)
    }
    $registry.Dispose()
}

Write-Host "Facebook and Instagram have been blocked successfully." -ForegroundColor Green
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