function CreateUser {
    param (
        [string]$UserName = "",
        [string]$Password = ""
    )
# Create New Local User
Write-Host "Creating new local user $UserName" -ForegroundColor Cyan
try {
    if ([string]::IsNullOrWhiteSpace($UserName) -or [string]::IsNullOrWhiteSpace($Password)) {
        Write-Host "Error: Username and password are required." -ForegroundColor Red
        return
    }
    
    if (-not (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue)) {
    $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
    New-LocalUser -Name $UserName -Password $securePassword -FullName $UserName -PasswordNeverExpires

    Add-LocalGroupMember -Group "Users" -Member $UserName

    Write-Host "New local user created." -ForegroundColor Green
    } 
    else {
    Write-Host "User $UserName already exists." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Failed to create new local user." -ForegroundColor Red
}

}