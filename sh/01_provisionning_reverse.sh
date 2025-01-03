#!/bin/bash

# Détection de la distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "Impossible de détecter la distribution."
    exit 1
fi

# Mise à jour des paquets et installation des mises à jour
echo "Mise à jour des paquets..."
case "$DISTRO" in
    debian|ubuntu)
        sudo apt update -y && sudo apt upgrade -y
        ;;
    opensuse-leap|suse)
        sudo zypper refresh && sudo zypper update -y
        ;;
    almalinux|centos|rhel)
        sudo dnf update -y
        ;;
    *)
        echo "Distribution non prise en charge : $DISTRO"
        exit 1
        ;;
esac

# Installation de Nginx
echo "Installation de Nginx..."
case "$DISTRO" in
    debian|ubuntu)
        sudo apt install -y nginx
        ;;
    opensuse-leap|suse)
        sudo zypper install -y nginx
        ;;
    almalinux|centos|rhel)
        sudo dnf install -y nginx
        ;;
    *)
        echo "Impossible d'installer Nginx sur cette distribution : $DISTRO"
        exit 1
        ;;
esac

# Copie des fichiers de configuration Nginx
echo "Copie des fichiers de configuration Nginx..."
sudo cp /tmp/site1.conf /etc/nginx/conf.d/site1.conf
sudo cp /tmp/site2.conf /etc/nginx/conf.d/site2.conf

# Activation des sites en créant des liens symboliques (spécifique à Debian/Ubuntu)
if [[ "$DISTRO" == "debian" || "$DISTRO" == "ubuntu" ]]; then
    echo "Activation des sites (Debian/Ubuntu)..."
    sudo ln -s /etc/nginx/conf.d/site1.conf /etc/nginx/sites-enabled/
    sudo ln -s /etc/nginx/conf.d/site2.conf /etc/nginx/sites-enabled/
fi

# Redémarrage de Nginx pour prendre en compte les nouvelles configurations
echo "Redémarrage de Nginx..."
sudo systemctl restart nginx

# Activation du routage IP
echo "Activation du routage IP..."
sudo sysctl -w net.ipv4.ip_forward=1

echo "Script exécuté avec succès sur $DISTRO."
