#!/usr/bin/bash
# Copyright (c) 2023-2024 iiPython

# Install docker
install_docker() {
    if command -v apt-get &> /dev/null
    then
        sudo apt-get update -yq
        sudo apt-get install ca-certificates curl gnupg -yq
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi
    if command -v pacman &> /dev/null
    then
        sudo pacman -Syu docker docker-buildx buildkit
    fi
    if command -v dnf &> /dev/null
    then
        sudo dnf -y install dnf-plugins-core
        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
        sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi

    # Post-install
    sudo usermod -aG docker $USER
    sudo systemctl enable --now docker.service
}

# Check if docker isn't installed
if ! command -v docker &> /dev/null
then
    read -p "Docker is not installed, would you like to try and automatically install it (y/N)? " yn
    case $yn in
        [Yy]* ) install_docker;;
    esac
fi

# Run container
DOCKER_BULDKIT=1 docker build --network host -t iipython-pyinstaller .
