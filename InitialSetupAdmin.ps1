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