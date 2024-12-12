# Windows 11 initial setup with Powershell

Used to setup new Windows 11 computer with Powershell for small company. This is not a complete guide but a starting point for your own setup. I recommend to check all scripts and understand what they do before running them.

Used [lestdoautomation github repository](https://github.com/letsdoautomation/powershell) as a base for many of scripts. I recommend to check it out because it has many useful scripts for Windows/Brave/Chrome/Enge setup.

Also used [StellarSand github repositoty](https://github.com/StellarSand/privacy-settings/blob/main/Privacy%20Settings/Windows-11.md) for privacy settings check list.

## Create new local user

Check first what users you have on computer

**Get only Enabled users:**

```powershell
Get-LocalUser | ?{$_.Enabled} | select Name, Enabled, PasswordLastSet
```

You might want to check all properties if users seems schetchy

**Get all properties:**

```powershell
Get-LocalUser | select *
```

**Create user with password and add him to Users group:**

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

**Copy settings to new users and welcome screen:**

```powershell
Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True
```

## New user setup

**Get current home location:**

```powershell
Get-WinHomeLocation
```

**Set home location to Finland:**

```powershell
Set-WinHomeLocation 77
```

**Get-WinUserLanguageList:**

```powershell
Get-WinUserLanguageList
```

**Use Set-WinUserLanguageList to set finnish and english keyboard:**

```powershell
Set-WinUserLanguageList fi-FI, en-us -force -wa silentlycontinue
```


**Get currently set time zone:**

```powershell
Get-TimeZone
```

**Set time zone using DisplayName parameter:**

```powershell
Get-TimeZone -ListAvailable | ?{$_.DisplayName -like "*Helsinki*"} | Set-TimeZone
```

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
"Microsoft.ScreenSketch",
"Microsoft.MicrosoftSolitaireCollection",
"Microsoft.MicrosoftStickyNotes",
"Microsoft.BingWeather",
"Microsoft.Xbox.TCUI",
"Microsoft.GamingApp",
"*MicrosoftFamily*"
Get-AppxPackage -AllUsers | ?{$_.name -in $app_packages} | Remove-AppxPackage -AllUsers
```

**Disable widgets in taskbar**

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

**Disable privacy experience for new users**

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

## Local Group Policy Editor

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
