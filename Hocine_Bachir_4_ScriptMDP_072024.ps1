<# Script interactif de réinitialisation de mot de passe
   Auteur: Bachir HOCINE
   Date: 18/07/2024
   Version: 1.1
   Description: Ce script permet de réinitialiser un mot de passe d'utilisateur dans Active Directory et de tracer l'opération dans un fichier de log.
#>

# Importer les modules nécessaires
Import-Module ActiveDirectory

# Chemin du fichier de log
$logFilePath = "E:\password_reset_log.txt"

# Fonction pour écrire dans le fichier de log
function Write-Log {
    param (
        [string]$logMessage
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp - $logMessage"
    Add-Content -Path $logFilePath -Value $entry
}

# Fonction pour demander et confirmer le mot de passe
function Get-SecurePassword {
    function ConvertTo-PlainText {
        param (
            [SecureString]$secureString
        )
        return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString))
    }

    function Validate-Password {
        param (
            [string]$password
        )
        if ($password.Length -lt 14) {
            Write-Host "Le mot de passe doit contenir au moins 14 caractères."
            return $false
        }
        if ($password -notmatch '[A-Z]') {
            Write-Host "Le mot de passe doit contenir au moins une lettre majuscule."
            return $false
        }
        if ($password -notmatch '[a-z]') {
            Write-Host "Le mot de passe doit contenir au moins une lettre minuscule."
            return $false
        }
        if ($password -notmatch '\d') {
            Write-Host "Le mot de passe doit contenir au moins un chiffre."
            return $false
        }
        if ($password -notmatch '[\W_]') {
            Write-Host "Le mot de passe doit contenir au moins un caractère spécial."
            return $false
        }
        return $true
    }

    while ($true) {
        $password = Read-Host "Entrez le nouveau mot de passe" -AsSecureString
        $passwordConfirmation = Read-Host "Confirmez le nouveau mot de passe" -AsSecureString

        $plainPassword = ConvertTo-PlainText -secureString $password
        $plainPasswordConfirmation = ConvertTo-PlainText -secureString $passwordConfirmation

        if ($plainPassword -ne $plainPasswordConfirmation) {
            Write-Host "Les mots de passe ne correspondent pas. Veuillez réessayer."
        } elseif (-not (Validate-Password -password $plainPassword)) {
            Write-Host "Le mot de passe ne répond pas aux critères de complexité. Veuillez réessayer."
        } else {
            return $password
        }
    }
}

# Fonction pour réinitialiser le mot de passe d'un utilisateur
function Reset-UserPassword {
    param (
        [string]$username,
        [string]$reason,
        [SecureString]$newPassword
    )

    try {
        # Vérifier si l'utilisateur existe
        $user = Get-ADUser -Identity $username -ErrorAction Stop

        # Réinitialiser le mot de passe et forcer le changement à la prochaine connexion
        Set-ADAccountPassword -Identity $user -NewPassword $newPassword -Reset
        Set-ADUser -Identity $user -ChangePasswordAtLogon $true

        # Écrire dans le fichier de log
        $logMessage = "Mot de passe réinitialisé pour l'utilisateur: $($user.Name) ($username), Motif: $reason"
        Write-Log -logMessage $logMessage

        Write-Host "Le mot de passe de l'utilisateur $($user.Name) ($username) a été réinitialisé avec succès. Motif: $reason"
    } catch {
        Write-Host "Une erreur s'est produite lors de la réinitialisation du mot de passe pour l'utilisateur $username : $_"
    }
}

# Script principal
Write-Host "Bienvenue dans l'outil de réinitialisation de mot de passe."

# Demander le login de l'utilisateur
$username = Read-Host "Entrez le login de l'utilisateur dont vous souhaitez réinitialiser le mot de passe"

# Demander le motif de la réinitialisation
$reason = Read-Host "Entrez le motif de la réinitialisation du mot de passe (mesure de sécurité suite incident, mot de passe oublié, à la demande de l’utilisateur, etc.)"

# Demander le nouveau mot de passe
$newPassword = $null
while (-not $newPassword) {
    $newPassword = Get-SecurePassword
}

# Appel de la fonction pour réinitialiser le mot de passe
Reset-UserPassword -username $username -reason $reason -newPassword $newPassword
