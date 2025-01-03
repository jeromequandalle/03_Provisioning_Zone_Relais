#!/bin/bash

# Script d'installation de Guacamole Server et Tomcat9
# Par précaution, exécutez ce script avec sudo ou en tant que root.

set -e  # Arrête l'exécution en cas d'erreur

# Fonction pour afficher un message formaté
function log() {
    echo -e "\n\e[1;32m$1\e[0m\n"
}

# Fonction pour installer des paquets
function install_packages() {
    log "Mise à jour des paquets et installation des dépendances..."
    sudo apt update -y
    sudo apt install -y "$@"
}

# Dépendances pour Guacamole Server
GUACAMOLE_DEPENDENCIES=(
    make build-essential libcairo2-dev libjpeg62-turbo-dev libpng-dev libtool-bin
    uuid-dev libossp-uuid-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev
    freerdp2-dev libpango1.0-dev libssh2-1-dev libvncserver-dev libtelnet-dev
    libwebsockets-dev libssl-dev libvorbis-dev libwebp-dev libpulse-dev
)

# Installation des dépendances nécessaires
install_packages "${GUACAMOLE_DEPENDENCIES[@]}"

# Télécharger et compiler Guacamole Server
GUACAMOLE_VERSION="1.5.4"
GUACAMOLE_SERVER_ARCHIVE="guacamole-server-${GUACAMOLE_VERSION}.tar.gz"
GUACAMOLE_SERVER_URL="https://downloads.apache.org/guacamole/${GUACAMOLE_VERSION}/source/${GUACAMOLE_SERVER_ARCHIVE}"

log "Téléchargement et compilation de Guacamole Server..."
wget "$GUACAMOLE_SERVER_URL"
tar xzf "$GUACAMOLE_SERVER_ARCHIVE"
cd "guacamole-server-${GUACAMOLE_VERSION}"
sudo ./configure --with-systemd-dir=/etc/systemd/system/ --disable-guacenc
sudo make
sudo make install
sudo ldconfig

# Configuration du service guacd
log "Activation et démarrage du service guacd..."
sudo systemctl daemon-reload
sudo systemctl enable --now guacd

# Mise à jour du fichier hosts
log "Mise à jour du fichier /etc/hosts..."
sudo sed -i '/^::1/s/^/#/g' /etc/hosts
sudo systemctl restart guacd

# Installation de Tomcat9
log "Installation de Tomcat9..."
sudo cp /tmp/bullseye.list /etc/apt/sources.list.d/bullseye.list
sudo apt update -y
sudo apt install -y tomcat9 tomcat9-admin tomcat9-common tomcat9-user
sudo rm /etc/apt/sources.list.d/bullseye.list

# Déploiement de Guacamole
log "Déploiement de Guacamole..."
sudo mkdir -p /etc/guacamole/{extensions,lib}
sudo wget "https://downloads.apache.org/guacamole/${GUACAMOLE_VERSION}/binary/guacamole-${GUACAMOLE_VERSION}.war" -O /etc/guacamole/guacamole.war
sudo ln -s /etc/guacamole/guacamole.war /var/lib/tomcat9/webapps/
sudo systemctl restart tomcat9 guacd

# Configuration de Guacamole
log "Configuration de Guacamole..."
sudo cp /tmp/tomcat9 /etc/default/tomcat9
sudo cp /tmp/guacamole.properties /etc/guacamole/guacamole.properties
sudo ln -s /etc/guacamole /usr/share/tomcat9/.guacamole
sudo cp /tmp/user-mapping.xml /etc/guacamole/user-mapping.xml

# Redémarrage des services
log "Redémarrage des services Tomcat9 et guacd..."
sudo systemctl restart tomcat9 guacd

log "Installation terminée avec succès !"
