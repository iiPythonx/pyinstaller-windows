#!/usr/bin/bash
# Copyright (c) 2023-2024 iiPython

sudo pacman -Syu docker docker-buildx buildkit
sudo usermod -aG docker $USER
sudo systemctl enable --now docker.service
DOCKER_BULDKIT=1 docker build --network host -t iipython-pyinstaller .
