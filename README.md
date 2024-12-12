# Windows 11 initial setup with Powershell

Used to setup new Windows 11 computer with Powershell for small company. This is not a complete guide but a starting point for your own setup. I recommend to check all scripts and understand what they do before running them.

Used [lestdoautomation github repository](https://github.com/letsdoautomation/powershell) as a base for many of scripts. I recommend to check it out because it has many useful scripts for Windows/Brave/Chrome/Enge setup.

Also used [StellarSand github repositoty](https://github.com/StellarSand/privacy-settings/blob/main/Privacy%20Settings/Windows-11.md) for privacy settings check list.


## Table of Contents  

1. [Administrator Setup](#administrator-setup)  
   - [Disable Widgets in Taskbar](#disable-widgets-in-taskbar)  
   - [Disable Privacy Experience for New Users](#disable-privacy-experience-for-new-users)  
   - [Copy Settings to New Users and Welcome Screen](#copy-settings-to-new-users-and-welcome-screen)  
   - [Remove Multiple App Packages for All Users](#remove-multiple-app-packages-for-all-users)  

2. [Local Group Policy Editor](#local-group-policy-editor)  
   - [Enabling Local Group Policy Editor on Windows 11](#enabling-local-group-policy-editor-on-windows-11)  

3. [Create New Local User](#create-new-local-user)  
   - [Check Existing Users](#check-existing-users)  
   - [Create a User with Password and Add to Users Group](#create-user-with-password-and-add-to-users-group)  

4. [New User Setup](#new-user-setup)  
   - [Set Home Location](#set-home-location)  
   - [Set Language List](#set-language-list)  
   - [Set Time Zone](#set-time-zone)  
   - [Install Google Chrome](#install-google-chrome)
   - [Block Google Chrome Access to a List of URLs](#block-google-chrome-access-to-a-list-of-urls)
   - [Check Execution Policy](#check-execution-policy)
   - [Install Software](#install-software)

5. [Images](#images-for-windows-11-personalization-and-privacy-settings)  
   - [Privacy and Security Settings](#privacy-and-security-settings)  
   - [Personalization Settings](#personalization-settings)  
   - [Accessibility Features](#accessibility-features)  
   - [System Features](#system-features)

---


## Administator setup

### Disable widgets in taskbar

![widgets](/Images/Windows_widgets.jpg)

```powershell
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
```

### Disable privacy experience for new users

![privacy setup](/Images/Windows_initial_privacy_popup.png)

OOBE stand for Out of Box Experience 
Read more about it here: [Customize the Out of Box Experience](https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/customize-oobe-in-windows-11)

Disabling it will make setup faster because you can setup them later through settings anyway. Additionally you have to setup them anyway because there are much more settings you want to setup than in OOBE.

```powershell
$settings =
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Windows\OOBE" Name  = "DisablePrivacyExperience" Value = 1
} | group Path

foreach ($setting in $settings) {
    $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
    }
    $setting.Group | % {
        $registry.SetValue($_.name, $_.value)
    }
    $registry.Dispose()
}
```

### Copy settings to new users and welcome screen

```powershell
Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True
```

### Remove multiple app packages for all users

**Remove multiple app packages for all existing user:**

Be very mindful what you remove. Powershell is very powerful tool and you can break your system with it.

```powershell
# Don't recommended removing
#"Microsoft.WindowsNotepad"
#"Microsoft.Paint"
#"Microsoft.WindowsCalculator"
#"Microsoft.XboxGamingOverlay"
#"Microsoft.Windows.Photos"

# System components
#"Microsoft.YourPhone"
#"Microsoft.Windows.DevHome"
#"Microsoft.GetHelp"
#"Microsoft.Getstarted"
#"Microsoft.WindowsStore"
# office
#"Microsoft.MicrosoftOfficeHub"
#"Microsoft.OutlookForWindows"
#tallennus
#"Microsoft.WindowsSoundRecorder"
#"Microsoft.WindowsCamera"

#"Microsoft.WindowsAlarms"
#screenshot
#"Microsoft.ScreenSketch"
#if not used, delete
#"Microsoft.PowerAutomateDesktop"

$app_packages = 
"Clipchamp.Clipchamp",
"Microsoft.549981C3F5F10", # Cortana
"Microsoft.WindowsFeedbackHub",
"microsoft.windowscommunicationsapps",
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
```

## Local Group Policy Editor

### Enabling Local Group Policy Editor on Windows 11

To disable installation of apps you perhaps want to use Local Group Policy Editor.

There are multiple ways to open it for it not nessessary already installed in your Windows 11. Learn how open it here: [Local Group Policy Editor](https://www.geeksforgeeks.org/access-group-policy-editor-in-win-home/)

I'm using to open it described [here](https://answers.microsoft.com/en-us/windows/forum/all/gpeditmsc-missing/cc1d05b2-457d-4aa6-839f-8136d0eddc35) 

Copy file 'GPedit.txt' to your computer, name it 'GPedit.bat' and run it as administrator. File content is below. You can find file [here](/GPedit.txt)

```bat
@echo off

pushd "%~dp0"

dir /b %SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientExtensions-Package~3*.mum >List.txt
dir /b %SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientTools-Package~3*.mum >>List.txt

for /f %%i in ('findstr /i . List.txt 2^>nul') do dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%i"

pause
```

After it you should be able to open Local Group Policy Editor by Win + r and typing 'gpedit.msc' in search bar and pressing enter.

## Create new local user

Check first what users you have on computer

### Check existing users

**Get only Enabled users:**

```powershell
Get-LocalUser | ?{$_.Enabled} | select Name, Enabled, PasswordLastSet
```

You might want to check all properties if users seems schetchy

**Get all properties:**

```powershell
Get-LocalUser | select *
```

### Create user with password and add to Users group

Remember to setup your own USERNAME and PASSWORD!

```powershell
$new_user = @{
    Name                 = 'USERNAME'
    Password           = (ConvertTo-SecureString -AsPlainText 'PASSWORD' -Force)
}
$user = New-LocalUser @new_user
$user | Set-LocalUser -PasswordNeverExpires $true 
$user | Add-LocalGroupMember -Group "Users"
```

## New user setup

### Set home location

**Get current home location:**

```powershell
Get-WinHomeLocation
```

**Set home location to Finland:**

```powershell
Set-WinHomeLocation 77
```

### Set language list

**Get-WinUserLanguageList:**

```powershell
Get-WinUserLanguageList
```

**Use Set-WinUserLanguageList to set finnish and english keyboard:**

```powershell
Set-WinUserLanguageList fi-FI, en-us -force -wa silentlycontinue
```

### Set time zone

**Get currently set time zone:**

```powershell
Get-TimeZone
```

**Set time zone using DisplayName parameter:**

```powershell
Get-TimeZone -ListAvailable | ?{$_.DisplayName -like "*Helsinki*"} | Set-TimeZone
```

### Install Google Chrome

Install latest version of Google Chrome.

```powershell
# Set path to download the Chrome installer
$InstallerPath = $env:TEMP;
$Installer = "chrome_installer.exe";

# Download the Chrome installer
Invoke-WebRequest "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile $InstallerPath$Installer;

# Run the installer silently
Start-Process -FilePath "$InstallerPath$Installer" -Args "/silent /install" -Verb RunAs -Wait;

# Clean up the installer file after installation
Remove-Item $InstallerPath$Installer

Write-Host "Google Chrome has been installed successfully."
```

### Block Google Chrome access to a list of URLs

Block Google Chrome access to a list of URLs
- facebook
- instagram

Then blocking you see this message when trying to access facebook.com or instagram.com

![block message](/Images/Facebook_blocked.jpg)

**Why you might want to block facebook and instagram?**
- Productivity 
    - They are time wasters
- Security
    -  Employees may unknowingly click on malicious links shared through these platforms.
    - Cybercriminals can spread malware through ads, messages, or fake accounts.
    - Limiting access reduces the risk of security breaches or compromised systems.
- Speed
    - Social media platforms, especially video- and image-heavy ones like Instagram, consume significant amounts of bandwidth.


> **Note:** This blocks only Google Chrome access to these URLs. You can still access them with other browsers. If this is the issue you might want to block them in other browsers or ban other browsers with company policy or with other tools.


```powershell
$settings = 
[PSCustomObject]@{ # block facebook
    Path  = "SOFTWARE\Policies\Google\Chrome\URLBlocklist"
    Value = "facebook.com"
    Name  = ++$count
},
[PSCustomObject]@{ # block instagram
    Path  = "SOFTWARE\Policies\Google\Chrome\URLBlocklist"
    Value = "instagram.com"
    Name  = ++$count
} | group Path

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
```

### Check Execution Policy

Make sure that you do not have Bypass in regular user execution policy.
Normally you do not want to see Bypass list. You can change it with Set-ExecutionPolicy command.

You can read about setting execution policy [here](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.4)

```powershell
Get-ExecutionPolicy -List
```

### Lock screen background to image

```powershell
$ImagePath="C:\path to your\file.jpg"
$Key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'

# testing if path exists in the system
# Out-Null suppresses any output from the New-Item command.
if (!(Test-Path -Path $Key)) {
   New-Item -Path $Key -Force | Out-Null
}
Set-ItemProperty -Path $Key -Name LockScreenImagePath -value $ImagePath
```

### Disable Ads on Windows 11

[removing adds from windows](https://www.geeksforgeeks.org/disable-annoying-ads-on-windows/)

### Install software

This installs software silently. Keep in mind that if you do not run this as administrator it will ask you your admin password. 
Additionally if you have to pass activation code it will not be done automatically. You have to add it manually.

```powershell

$folderPath = "C:\path to your\folder"
# Get all exe files in the folder
$fileNames = Get-ChildItem -Path $folderPath -Recurse -Include *.exe
ForEach ($fileName in $fileNames) {
    $FilePath = $fileName.FullName
    Write-Host "Installing $FilePath"
    Start-Process -Wait -FilePath $FilePath -Args "/silent" -PassThru
}

```

## Images for Windows 11 Personalization and Privacy Settings

### Privacy and Security Settings
![General Privacy and Security](Images/General_privacy_security.jpg)
![Activity History Privacy and Security](Images/Activity_history_privacy_security.jpg)
![Diagnostics Privacy and Security](Images/Diagnostics_privacy_security.jpg)
![Search Permissions Privacy Security](Images/Search_permissions_privacy_security.jpg)
![Search Permissions 2 Privacy Security](Images/Search_permissions2_privacy_security.jpg)
![Speech Accessibility](Images/Speech_accessibility.jpg)
![Speech Privacy and Security](Images/Speech_privacy_security.jpg)
![Typing Personalisation](Images/Typing_personalisation.jpg)
![Typing Privacy and Security](Images/Typing_privacy_security.jpg)

### Personalization Settings
![Background Personalisation](Images/Background_personalisation.jpg)
![Device Usage Personalisation](Images/Device_usage_personalisation.jpg)
![Lock Screen Personalisation](Images/Lock_screen_personalization.jpg)
![Start Personalisation](Images/Start_personalisation.jpg)
![Taskbar Personalisation](Images/Taskbar_personalisation.jpg)

### Accessibility Features
![Narrator](Images/Narrator.jpg)
![Typing Insights](Images/Typing_insights.jpg)
![Typing Time Language](Images/Typing_time_language.jpg)

### System Features
![Game Bar](Images/Game_bar.jpg)
![Game Mode](Images/Game_mode.jpg)
![Share Across Devices](Images/Share_across_devices.jpg)