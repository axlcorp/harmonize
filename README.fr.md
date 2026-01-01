# 🎨 Prompt Harmonizer

**Unifiez et modernisez votre environnement shell sur toutes vos machines Linux**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/Bash-5.0+-green.svg)](https://www.gnu.org/software/bash/)
[![Testé](https://img.shields.io/badge/Test%C3%A9-Debian%20%7C%20Ubuntu%20%7C%20Fedora%20%7C%20Arch-success.svg)](tests/)

Un script puissant et prêt pour la production pour **harmoniser les prompts shell**, **les bannières système** et **les outils de développement** à travers toute votre infrastructure Linux (VMs, conteneurs, bare metal, instances cloud).

```bash
# Une seule commande pour tout gérer
curl -fsSL https://raw.githubusercontent.com/<you>/harmonize/main/harmonize.sh | sudo bash -s -- install --lang fr
```

---

## ✨ Fonctionnalités

### 🚀 Fonctionnalités Principales

- **🎯 Compatibilité Universelle**: Debian, Ubuntu, Fedora, RHEL, Arch Linux
- **🐚 Support Dual Shell**: Bash + Zsh avec configuration unifiée
- **⭐ Prompt Starship**: Moderne, rapide et personnalisable (ou fallback PS1 classique)
- **📊 Badges Intelligents**: Détecte automatiquement ROLE, SSH, Conteneurs, Docker, contextes Kubernetes
- **🎨 Bannières Dynamiques**: Informations système en temps réel à la connexion (MOTD)
- **🔧 Pack Shell Moderne**: Installation optionnelle de zoxide, eza, bat, fzf
- **🪝 Hooks Extensibles**: Système de plugins pour étapes d'installation personnalisées
- **🌍 Internationalisation**: Anglais + Français (détection automatique)
- **🔄 Idempotent**: Sûr à exécuter plusieurs fois
- **⚡ Auto-Rollback**: Récupération automatique en cas d'échec
- **📦 Config Centralisée**: Chargement des configurations depuis des dépôts Git distants

### 🎭 Expérience d'Installation

Installation belle et professionnelle avec :
- ╔═══╗ En-tête encadré avec version
- [1/6] Indicateurs de progression étape par étape
- ✓ Messages d'état avec code couleur
- 📦 Boîte de résumé d'installation
- 💾 Sauvegardes automatiques horodatées

---

## 📸 Aperçu

### Prompt Starship avec Badges de Contexte

```
┌─ alex@serveur-prod [ROLE:pve] [SSH] [DOCKER:default] dans ~/projets
└❯
```

### Bannière MOTD Dynamique

```
    🖥  OS:          Ubuntu 22.04.3 LTS        ⏱  Uptime:      45 jours, 3 heures
    🏠 Hôte:        serveur-web-01             💡 IP:          192.168.1.10
    🏷  Rôle:        production                 🧠 Charge:      0.45 0.52 0.48

    💾 Mém:        [||||||||..] 78%             💽 Disque /:   [|||||.....] 45%
```

---

## 🚀 Démarrage Rapide

### Installation Basique

```bash
# Installer avec les paramètres par défaut (prompt Starship + bannière dynamique)
curl -fsSL https://raw.githubusercontent.com/VOTRE_USER/harmonize/main/harmonize.sh | sudo bash -s -- install --lang fr
```

### Installation Interactive

```bash
# Lancer l'assistant de configuration
curl -fsSL https://... | sudo bash -s -- install --interactive --lang fr
```

### Avec Outils Modernes

```bash
# Inclure zoxide, eza, bat, fzf
curl -fsSL https://... | sudo bash -s -- install --modern-tools --lang fr
```

### Options Avancées

```bash
# Options multiples
curl -fsSL https://... | sudo bash -s -- install \
  --interactive \
  --modern-tools \
  --keyboard fr \
  --lang fr
```

---

## 📖 Utilisation

### Commandes

```bash
# Installer ou mettre à jour
sudo bash harmonize.sh install
sudo bash harmonize.sh update

# Désinstaller (garde Starship par défaut)
sudo bash harmonize.sh uninstall

# Désinstaller y compris Starship
REMOVE_STARSHIP=1 sudo bash harmonize.sh uninstall

# Mode simulation (aperçu sans appliquer)
sudo bash harmonize.sh install --dry-run
```

### Variables d'Environnement

#### Configuration du Prompt

```bash
# Choisir le mode prompt
PROMPT_MODE=starship sudo bash harmonize.sh install  # Par défaut
PROMPT_MODE=ps1 sudo bash harmonize.sh install       # Prompt simple

# Forcer la mise à jour de la config Starship
FORCE_STARSHIP_CONFIG=1 sudo bash harmonize.sh update

# Mettre à jour le binaire Starship
UPDATE_STARSHIP=1 sudo bash harmonize.sh update
```

#### Configuration de la Bannière

```bash
# Utiliser la bannière dynamique (par défaut)
USE_DYNAMIC_BANNER=1 sudo bash harmonize.sh install

# Utiliser une bannière statique
USE_DYNAMIC_BANNER=0 BANNER_TEXT="Bienvenue\n" sudo bash harmonize.sh install

# Configurer la bannière SSH
CONFIGURE_SSH_BANNER=1 sudo bash harmonize.sh install  # Par défaut
CONFIGURE_SSH_BANNER=0 sudo bash harmonize.sh install  # Ignorer
```

#### Configuration du Shell

```bash
# Configurer les deux shells (par défaut)
ENABLE_BASH=1 ENABLE_ZSH=1 sudo bash harmonize.sh install

# Bash uniquement
ENABLE_BASH=1 ENABLE_ZSH=0 sudo bash harmonize.sh install

# Zsh uniquement
ENABLE_BASH=0 ENABLE_ZSH=1 sudo bash harmonize.sh install
```

#### Configuration Système

```bash
# Définir la disposition du clavier
sudo bash harmonize.sh install --keyboard fr

# Définir la langue
sudo bash harmonize.sh install --lang fr

# Installer les outils modernes
INSTALL_MODERN_TOOLS=1 sudo bash harmonize.sh install
```

---

## 🎯 Badges de Contexte

Harmonize détecte automatiquement votre environnement et affiche les badges pertinents :

### Badge ROLE

Créez `/etc/role` avec le rôle de votre serveur :

```bash
# Exemples
echo "prod" | sudo tee /etc/role        # Serveur de production
echo "dev" | sudo tee /etc/role         # Développement
echo "pve" | sudo tee /etc/role         # Proxmox VE
echo "k8s-worker" | sudo tee /etc/role  # Worker Kubernetes
echo "docker" | sudo tee /etc/role      # Hôte Docker
```

Si `/etc/role` n'existe pas, Harmonize utilise des heuristiques :
- Détecte Proxmox VE → `pve`
- Détecte Docker → `docker`
- Détecte Kubernetes → `k8s`

### Badges Auto-Détectés

- **SSH**: Affiché lors d'une connexion SSH (`$SSH_CONNECTION`)
- **CT**: Détection de conteneur (Docker, LXC via `/.dockerenv`, `/run/.containerenv`, cgroups)
- **DOCKER:context**: Contexte Docker actuel si docker est disponible
- **K8S:context**: Contexte kubectl actuel si kubectl est disponible

---

## 🪝 Système de Hooks

Étendez Harmonize avec des scripts personnalisés à des points d'exécution spécifiques.

### Hooks Disponibles

| Point de Hook | Quand il s'exécute | Cas d'usage |
|---------------|-------------------|-------------|
| `pre-install/` | Avant le début de l'installation | Sauvegardes perso, validations |
| `post-deps/` | Après installation des dépendances | Configuration dépôts, sécurité |
| `post-banners/` | Après configuration des bannières | Messages MOTD personnalisés |
| `post-tools/` | Après installation outils modernes | Configs spécifiques aux outils |
| `post-starship/` | Après installation de Starship | Modules Starship personnalisés |
| `post-shells/` | Après application configs shell | Alias shell, fonctions |
| `post-install/` | Après installation complète | Logiciels additionnels, setup final |
| `pre-uninstall/` | Avant désinstallation | Préparation nettoyage |
| `post-uninstall/` | Après désinstallation | Nettoyage final |

### Créer des Hooks

**1. Créer le script hook :**

```bash
sudo nano /etc/harmonize/hooks.d/post-install/01-mes-outils.sh
```

**2. Écrire votre hook :**

```bash
#!/usr/bin/env bash
# Installer les outils standards de l'entreprise

log "Installation des outils entreprise..."

# Utiliser les fonctions Harmonize
install_packages htop ncdu tree jq

# Accéder aux variables Harmonize
if [[ "$OS_ID" == "ubuntu" ]]; then
  install_packages outil-specifique-ubuntu
fi

print_success "Outils entreprise installés"
```

**3. Le rendre exécutable :**

```bash
sudo chmod +x /etc/harmonize/hooks.d/post-install/01-mes-outils.sh
```

### Exemples de Hooks

Consultez [`examples/hooks/`](examples/hooks/) pour des exemples prêts à l'emploi :

- **Mises à jour de Sécurité**: Patching automatique de sécurité
- **Alias Docker**: Raccourcis Docker utiles
- **Configuration Vim**: Setup vim moderne
- **Configuration Tmux**: Défauts tmux sensés
- **MOTD Personnalisé**: Messages de bienvenue
- **Sauvegarde Pré-installation**: Sauvegardes de sécurité additionnelles

### Fonctions Disponibles dans les Hooks

Les hooks ont accès à toutes les fonctions Harmonize :

```bash
# Gestion de paquets
install_packages pkg1 pkg2 pkg3

# Logging
log "message"
print_success "Message de succès"
print_info "Message d'info"
print_warning "Message d'avertissement"
print_error "Message d'erreur"

# Variables
$OS_ID           # debian, ubuntu, fedora, arch, etc.
$PKG_MGR         # apt, dnf, pacman
$DRY_RUN         # 0 ou 1
$PROMPT_MODE     # starship ou ps1
```

---

## 🌐 Configuration Centralisée

Chargez les configurations depuis un dépôt Git distant pour des déploiements cohérents.

### Configuration

**1. Créer un dépôt de configuration :**

```bash
git init harmonize-config
cd harmonize-config

# Ajouter une bannière personnalisée
cat > banner.txt <<'EOF'
╔═══════════════════════════════════════╗
║   ACME Corp - Accès Autorisé Seulement║
╚═══════════════════════════════════════╝
EOF

# Ajouter une config Starship personnalisée
cp ~/.config/starship.toml .

# Ajouter un générateur de bannière personnalisé (optionnel)
cp /chemin/vers/generate-banner.sh .

git add .
git commit -m "Config initiale"
git push origin main
```

**2. Utiliser la configuration :**

```bash
export CONFIG_URL_BASE="https://raw.githubusercontent.com/acme-corp/harmonize-config/main"
curl -fsSL https://... | sudo -E bash -s -- install
```

### Fichiers de Configuration

| Fichier | But | Auto-Chargé |
|---------|-----|-------------|
| `banner.txt` | Texte de bannière statique | ✅ Oui |
| `starship.toml` | Configuration Starship | ✅ Oui |
| `generate-banner.sh` | Générateur de bannière dynamique | ✅ Oui |

Voir [config/README.md](config/README.md) pour la documentation détaillée.

---

## 📁 Emplacements des Fichiers

### Fichiers d'Installation

```
/usr/local/bin/starship              # Binaire Starship
/usr/local/bin/harmonize-banner      # Générateur de bannière dynamique
/etc/bash.bashrc                     # Config Bash globale
/etc/zsh/zshrc                       # Config Zsh globale
/etc/issue                           # Bannière connexion console
/etc/issue.net                       # Bannière connexion réseau
/etc/ssh/sshd_config                 # Config daemon SSH (si activé)
/etc/update-motd.d/99-harmonize-banner  # Script MOTD
```

### État & Logs

```
/var/lib/prompt-harmonizer/
  └── state.env                      # État de l'installation

/var/log/prompt-harmonizer.log       # Logs détaillés

/var/backups/prompt-harmonizer/
  └── backup-AAAAMMJJ-HHMMSS/        # Sauvegardes automatiques
```

### Hooks

```
/etc/harmonize/hooks.d/
  ├── pre-install/
  ├── post-deps/
  ├── post-banners/
  ├── post-tools/
  ├── post-starship/
  ├── post-shells/
  ├── post-install/
  ├── pre-uninstall/
  └── post-uninstall/
```

### Configuration Utilisateur

```
~/.config/starship.toml              # Config Starship par utilisateur
                                     # (root + tous UID >= 1000)
```

---

## 🧪 Tests

Harmonize inclut une suite de tests complète :

### Vérification Rapide

```bash
./tests/quick-check.sh
# Exécute 35+ vérifications en quelques secondes
```

### Tests Unitaires

```bash
./tests/unit-tests.sh
# 16 tests automatisés
```

### Suite de Tests Complète

```bash
# Tester sur toutes les distributions supportées
./tests/run-tests.sh

# Sortie verbose
VERBOSE=1 ./tests/run-tests.sh

# Tester un mode spécifique
TEST_MODE=basic ./tests/run-tests.sh
```

### Tests Docker

```bash
# Tester sur Debian
docker build -t harmonize-test -f tests/Dockerfile.debian .

# Tester sur Ubuntu avec outils modernes
docker build -t harmonize-test -f tests/Dockerfile.ubuntu .

# Tester sur Fedora
docker build -t harmonize-test -f tests/Dockerfile.fedora .

# Tester sur Arch Linux
docker build -t harmonize-test -f tests/Dockerfile.arch .
```

---

## 🔒 Sécurité & Sûreté

### Fonctionnalités de Sécurité Intégrées

- ✅ **Sauvegardes automatiques** avant toute modification
- ✅ **Rollback en cas d'échec** - récupération automatique si l'installation échoue
- ✅ **Opérations idempotentes** - sûr à exécuter plusieurs fois
- ✅ **Blocs gérés** - marqueurs clairs pour les sections contrôlées par Harmonize
- ✅ **Validation des entrées** - toutes les fonctions valident les paramètres
- ✅ **Gestion des erreurs** - vérification et rapport d'erreurs complets
- ✅ **Vérifications des prérequis** - vérifie les exigences système avant l'installation
- ✅ **Mode simulation** - aperçu des changements sans les appliquer

### Bonnes Pratiques de Sécurité

1. **Examiner avant d'installer** : Utiliser `--dry-run` pour prévisualiser les changements
2. **Vérifier les téléchargements** : Toujours utiliser des URLs HTTPS
3. **Vérifier les hooks** : Examiner les scripts de hook avant exécution (ils s'exécutent en root)
4. **Utiliser le contrôle de version** : Épingler à des versions spécifiques pour la production
5. **Tester d'abord** : Utiliser des conteneurs Docker pour les tests

### Rollback

Rollback automatique en cas d'échec, ou restauration manuelle :

```bash
# Voir les sauvegardes
ls -la /var/backups/prompt-harmonizer/

# Restauration manuelle (si nécessaire)
BACKUP_DIR=/var/backups/prompt-harmonizer/backup-AAAAMMJJ-HHMMSS
sudo cp -a $BACKUP_DIR/bash.bashrc /etc/
sudo cp -a $BACKUP_DIR/issue /etc/
```

---

## 🐛 Dépannage

### Problèmes Courants

**"Ce script doit être exécuté en root"**
```bash
# Solution : Utiliser sudo
sudo bash harmonize.sh install
```

**"Commandes requises manquantes"**
```bash
# Debian/Ubuntu
sudo apt-get install curl perl coreutils

# Fedora/RHEL
sudo dnf install curl perl coreutils
```

**"Starship pas dans le PATH"**
```bash
# Ajouter au PATH
export PATH=$PATH:/usr/local/bin
source /etc/bash.bashrc
```

**Installation échouée**
```bash
# Consulter les logs
tail -100 /var/log/prompt-harmonizer.log

# Le rollback automatique restaurera l'état précédent
```

Voir **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** pour un guide de dépannage complet (en anglais).

---

## 📚 Documentation

- **[CHANGELOG.md](CHANGELOG.md)** - Historique des versions et changements
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Guide de dépannage détaillé
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Comment contribuer
- **[config/README.md](config/README.md)** - Guide de configuration centralisée
- **[LICENSE](LICENSE)** - Licence MIT

---

## 🤝 Contribuer

Les contributions sont les bienvenues ! Voir [CONTRIBUTING.md](CONTRIBUTING.md) pour les directives.

### Développement

```bash
# Cloner le dépôt
git clone https://github.com/VOTRE_USER/harmonize.git
cd harmonize

# Exécuter les tests
./tests/quick-check.sh
./tests/unit-tests.sh

# Tester les changements
sudo bash harmonize.sh install --dry-run
```

---

## 📜 Licence

Licence MIT - voir [LICENSE](LICENSE) pour les détails.

---

## 🙏 Crédits

- **[Starship](https://starship.rs/)** - Le prompt minimal, ultra-rapide et infiniment personnalisable
- **Outils Shell Modernes** : [zoxide](https://github.com/ajeetdsouza/zoxide), [eza](https://github.com/eza-community/eza), [bat](https://github.com/sharkdp/bat), [fzf](https://github.com/junegunn/fzf)

---

## 🎯 Cas d'Usage

### Standardisation d'Infrastructure

Déployez des environnements shell cohérents sur :
- 🏢 **Infrastructure d'entreprise** - Expérience unifiée pour tous les admins
- ☁️ **Déploiements cloud** - Instances AWS, Azure, GCP
- 🐳 **Environnements conteneurs** - Nœuds Docker, Kubernetes
- 💻 **Homelab** - Proxmox VE, conteneurs LXC, VMs
- 🔬 **Environnements de développement** - Machines locales, serveurs de dev

### Collaboration d'Équipe

- Partager les configurations via dépôts Git
- Imposer les standards d'entreprise avec les hooks
- Fournir une conscience du contexte (rôles prod/dev/staging)
- Simplifier l'onboarding des nouveaux membres de l'équipe

---

## 📊 Comparaison Rapide

| Fonctionnalité | Harmonize | Setup Manuel | Autres Outils |
|----------------|-----------|--------------|---------------|
| Support multi-distro | ✅ 5 distros | ⚠️ Manuel par distro | ⚠️ Limité |
| Rollback automatique | ✅ Oui | ❌ Non | ⚠️ Rare |
| Système de hooks | ✅ 9 points | ❌ Non | ⚠️ Limité |
| Config centralisée | ✅ Basé Git | ❌ Sync manuel | ⚠️ Varie |
| Bannières dynamiques | ✅ Intégré | ⚠️ Scripts perso | ❌ Non |
| Idempotent | ✅ Oui | ⚠️ Dépend | ⚠️ Varie |
| Suite de tests | ✅ 35+ tests | ❌ Non | ⚠️ Limité |

---

<div align="center">

**Fait avec ❤️ pour les administrateurs système et ingénieurs DevOps**

[Signaler un Bug](https://github.com/VOTRE_USER/harmonize/issues) · [Demander une Fonctionnalité](https://github.com/VOTRE_USER/harmonize/issues) · [Documentation](https://github.com/VOTRE_USER/harmonize/wiki)

</div>
