# je vide la variable erreur
$Error.Clear()

# Verification du plugin pswindowsupdate, si il est présent ou pas
$ModInstallSrvRoot = Get-Module -ListAvailable -Name PSWindowsUpdate
if  (($Error.count -eq 0) -and ($ModInstallSrvRoot -eq $null))
{ 
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module PSWindowsUpdate -Confirm:$false -Force
    Import-module PSWindowsUpdate
    
}

$Error.Clear()

# 2e Verification pour verifier qu'il c'est bien installé
$InvokeTest = Get-Module -ListAvailable -Name PSWindowsUpdate

# Si il ne c'est pas installer je fais de modification et des installations suivant le message d'erreur
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

# Récupérationdu module qui me permet de savoir si le poste est en attente de restart liée aux mise à jour
if (-Not (Get-Module -ListAvailable -Name PendingReboot))
{ 
    Install-Module PendingReboot -Confirm:$false -Force
    Import-module PendingReboot
}

# Récupère la liste des MAJ
$Winupdate = Get-WindowsUpdate
# On prend les version de KB
$WUTitre = $Winupdate.title | select-string -pattern 'KB[0-9]+'
# On met en variable les valeur récupéré avec la regex
$WUKB = $WUTitre.matches.value | Select-Object -Unique | Out-String 
# On remplace les retour à la ligne par des espace
$WUKB = $WUKB -replace '\s',' '
# On  met en variable la valeur a savoir si le poste est en attente de reboot suite à des MAJ
$WUReboot = (Test-PendingReboot -SkipConfigurationManagerClientCheck -Detailed).WindowsUpdateAutoUpdate
# On récupère le serveur WSUS présent dans le registre
$Server = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\" -Name "WUServer").WUServer

# Si il y a des MAJ alors on met en variable NOK, sinon c'est OK
if ($WUTitre.Count -gt 0)
{
    $WUpdate = "NOK"
}
else
{
    $WUpdate = "OK"
}

#On renvoi le XML contenant les informations
$xml = "<WUSTATE>`n"
$xml += "<DATE>$(Get-Date -Format "dd/MM/yyyy_HH:mm")</DATE>`n"
$xml += "<STATE>${WUpdate}</STATE>`n"
$xml += "<REBOOT>${WUReboot}</REBOOT>`n"
$xml += "<MAJ>${WUKB}</MAJ>`n"
$xml += "<SERVER>${Server}</SERVER>`n"
$xml += "</WUSTATE>"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::WriteLine($xml)