# ⚙️ Services partagés en entreprise et automatisation PowerShell

## 📋 Contexte du projet
Dans le cadre de ma formation de **Technicien Informatique** (OpenClassrooms), j'ai déployé et administré l'infrastructure système et réseau de l'entreprise *Axeplane Industry* sous **Windows Server 2022**, sécurisé les accès selon les bonnes pratiques **AGDLP**, configuré les sauvegardes **Veeam** et développé des **scripts PowerShell** pour automatiser l'administration quotidienne.

---

## 🛠️ Architecture & Compétences techniques mobilisées
* **Serveurs & Infrastructure (`AXEPLANE.LOC`) :** Déploiement d'un contrôleur de domaine principal (`SRV-AD` sous Windows Server 2022 Standard) et d'un serveur secondaire sans interface graphique (`SRV-BKP` sous Windows Server 2022 Core).
* **Services Réseau :** Configuration d'une étendue **DHCP** (`192.168.56.30` – `192.168.56.230`) et gestion des zones de recherche directe/inverse **DNS** (`nslookup`).
* **Active Directory (AD DS) & Sécurité :** Structuration des Unités d'Organisation (OU) par service, gestion des groupes selon la méthode **AGDLP** (Domain Local / Global), stratégie de mots de passe affinée (**PSO** : 14 caractères min., complexité, verrouillage) et déploiement de **GPO**.
* **Partages & Sauvegardes :** Configuration des partages de services et dossiers privés avec permissions **NTFS avancées** (héritage désactivé), et planification des sauvegardes automatisées sur partage réseau (`\\backup\save$`) via **Veeam Backup**.
* **Automatisation PowerShell :**
  * `ScriptUsers.ps1` : Création en masse des utilisateurs AD depuis un fichier CSV, ajout aux groupes globaux/locaux, création du dossier personnel avec ACL NTFS sur mesure et mappage automatique du lecteur réseau `P:`.
  * `ScriptMDP.ps1` : Outil interactif de réinitialisation sécurisée de mot de passe AD avec contrôle de complexité (14 caractères, majuscule, minuscule, chiffre, spécial), changement forcé à la connexion et journalisation horodatée dans un fichier de log.

---

## 📂 Livrables & Scripts du projet
* 🖥️ [Documentation complète de l'infrastructure, AD DS, NTFS et Veeam (PDF)](Hocine_Bachir_1_Configurations_072024.pdf)
* 🛡️ [Rapport des stratégies de groupe (GPO)](Hocine_Bachir_2_GPO_072024.html)
* ⚡ [Script PowerShell : Création automatisée d'utilisateurs AD et lecteurs personnels (.ps1)](Hocine_Bachir_3_ScriptUsers_072024.ps1)
* 🔐 [Script PowerShell : Réinitialisation sécurisée de mot de passe avec audit log (.ps1)](Hocine_Bachir_4_ScriptMDP_072024.ps1)
