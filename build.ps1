###############################################################
##                                                           ##
##                     Base Build Script                     ##
##                            For                            ##
##                   Global Resale GRID 3.0                  ##
##                                                           ##
###############################################################

param (
    [string]$action = "default"
)

if (Get-Module -ListAvailable -Name psake) {
    Write-Host "psake exists"
} 
else {
    Write-Host "psake does not exist"
    Write-Host "installing psake"
    Find-Module psake | Install-Module
}

if (Get-Module -ListAvailable -Name psake) {
    Write-Host "VSSetup exists"
}
else {
    Write-Host "VSSetup does not exist"
    Write-Host "installing VSSetup"
    Install-Module VSSetup -Scope CurrentUser
}

Invoke-Psake .\default.ps1 $action