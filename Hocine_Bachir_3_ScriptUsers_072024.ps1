# Script de création d'utilisateurs à partir d'un fichier CSV
# Auteur: Bachir HOCINE
# Date: 18/07/2024
# Version: 1.0
# Description: Ce script crée des utilisateurs dans Active Directory à partir d'un fichier CSV.

# Importer les modules nécessaires
Import-Module ActiveDirectory

# Fonction pour créer un utilisateur dans AD à partir du fichier CSV
function New-ADUsersFromCSV {
    param([string]$CSVPath)
    if (-not (Test-Path $CSVPath)) { Write-Host "Le fichier CSV spécifié n'existe pas."; return }
    $users = Import-Csv -Path $CSVPath
    foreach ($user in $users) {
        try {
            $newUserParams = @{
                SamAccountName = $user.Login
                UserPrincipalName = "$($user.Login)@axeplane.loc"
                Name = "$($user.Prenom) $($user.Nom)"
                GivenName = $user.Prenom
                Surname = $user.Nom
                Enabled = $true
                ChangePasswordAtLogon = $true
                DisplayName = "$($user.Nom), $($user.Prenom)"
                Description = $user.Description
                Path = $user.OU
                AccountPassword = ConvertTo-SecureString $user.'Mot de passe' -AsPlainText -Force
                EmailAddress = $user.Email
            }
           New-ADUser @newUserParams
    if ($user.'Groupe Global' -and $user.'Groupe Local') { 
    Add-ADGroupMember -Identity $user.'Groupe Global' -Members $user.Login
    Add-ADGroupMember -Identity $user.'Groupe Local' -Members $user.Login}

Write-Host "Le compte utilisateur $($user.Login) a été créé avec succès."

            
            # Création du partage privé
            $personalFolderPath = "\\SRV-AD\utilisateurs$\$($user.Login)"
            New-Item -Path $personalFolderPath -ItemType Directory -Force | Out-Null
            $acl = Get-Acl -Path $personalFolderPath
            $acl.SetAccessRuleProtection($True, $False)
            $acl.Access | ForEach { [Void]$acl.RemoveAccessRule($_) }
            $permission = New-Object System.Security.AccessControl.FileSystemAccessRule($user.Login, "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
            $acl.AddAccessRule($permission)
            Set-Acl -Path $personalFolderPath -AclObject $acl | Out-Null

            # Autoriser l'administrateur à accéder au dossier
            $adminPermission = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrateurs", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
            $acl.AddAccessRule($adminPermission)
            Set-Acl -Path $personalFolderPath -AclObject $acl | Out-Null

            
            # Mappage du partage privé sur le lecteur P:

            Set-ADUser -Identity $($user.Login) -HomeDirectory "\\SRV-AD\utilisateurs$\$($user.Login)" -HomeDrive "P:"
                                    
            Write-Host "Le dossier personnel pour $($user.Login) a été créé et mappé avec succès."
        } catch { Write-Host "Une erreur s'est produite lors de la création de l'utilisateur $($user.Login) : $_" }
    }
}

# Définir le chemin du fichier CSV contenant les utilisateurs à créer
$CSVPath = "E:\compte.csv"

# Appel de la fonction pour créer les utilisateurs à partir du fichier CSV
New-ADUsersFromCSV -CSVPath $CSVPath
