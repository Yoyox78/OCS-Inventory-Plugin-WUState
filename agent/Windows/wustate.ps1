$Error.Clear()

$ModInstallSrvRoot = Get-Module -ListAvailable -Name PSWindowsUpdate
if  (($Error.count -eq 0) -and ($ModInstallSrvRoot -eq $null))
{ 
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module PSWindowsUpdate -Confirm:$false -Force
    Import-module PSWindowsUpdate
    
}

$Error.Clear()

$InvokeTest = Get-Module -ListAvailable -Name PSWindowsUpdate


if  (($Error.count -eq 0) -and ($InvokeTest -eq $null))
{ 
    $Error.Clear()
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    if (Select-String -InputObject $Error[0].FullyQualifiedErrorId -Pattern 'NoMatchFoundForProvider' -Quiet) 
    {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Value "1" -Type DWord
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Value "1" -Type DWord
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
        $Error.Clear()
    }
    Install-Module PSWindowsUpdate -Confirm:$false -Force
    Import-module PSWindowsUpdate

}

if (-Not (Get-Module -ListAvailable -Name PendingReboot))
{ 
    Install-Module PendingReboot -Confirm:$false -Force
    Import-module PendingReboot
}

$Winupdate = Get-WindowsUpdate
$WUTitre = $Winupdate.title | select-string -pattern 'KB[0-9]+'
$WUKB = $WUTitre.matches.value | Select-Object -Unique | Out-String 
$WUKB = $WUKB -replace '\s',' '
$WUReboot = (Test-PendingReboot -SkipConfigurationManagerClientCheck -Detailed).WindowsUpdateAutoUpdate

if ($WUTitre.Count -gt 0)
{
    $WUpdate = "NOK"
}
else
{
    $WUpdate = "OK"
}


$xml = "<WUSTATE>`n"
$xml += "<DATE>$(Get-Date -Format "dd/MM/yyyy_HH:mm")</DATE>`n"
$xml += "<STATE>${WUpdate}</STATE>`n"
$xml += "<REBOOT>${WUReboot}</REBOOT>`n"
$xml += "<MAJ>${WUKB}</MAJ>`n"
$xml += "</WUSTATE>"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::WriteLine($xml)