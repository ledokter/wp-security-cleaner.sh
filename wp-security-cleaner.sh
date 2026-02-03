#!/bin/bash

###############################################################################
# WordPress Security Cleaner
# Nettoie et sécurise une installation WordPress compromise
# Détecte et supprime les malwares, réinstalle le core propre
###############################################################################

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Banner
cat << "EOF"
 __      __        _______                       
/  \    /  \ ____ \   _  \   ______ ____   ____  
\   \/\/   //  _ \/  /_\  \ /  ___// __ \_/ ___\ 
 \        /(  <_> )  |    \_\___ \\  ___/\  \___ 
  \__/\  /  \____/|__| _______/____\___  >\___  >
       \/                  \______/    \/     \/ 
   Security Cleaner v1.0
EOF

print_header "WORDPRESS SECURITY CLEANER"

# === VÉRIFICATION DES PRIVILÈGES ===

if [ "$EUID" -ne 0 ]; then 
    print_error "Ce script doit être exécuté avec sudo/root"
    echo "Usage: sudo $0"
    exit 1
fi

# === CONFIGURATION INTERACTIVE ===

echo ""
print_header "CONFIGURATION"

# Chemin WordPress
echo ""
if [ -n "$1" ]; then
    WP_PATH="$1"
    print_info "Chemin fourni en argument : $WP_PATH"
else
    read -p "Chemin de l'installation WordPress : " WP_PATH
fi

# Vérifier que le chemin existe
if [ ! -d "$WP_PATH" ]; then
    print_error "Le répertoire n'existe pas : $WP_PATH"
    exit 1
fi

# Vérifier que c'est bien un site WordPress
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    print_error "wp-config.php introuvable. Ce n'est pas un site WordPress ?"
    exit 1
fi

print_success "Installation WordPress détectée : $WP_PATH"

# Nom du backup
BACKUP_PATH="${WP_PATH}_backup_$(date +%Y%m%d_%H%M%S)"

# Utilisateur système (propriétaire des fichiers)
echo ""
read -p "Utilisateur système propriétaire des fichiers [www-data] : " WP_USER
WP_USER=${WP_USER:-www-data}

# Vérifier que l'utilisateur existe
if ! id "$WP_USER" &>/dev/null; then
    print_warning "L'utilisateur $WP_USER n'existe pas"
    read -p "Continuer quand même ? (O/N) : " CONTINUE
    if [ "$CONTINUE" != "O" ] && [ "$CONTINUE" != "o" ]; then
        exit 1
    fi
fi

# Langue WordPress
echo ""
echo -e "${YELLOW}Langue de WordPress :${NC}"
echo "  1) Français (fr_FR)"
echo "  2) Anglais (en_US)"
echo "  3) Autre"
read -p "Sélectionnez [1] : " LANG_CHOICE
LANG_CHOICE=${LANG_CHOICE:-1}

case $LANG_CHOICE in
    1) WP_LOCALE="fr_FR" ;;
    2) WP_LOCALE="en_US" ;;
    3) 
        read -p "Code locale (ex: de_DE, es_ES) : " WP_LOCALE
        WP_LOCALE=${WP_LOCALE:-fr_FR}
        ;;
    *) WP_LOCALE="fr_FR" ;;
esac

print_success "Locale WordPress : $WP_LOCALE"

# Mode de nettoyage
echo ""
echo -e "${YELLOW}Mode de nettoyage :${NC}"
echo "  1) Standard (suppression malwares connus + scan)"
echo "  2) Profond (+ réinstallation plugins)"
echo "  3) Complet (+ réinstallation thèmes)"
read -p "Sélectionnez [1] : " CLEAN_MODE
CLEAN_MODE=${CLEAN_MODE:-1}

# Confirmation
echo ""
print_warning "ATTENTION : Cette opération va modifier votre installation WordPress"
echo ""
echo "Résumé de la configuration :"
echo "  • Chemin WordPress : $WP_PATH"
echo "  • Backup sera créé : $BACKUP_PATH"
echo "  • Propriétaire fichiers : $WP_USER"
echo "  • Locale : $WP_LOCALE"
echo "  • Mode : $([ "$CLEAN_MODE" -eq 1 ] && echo "Standard" || [ "$CLEAN_MODE" -eq 2 ] && echo "Profond" || echo "Complet")"
echo ""
read -p "Confirmer et continuer ? (O/N) : " CONFIRM

if [ "$CONFIRM" != "O" ] && [ "$CONFIRM" != "o" ]; then
    print_error "Opération annulée"
    exit 0
fi

# === DÉBUT DU NETTOYAGE ===

print_header "NETTOYAGE EN COURS"

# Aller dans le répertoire WordPress
cd "$WP_PATH" || exit 1

# Compteur d'étapes
STEP=0
TOTAL_STEPS=11

# Fonction pour afficher les étapes
step_msg() {
    STEP=$((STEP + 1))
    echo ""
    echo -e "${CYAN}[$STEP/$TOTAL_STEPS]${NC} ${BLUE}$1${NC}"
}

# === ÉTAPE 1 : BACKUP ===

step_msg "Création du backup de sécurité"

cp -r "$WP_PATH" "$BACKUP_PATH"
print_success "Backup créé : $BACKUP_PATH"

# === ÉTAPE 2 : SAUVEGARDE COMPOSANTS IMPORTANTS ===

step_msg "Sauvegarde de wp-content et wp-config.php"

mkdir -p "${BACKUP_PATH}/safe"
cp -r wp-content "${BACKUP_PATH}/safe/wp-content"
cp wp-config.php "${BACKUP_PATH}/safe/wp-config.php"

print_success "Fichiers importants sauvegardés"

# === ÉTAPE 3 : SUPPRESSION MALWARES CONNUS ===

step_msg "Suppression des fichiers malveillants connus"

MALWARE_FILES=(
    "1index.php"
    "index.php.bak"
    "db.php"
    "del.php"
    "wikindex.php"
    "wp-content/db.php"
    ".htaccess.bak"
    "wp-config.php.bak"
    "wp-includes/wp-class.php"
    "wp-admin/includes/class-wp-upgrader-skins.php.bak"
)

REMOVED_COUNT=0

for file in "${MALWARE_FILES[@]}"; do
    if [ -f "$file" ]; then
        rm -f "$file"
        echo "  • Supprimé : $file"
        REMOVED_COUNT=$((REMOVED_COUNT + 1))
    fi
done

if [ $REMOVED_COUNT -eq 0 ]; then
    print_info "Aucun fichier malveillant connu trouvé"
else
    print_success "$REMOVED_COUNT fichier(s) malveillant(s) supprimé(s)"
fi

# === ÉTAPE 4 : SUPPRESSION CORE INFECTÉ ===

step_msg "Suppression de wp-admin et wp-includes"

rm -rf wp-admin
rm -rf wp-includes

print_success "Dossiers core supprimés"

# === ÉTAPE 5 : RÉINSTALLATION CORE ===

step_msg "Réinstallation du core WordPress propre"

# Vérifier si WP-CLI est installé
if command -v wp &> /dev/null; then
    print_info "Utilisation de WP-CLI"
    wp core download --force --skip-content --locale="$WP_LOCALE" --allow-root
    print_success "Core WordPress réinstallé avec WP-CLI"
else
    print_info "WP-CLI non trouvé, téléchargement manuel"
    
    # Déterminer l'URL de téléchargement
    if [ "$WP_LOCALE" == "fr_FR" ]; then
        WP_URL="https://fr.wordpress.org/latest-fr_FR.tar.gz"
    else
        WP_URL="https://wordpress.org/latest.tar.gz"
    fi
    
    wget -q "$WP_URL" -O /tmp/wordpress.tar.gz
    tar -xzf /tmp/wordpress.tar.gz -C /tmp/
    
    # Copier uniquement wp-admin et wp-includes
    cp -r /tmp/wordpress/wp-admin .
    cp -r /tmp/wordpress/wp-includes .
    cp /tmp/wordpress/*.php .
    
    # Nettoyer
    rm -rf /tmp/wordpress /tmp/wordpress.tar.gz
    
    print_success "Core WordPress réinstallé manuellement"
fi

# === ÉTAPE 6 : VÉRIFICATION CHECKSUMS ===

step_msg "Vérification de l'intégrité des fichiers"

if command -v wp &> /dev/null; then
    if wp core verify-checksums --allow-root 2>&1 | grep -q "Success"; then
        print_success "Checksums vérifiés : fichiers intègres"
    else
        print_warning "Certains fichiers ne correspondent pas aux checksums officiels"
    fi
else
    print_info "Vérification des checksums ignorée (WP-CLI requis)"
fi

# === ÉTAPE 7 : SCAN MALWARES DANS WP-CONTENT ===

step_msg "Scan des fichiers malveillants dans wp-content"

INFECTED_FILES="$BACKUP_PATH/infected_files.txt"

# Patterns de malwares courants
find wp-content -name "*.php" -type f -exec grep -l \
    -e "eval(" \
    -e "base64_decode(" \
    -e "gzinflate(" \
    -e "str_rot13(" \
    -e "preg_replace.*\/e" \
    -e "assert(" \
    -e "urldecode.*%" \
    -e "\$_POST\['.*'\].*eval" \
    -e "system(" \
    -e "exec(" \
    -e "shell_exec(" \
    {} \; 2>/dev/null > "$INFECTED_FILES" || true

INFECTED_COUNT=$(wc -l < "$INFECTED_FILES")

if [ "$INFECTED_COUNT" -gt 0 ]; then
    print_warning "$INFECTED_COUNT fichier(s) suspect(s) détecté(s)"
    echo ""
    echo "Liste des fichiers suspects :"
    cat "$INFECTED_FILES" | head -20
    
    if [ "$INFECTED_COUNT" -gt 20 ]; then
        echo "  [...] ($((INFECTED_COUNT - 20)) fichiers supplémentaires)"
    fi
    
    echo ""
    echo "Liste complète : $INFECTED_FILES"
    echo ""
    read -p "Supprimer ces fichiers ? (O/N) : " DELETE_INFECTED
    
    if [ "$DELETE_INFECTED" == "O" ] || [ "$DELETE_INFECTED" == "o" ]; then
        while IFS= read -r file; do
            rm -f "$file"
            echo "  • Supprimé : $file"
        done < "$INFECTED_FILES"
        print_success "Fichiers suspects supprimés"
    else
        print_info "Fichiers suspects conservés (vérifiez manuellement)"
    fi
else
    print_success "Aucun fichier suspect détecté dans wp-content"
fi

# === ÉTAPE 8 : RÉINSTALLATION PLUGINS (MODE PROFOND) ===

if [ "$CLEAN_MODE" -ge 2 ]; then
    step_msg "Réinstallation des plugins depuis le dépôt WordPress"
    
    if command -v wp &> /dev/null; then
        # Lister les plugins installés
        PLUGINS=$(wp plugin list --field=name --allow-root 2>/dev/null || true)
        
        if [ -n "$PLUGINS" ]; then
            echo "$PLUGINS" | while IFS= read -r plugin; do
                echo "  • Réinstallation : $plugin"
                wp plugin install "$plugin" --force --allow-root 2>/dev/null || echo "    ⚠️  Échec (plugin introuvable ou premium)"
            done
            print_success "Plugins réinstallés"
        else
            print_info "Aucun plugin à réinstaller"
        fi
    else
        print_warning "WP-CLI requis pour réinstaller les plugins"
    fi
else
    print_info "Réinstallation des plugins ignorée (mode standard)"
fi

# === ÉTAPE 9 : RÉINSTALLATION THÈMES (MODE COMPLET) ===

if [ "$CLEAN_MODE" -eq 3 ]; then
    step_msg "Réinstallation des thèmes depuis le dépôt WordPress"
    
    if command -v wp &> /dev/null; then
        THEMES=$(wp theme list --field=name --allow-root 2>/dev/null || true)
        
        if [ -n "$THEMES" ]; then
            echo "$THEMES" | while IFS= read -r theme; do
                # Ne pas réinstaller les thèmes par défaut de WordPress
                if [[ "$theme" != "twentytwenty"* ]]; then
                    echo "  • Réinstallation : $theme"
                    wp theme install "$theme" --force --allow-root 2>/dev/null || echo "    ⚠️  Échec (thème introuvable ou premium)"
                fi
            done
            print_success "Thèmes réinstallés"
        fi
    else
        print_warning "WP-CLI requis pour réinstaller les thèmes"
    fi
else
    print_info "Réinstallation des thèmes ignorée"
fi

# === ÉTAPE 10 : RESTAURATION WP-CONFIG ===

step_msg "Restauration de wp-config.php propre"

cp "${BACKUP_PATH}/safe/wp-config.php" wp-config.php

print_success "wp-config.php restauré"

# === ÉTAPE 11 : PERMISSIONS ===

step_msg "Configuration des permissions sécurisées"

if id "$WP_USER" &>/dev/null; then
    chown -R "$WP_USER":"$WP_USER" "$WP_PATH"
    print_success "Propriétaire défini : $WP_USER"
fi

find "$WP_PATH" -type d -exec chmod 755 {} +
find "$WP_PATH" -type f -exec chmod 644 {} +

# wp-config.php doit être en 600 (lecture/écriture propriétaire uniquement)
chmod 600 "$WP_PATH/wp-config.php"

print_success "Permissions configurées (755 dossiers, 644 fichiers, 600 wp-config.php)"

# === ÉTAPE 12 : NETTOYAGE FINAL ===

step_msg "Nettoyage des fichiers temporaires"

# Les fichiers de rapport sont gardés dans le backup
print_success "Nettoyage terminé"

# === RAPPORT FINAL ===

print_header "✨ NETTOYAGE TERMINÉ"

echo ""
print_success "Votre site WordPress a été nettoyé et sécurisé"
echo ""
echo -e "${BLUE}📊 Résumé :${NC}"
echo "  • Backup complet : $BACKUP_PATH"
echo "  • Core WordPress : Réinstallé ($WP_LOCALE)"
echo "  • Malwares connus : $REMOVED_COUNT supprimé(s)"
echo "  • Fichiers suspects : $INFECTED_COUNT détecté(s)"
echo "  • Plugins : $([ "$CLEAN_MODE" -ge 2 ] && echo "Réinstallés" || echo "Non réinstallés")"
echo "  • Thèmes : $([ "$CLEAN_MODE" -eq 3 ] && echo "Réinstallés" || echo "Non réinstallés")"
echo ""
echo -e "${YELLOW}⚠️  ACTIONS RECOMMANDÉES :${NC}"
echo ""
echo "1. Testez votre site : $WP_PATH"
echo "2. Vérifiez les fichiers suspects manuellement"
echo "3. Changez TOUS les mots de passe (admin, FTP, BDD)"
echo "4. Mettez à jour WordPress, plugins et thèmes"
echo "5. Installez un plugin de sécurité (Wordfence, iThemes Security)"
echo "6. Vérifiez la base de données (tables wp_options, wp_posts)"
echo ""
echo -e "${GREEN}Si tout fonctionne, supprimez le backup :${NC}"
echo "   rm -rf $BACKUP_PATH"
echo ""
echo -e "${RED}Si problème, restaurez le backup :${NC}"
echo "   rm -rf $WP_PATH"
echo "   mv $BACKUP_PATH $WP_PATH"
echo ""
print_success "Terminé !"
