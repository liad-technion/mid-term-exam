#!/usr/bin/env bash
################################
# Developer: Liad Binyamin
# Purpose: Checks for pre-requirements for the exam
# Version: 0.0.1
# Date: 11.5.26
set -o errexit
set -o pipefail
set -o nounset
################################

# Checking requirements functions
check() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "✗ $1 not found, please install it to proceed."
        return 1
    fi
    echo "✓ $1"
}

# Install poetry function
poetry_installer(){
    echo "Installing poetry..."
    curl -sSL https://install.python-poetry.org | python3 - >/dev/null 2>&1
    echo "Adding poetry to PATH..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    export PATH="$HOME/.local/bin:$PATH"
    poetry --version
    echo "Poetry is successfully installed.."
}

# Check docker permissions
check_docker_permission(){
    if groups $USER | grep -q docker;
    then
        echo "✓ Docker permissions confirmed."
    else
        echo '''✗ Docker permissions not confirmed.
             To add your user to the docker group, run the following command: sudo usermod -aG docker $USER.
        '''
        exit 1
    fi
}

# Check nginx service is off
check_nginx_service(){
    if systemctl is-active --quiet nginx;
    then
        echo "✓ Nginx service is off."
    else
        echo "✗ Nginx service is on. Please turn it off."
        exit 1
    fi
}


check docker && check_docker_permission || echo "  → install: curl -fsSL https://get.docker.com | sh"
check git || echo "  → install: sudo apt install git"
check python3 || echo "  → install: sudo apt install python3"
check pip || check pip3 || echo "  → install: sudo apt install python3-pip"
check poetry || poetry_installer
check nginx || echo "  → install: sudo apt install nginx"
check curl #Native on ubuntu
check jq || echo "  → install: sudo apt install jq"
check vim #Native on ubuntu
check nano #Native on ubuntu





