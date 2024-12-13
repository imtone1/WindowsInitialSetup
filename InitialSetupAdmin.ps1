function InitialSetupAdmin{
    param(
        [string]$UserName = "USERNAME",
        [string]$Password = "PASSWORD",
        [int]$HomeLocation = 77, # Finland
        [string]$TimeZone = "*Helsinki*",
        [string[]]$Languages = @("fi-FI", "en-us")
    )

function Set-RegistryValue {
    param([string]$Path, [string]$Name, [object]$Value, [string]$Type = "DWORD")
    try {
        $reg = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($Path, $true)
        if (-not $reg) { $reg = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($Path) }
        $reg.SetValue($Name, $Value, [Microsoft.Win32.RegistryValueKind]::$Type)
        $reg.Dispose()
    } catch {
        Write-Host "Failed to set registry value $Name in $Path. $_" -ForegroundColor Red
    }
}

# Disable Widgets in Taskbar
Write-Host "Disabling widgets in taskbar..."
Set-RegistryValue -Path "SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Value 0
Write-Host "Widgets in taskbar disabled." -ForegroundColor Green

# Disable OOBE Privacy Experience
Write-Host "Disabling OOBE Privacy Experience..."
Set-RegistryValue -Path "SOFTWARE\Policies\Microsoft\Windows\OOBE" -Name "DisablePrivacyExperience" -Value 1
Write-Host "OOBE Privacy Experience disabled." -ForegroundColor Green

# Remove Unnecessary App Packages
Write-Host "Removing unnecessary app packages..." -ForegroundColor Cyan
try {
$app_packages = 
"Clipchamp.Clipchamp",
"Microsoft.549981C3F5F10", # Cortana
"Microsoft.WindowsFeedbackHub",
"Microsoft.WindowsMaps",
"Microsoft.ZuneMusic",
"Microsoft.BingNews",
"Microsoft.Todos",
"Microsoft.ZuneVideo",
"Microsoft.People",
"MicrosoftCorporationII.QuickAssist",
"Microsoft.MicrosoftSolitaireCollection",
"Microsoft.MicrosoftStickyNotes",
"Microsoft.BingWeather",
"Microsoft.Xbox.TCUI",
"Microsoft.GamingApp",
"*MicrosoftFamily*"
Get-AppxPackage -AllUsers | ?{$_.name -in $app_packages} | Remove-AppxPackage -AllUsers
Write-Host "App packages removed." -ForegroundColor Green
}
catch {
    Write-Host "Failed to remove app packages." -ForegroundColor Red
}

# Set Home Location
Write-Host "Setting home location to $HomeLocation" -ForegroundColor Cyan
try {
Set-WinHomeLocation $HomeLocation
}
catch {
    Write-Host "Failed to set home location." -ForegroundColor Red
}

 # Configure User Languages
try {
Write-Host "Configuring user language list: $($Languages -join ', ')" -ForegroundColor Cyan
Set-WinUserLanguageList fi-FI, en-us -force -wa silentlycontinue
}
catch {
    Write-Host "Failed to configure user language list." -ForegroundColor Red
}
# Set Time Zone
try {
Write-Host "Setting time zone to match $TimeZone" -ForegroundColor Cyan
Get-TimeZone -ListAvailable | ?{$_.DisplayName -like $TimeZone} | Set-TimeZone
}
catch {
    Write-Host "Failed to set time zone." -ForegroundColor Red
}
# Create New Local User
Write-Host "Creating new local user $UserName" -ForegroundColor Cyan
try {
$securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
New-LocalUser -Name $UserName -Password $securePassword -FullName $UserName -PasswordNeverExpires

Add-LocalGroupMember -Group "Users" -Member $UserName

Write-Host "New local user created." -ForegroundColor Green
}
catch {
    Write-Host "Failed to create new local user." -ForegroundColor Red
}

Write-Host "Function InitialSetupAdmin completed." -ForegroundColor Green
}