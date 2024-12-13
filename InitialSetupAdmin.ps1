function InitialSetupAdmin{
    param(
        [string]$UserName = "USERNAME",
        [string]$Password = "PASSWORD",
        [int]$HomeLocation = 77, # Finland
        [string]$TimeZone = "*Helsinki*",
        [string[]]$Languages = @("fi-FI", "en-us")
    )
 # Disable Widgets in Taskbar

Write-Host "Disabling widgets in taskbar..."
try {
$settings = [PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Dsh" Value = 0
    Name  = "AllowNewsAndInterests"
} | group Path

foreach ($setting in $settings) {
    $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
    }
    $setting.Group | % {
        if (!$_.Type) {
            $registry.SetValue($_.name, $_.value)
        }
        else {
            $registry.SetValue($_.name, $_.value, $_.type)
        }
    }
    $registry.Dispose()
    
}
Write-Host "Widgets in taskbar disabled."
}
catch {
    Write-Host "Failed to disable widgets in taskbar."
}



# Disable OOBE Privacy Experience
Write-Host "Disabling OOBE Privacy Experience..."
try{
$settings1 =
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Windows\OOBE" Name  = "DisablePrivacyExperience" Value = 1
} | group Path

foreach ($setting in $settings1) {
    $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
    }
    $setting.Group | % {
        $registry.SetValue($_.name, $_.value)
    }
    $registry.Dispose()
}
Write-Host "OOBE Privacy Experience disabled."
}
catch {
    Write-Host "Failed to disable OOBE Privacy Experience."
}

# Remove Unnecessary App Packages
Write-Host "Removing unnecessary app packages..."
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
Write-Host "App packages removed."
}
catch {
    Write-Host "Failed to remove app packages."
}

# Set Home Location
Write-Host "Setting home location to $HomeLocation"
try {
Set-WinHomeLocation $HomeLocation
}
catch {
    Write-Host "Failed to set home location."
}

 # Configure User Languages
try {
Write-Host "Configuring user language list: $($Languages -join ', ')"
Set-WinUserLanguageList fi-FI, en-us -force -wa silentlycontinue
}
catch {
    Write-Host "Failed to configure user language list."
}
# Set Time Zone
try {
Write-Host "Setting time zone to match $TimeZone"
Get-TimeZone -ListAvailable | ?{$_.DisplayName -like $TimeZone} | Set-TimeZone
}
catch {
    Write-Host "Failed to set time zone."
}
# Create New Local User
Write-Host "Creating new local user $UserName"
try {
$securePassword = ConvertTo-SecureString -AsPlainText $Password -Force
$user = New-LocalUser -Name $UserName -Password $securePassword -FullName $UserName -PasswordNeverExpires $true
$user | Set-LocalUser -PasswordNeverExpires $true 
$user | Add-LocalGroupMember -Group "Users"

Write-Host "New local user created."
}
catch {
    Write-Host "Failed to create new local user."
}

Write-Host "Function InitialSetupAdmin completed."
}