# 🛡️ WordPress Security Cleaner

Script Bash professionnel pour **nettoyer et sécuriser une installation WordPress compromise**. Détecte et supprime les malwares, réinstalle le core WordPress propre, et restaure les permissions sécurisées.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Bash](https://img.shields.io/badge/bash-4.0%2B-orange.svg)
![WordPress](https://img.shields.io/badge/WordPress-5.0%2B-21759B.svg)

## 🚨 Quand Utiliser Ce Script ?

Utilisez ce script si votre site WordPress présente ces symptômes :

- ❌ **Redirections malveillantes** vers des sites externes
- ❌ **Spam SEO** (liens cachés dans les pages)
- ❌ **Fichiers suspects** détectés par un scan antivirus
- ❌ **Backdoors** (accès administrateur non autorisé)
- ❌ **Injections de code** dans les fichiers PHP
- ❌ **Performances dégradées** inexpliquées
- ❌ **Avertissements Google** (site piraté/malveillant)

## 🎯 Fonctionnalités

### Nettoyage Automatique

- ✅ **Backup complet** avant toute modification
- ✅ **Suppression des malwares connus** (backdoors, shells PHP)
- ✅ **Réinstallation du core WordPress** (wp-admin, wp-includes)
- ✅ **Scan avancé** de patterns malveillants dans wp-content
- ✅ **Réinstallation des plugins** depuis le dépôt officiel
- ✅ **Réinstallation des thèmes** (optionnel)
- ✅ **Permissions sécurisées** (755/644/600)
- ✅ **Vérification des checksums** (intégrité des fichiers)

### Détection de Malwares

Le script détecte ces patterns PHP malveillants :

| Pattern | Type de Malware |
|---------|-----------------|
| `eval()` | Exécution de code dynamique |
| `base64_decode()` | Code obfusqué encodé |
| `gzinflate()` | Compression pour cacher du code |
| `str_rot13()` | Obfuscation ROT13 |
| `preg_replace(.*\/e)` | Exécution via regex (deprecated) |
| `system()` / `exec()` | Commandes système |
| `shell_exec()` | Exécution shell |
| `$_POST['*'] + eval` | Backdoor POST |

## 📋 Prérequis

### Système

- **Linux** (Debian, Ubuntu, CentOS, RHEL)
- **Accès root/sudo** obligatoire
- **Bash** 4.0+
- **Serveur web** (Apache, Nginx)

### Dépendances

```bash
# Obligatoires
sudo apt install wget tar grep -y

# Optionnelles (recommandées)
sudo apt install wp-cli -y  # Pour réinstallation automatique plugins/thèmes
Installation WP-CLI (Recommandé)
bash
# Télécharger WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# Rendre exécutable
chmod +x wp-cli.phar

# Installer globalement
sudo mv wp-cli.phar /usr/local/bin/wp

# Vérifier
wp --info
🚀 Installation
Téléchargement Direct
bash
# Télécharger le script
wget https://raw.githubusercontent.com/ledokter/wordpress-security-cleaner/main/wp-security-cleaner.sh

# Rendre exécutable
chmod +x wp-security-cleaner.sh
Clone du Dépôt
bash
git clone https://github.com/ledokter/wordpress-security-cleaner.git
cd wordpress-security-cleaner
chmod +x wp-security-cleaner.sh
💻 Utilisation
Mode Interactif (Recommandé)
bash
sudo ./wp-security-cleaner.sh
Le script vous guidera à travers la configuration :

Chemin WordPress (ex: /var/www/html/monsite)

Utilisateur système (ex: www-data, apache, nginx)

Langue WordPress (fr_FR, en_US, etc.)

Mode de nettoyage (Standard, Profond, Complet)

Confirmation avant de commencer

Mode Rapide (Argument)
bash
sudo ./wp-security-cleaner.sh /var/www/html/monsite
Exemple de Session
text
 __      __        _______                       
/  \    /  \ ____ \   _  \   ______ ____   ____  
\   \/\/   //  _ \/  /_\  \ /  ___// __ \_/ ___\ 
 \        /(  <_> )  |    \_\___ \\  ___/\  \___ 
  \__/\  /  \____/|__| _______/____\___  >\___  >
       \/                  \______/    \/     \/ 
   Security Cleaner v1.0

═══════════════════════════════════════════════════════════════
 WORDPRESS SECURITY CLEANER
═══════════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════════
 CONFIGURATION
═══════════════════════════════════════════════════════════════

Chemin de l'installation WordPress : /var/www/html/monsite
✅ Installation WordPress détectée : /var/www/html/monsite

Utilisateur système propriétaire des fichiers [www-data] : 
✅ Utilisateur www-data validé

Langue de WordPress :
  1) Français (fr_FR)
  2) Anglais (en_US)
  3) Autre
Sélectionnez  : 1[1]
✅ Locale WordPress : fr_FR

Mode de nettoyage :
  1) Standard (suppression malwares connus + scan)
  2) Profond (+ réinstallation plugins)
  3) Complet (+ réinstallation thèmes)
Sélectionnez  : 2[1]

⚠️  ATTENTION : Cette opération va modifier votre installation WordPress

Résumé de la configuration :
  -  Chemin WordPress : /var/www/html/monsite
  -  Backup sera créé : /var/www/html/monsite_backup_20260203_040000
  -  Propriétaire fichiers : www-data
  -  Locale : fr_FR
  -  Mode : Profond

Confirmer et continuer ? (O/N) : O

═══════════════════════════════════════════════════════════════
 NETTOYAGE EN COURS
═══════════════════════════════════════════════════════════════

[1/11] Création du backup de sécurité
✅ Backup créé : /var/www/html/monsite_backup_20260203_040000

[2/11] Sauvegarde de wp-content et wp-config.php
✅ Fichiers importants sauvegardés

[3/11] Suppression des fichiers malveillants connus
  -  Supprimé : 1index.php
  -  Supprimé : wp-content/db.php
✅ 2 fichier(s) malveillant(s) supprimé(s)

[4/11] Suppression de wp-admin et wp-includes
✅ Dossiers core supprimés

[5/11] Réinstallation du core WordPress propre
ℹ️  Utilisation de WP-CLI
✅ Core WordPress réinstallé avec WP-CLI

[6/11] Vérification de l'intégrité des fichiers
✅ Checksums vérifiés : fichiers intègres

[7/11] Scan des fichiers malveillants dans wp-content
⚠️  14 fichier(s) suspect(s) détecté(s)

Liste des fichiers suspects :
wp-content/themes/montheme/footer.php
wp-content/plugins/contact-form/upload.php
[...]

Liste complète : /var/www/html/monsite_backup_20260203_040000/infected_files.txt

Supprimer ces fichiers ? (O/N) : O
  -  Supprimé : wp-content/themes/montheme/footer.php
  -  Supprimé : wp-content/plugins/contact-form/upload.php
✅ Fichiers suspects supprimés

[8/11] Réinstallation des plugins depuis le dépôt WordPress
  -  Réinstallation : contact-form-7
  -  Réinstallation : yoast-seo
✅ Plugins réinstallés

[9/11] Réinstallation des thèmes depuis le dépôt WordPress
ℹ️  Réinstallation des thèmes ignorée

[10/11] Restauration de wp-config.php propre
✅ wp-config.php restauré

[11/11] Configuration des permissions sécurisées
✅ Propriétaire défini : www-data
✅ Permissions configurées (755 dossiers, 644 fichiers, 600 wp-config.php)

[12/11] Nettoyage des fichiers temporaires
✅ Nettoyage terminé

═══════════════════════════════════════════════════════════════
 ✨ NETTOYAGE TERMINÉ
═══════════════════════════════════════════════════════════════

✅ Votre site WordPress a été nettoyé et sécurisé

📊 Résumé :
  -  Backup complet : /var/www/html/monsite_backup_20260203_040000
  -  Core WordPress : Réinstallé (fr_FR)
  -  Malwares connus : 2 supprimé(s)
  -  Fichiers suspects : 14 détecté(s)
  -  Plugins : Réinstallés
  -  Thèmes : Non réinstallés

⚠️  ACTIONS RECOMMANDÉES :

1. Testez votre site : /var/www/html/monsite
2. Vérifiez les fichiers suspects manuellement
3. Changez TOUS les mots de passe (admin, FTP, BDD)
4. Mettez à jour WordPress, plugins et thèmes
5. Installez un plugin de sécurité (Wordfence, iThemes Security)
6. Vérifiez la base de données (tables wp_options, wp_posts)

Si tout fonctionne, supprimez le backup :
   rm -rf /var/www/html/monsite_backup_20260203_040000

Si problème, restaurez le backup :
   rm -rf /var/www/html/monsite
   mv /var/www/html/monsite_backup_20260203_040000 /var/www/html/monsite

✅ Terminé !
🔧 Modes de Nettoyage
Mode 1 : Standard
Suppression des malwares connus

Scan des fichiers suspects

Réinstallation du core WordPress

Rapide (5-10 minutes)

Recommandé pour : Infections légères, maintenance préventive

Mode 2 : Profond
Tout du mode Standard

+ Réinstallation des plugins depuis le dépôt officiel

Moyen (10-20 minutes selon le nombre de plugins)

Recommandé pour : Infections modérées, plugins compromis

Mode 3 : Complet
Tout du mode Profond

+ Réinstallation des thèmes depuis le dépôt officiel

Long (20-30 minutes)

Recommandé pour : Infections graves, thèmes compromis

🛡️ Ce Que le Script Fait
✅ Actions Effectuées
Backup complet (copie intégrale dans un dossier daté)

Sauvegarde séparée de wp-content et wp-config.php

Suppression des fichiers malveillants connus :

1index.php, index.php.bak (backdoors)

db.php, del.php (shells PHP)

wikindex.php (malware connu)

.htaccess.bak (règles malveillantes)

Suppression de wp-admin et wp-includes (souvent infectés)

Téléchargement du core WordPress officiel (version propre)

Vérification des checksums (intégrité garantie)

Scan des patterns malveillants dans wp-content

Réinstallation des plugins/thèmes depuis les sources officielles

Restauration de wp-config.php propre

Configuration des permissions sécurisées (755/644/600)

❌ Ce Que le Script NE Fait PAS
❌ Nettoyage de la base de données (scripts injectés dans wp_options, wp_posts)

❌ Détection de thèmes/plugins premium piratés (souvent infectés)

❌ Modification des mots de passe (à faire manuellement)

❌ Configuration du pare-feu ou WAF

❌ Analyse des logs Apache/Nginx

📊 Fichiers Malveillants Détectés
Backdoors Connus
Fichier	Description
1index.php	Backdoor classique (upload de fichiers)
index.php.bak	Copie infectée de l'index
db.php	Shell PHP d'accès à la base de données
del.php	Script de suppression de fichiers
wikindex.php	Malware spécifique WordPress
Patterns Détectés (Scan)
php
// Exemples de code malveillant détecté :

eval($_POST['cmd']);                    // Backdoor POST
base64_decode("aW5qZWN0ZWQgY29kZQ=="); // Code obfusqué
<?php @system($_GET['c']); ?>          // Exécution commandes
preg_replace("/.*/e", $_POST['x']);    // Injection via regex (PHP < 7)
🔒 Sécurité Post-Nettoyage
Actions Obligatoires
Changez TOUS les mots de passe :

bash
# Dans WordPress : Utilisateurs > Modifier
# Ou via WP-CLI :
wp user update admin --user_pass=NouveauMotDePasse --allow-root
Changez les mots de passe FTP/SFTP :

bash
passwd utilisateur-ftp
Changez le mot de passe MySQL :

sql
ALTER USER 'wordpress_user'@'localhost' IDENTIFIED BY 'NouveauMotDePasse';
FLUSH PRIVILEGES;
Régénérez les clés de sécurité dans wp-config.php :

Allez sur : https://api.wordpress.org/secret-key/1.1/salt/

Remplacez les lignes define('AUTH_KEY', ...) dans wp-config.php

Plugins de Sécurité Recommandés
bash
# Installer Wordfence (scanner + firewall)
wp plugin install wordfence --activate --allow-root

# Ou iThemes Security
wp plugin install better-wp-security --activate --allow-root

# Ou Sucuri Security
wp plugin install sucuri-scanner --activate --allow-root
Hardening WordPress
Ajoutez à wp-config.php :

php
// Désactiver l'éditeur de fichiers (sécurité)
define('DISALLOW_FILE_EDIT', true);

// Désactiver l'installation de plugins/thèmes
define('DISALLOW_FILE_MODS', true);

// Forcer SSL pour l'admin
define('FORCE_SSL_ADMIN', true);

// Limiter les révisions
define('WP_POST_REVISIONS', 3);
Protéger wp-config.php avec .htaccess
text
# Ajouter dans .htaccess (Apache)
<files wp-config.php>
  order allow,deny
  deny from all
</files>
🐛 Dépannage
Erreur : "Permission denied"
Cause : Script non exécuté avec sudo

Solution :

bash
sudo ./wp-security-cleaner.sh
Erreur : "wp-config.php introuvable"
Cause : Mauvais chemin ou pas un site WordPress

Solution :

bash
# Trouver le bon chemin
find /var/www -name "wp-config.php" 2>/dev/null

# Relancer avec le bon chemin
sudo ./wp-security-cleaner.sh /var/www/html/monsite
Erreur : "WP-CLI not found"
Cause : WP-CLI non installé (pas bloquant)

Solution :

bash
# Installer WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
Alternative : Le script fonctionne sans WP-CLI (téléchargement manuel)

Site cassé après le nettoyage
Cause : Thème ou plugin personnalisé infecté et supprimé

Solution :

bash
# Restaurer le backup
sudo rm -rf /var/www/html/monsite
sudo mv /var/www/html/monsite_backup_20260203_040000 /var/www/html/monsite

# Identifier le fichier problématique dans le rapport
cat /var/www/html/monsite_backup_20260203_040000/infected_files.txt

# Nettoyer manuellement le fichier infecté
nano /var/www/html/monsite/wp-content/themes/montheme/functions.php
Base de données toujours infectée
Cause : Le script ne nettoie pas la BDD

Solution :

bash
# Rechercher du code malveillant dans la BDD
wp db query "SELECT * FROM wp_options WHERE option_value LIKE '%base64%'" --allow-root

# Nettoyer une option infectée
wp option delete option_infectee --allow-root

# Ou avec MySQL directement
mysql -u root -p wordpress_db -e "UPDATE wp_options SET option_value = '' WHERE option_name = 'option_infectee';"
📚 Ressources
Documentation
WordPress Security

Sucuri Blog

Wordfence Learning Center

WP-CLI Commands

Outils Complémentaires
Sucuri SiteCheck - Scanner en ligne gratuit

VirusTotal - Analyse de fichiers suspects

Google Search Console - Vérifier les avertissements Google

Support
Issues GitHub

WordPress Support Forum

⚠️ Avertissement
⚠️ Testez toujours sur un environnement de développement d'abord

⚠️ Un backup est automatiquement créé mais vérifiez-le

⚠️ Ce script ne remplace pas un audit de sécurité professionnel

⚠️ Nettoyez la base de données manuellement après le script

⚠️ Changez tous les mots de passe après le nettoyage

🤝 Contribution
Les contributions sont bienvenues !

Fork ce dépôt

Créez une branche : git checkout -b feature/amelioration

Committez : git commit -m "Ajout détection malware X"

Push : git push origin feature/amelioration

Ouvrez une Pull Request

📝 Changelog
v1.0.0 (2026-02-03)
🎉 Version initiale

✨ Configuration interactive complète

✨ 3 modes de nettoyage (Standard, Profond, Complet)

✨ Détection de 10+ patterns de malwares

✨ Backup automatique

✨ Réinstallation core WordPress

✨ Support multi-langues

✨ Vérification checksums

✨ Permissions sécurisées

⚖️ Licence
MIT License

📬 Contact
Auteur : ledokter

⭐ Si ce script vous sauve, donnez une étoile au projet !
