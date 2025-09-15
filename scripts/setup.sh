#!/bin/bash

# Ubuntu Custom ISO Builder - Setup Script
# Installs dependencies and prepares the environment

set -e

echo "Ubuntu Custom ISO Builder - Setup"
echo "================================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Error: Please do not run this script as root"
    echo "The script will prompt for sudo when needed"
    exit 1
fi

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    echo "Error: Cannot detect operating system"
    exit 1
fi

echo "Detected OS: $OS $VERSION"

# Install dependencies based on distribution
case $OS in
    ubuntu|debian)
        echo "Installing dependencies for Ubuntu/Debian..."
        sudo apt-get update
        sudo apt-get install -y \
            xorriso \
            isolinux \
            wget \
            curl \
            genisoimage \
            squashfs-tools \
            rsync \
            git \
            make \
            docker.io \
            docker-compose
        
        # Enable and start Docker
        sudo systemctl enable docker
        sudo systemctl start docker
        
        # Add user to docker group
        sudo usermod -aG docker $USER
        ;;
    
    fedora|centos|rhel)
        echo "Installing dependencies for RHEL/Fedora..."
        if command -v dnf >/dev/null 2>&1; then
            PKG_MANAGER="dnf"
        else
            PKG_MANAGER="yum"
        fi
        
        sudo $PKG_MANAGER install -y \
            xorriso \
            syslinux \
            wget \
            curl \
            genisoimage \
            squashfs-tools \
            rsync \
            git \
            make \
            docker \
            docker-compose
        
        sudo systemctl enable docker
        sudo systemctl start docker
        sudo usermod -aG docker $USER
        ;;
    
    arch)
        echo "Installing dependencies for Arch Linux..."
        sudo pacman -Sy --noconfirm \
            xorriso \
            syslinux \
            wget \
            curl \
            cdrtools \
            squashfs-tools \
            rsync \
            git \
            make \
            docker \
            docker-compose
        
        sudo systemctl enable docker
        sudo systemctl start docker
        sudo usermod -aG docker $USER
        ;;
    
    *)
        echo "Warning: Unsupported distribution: $OS"
        echo "Please install the following packages manually:"
        echo "  - xorriso"
        echo "  - isolinux/syslinux"
        echo "  - wget, curl"
        echo "  - genisoimage/cdrtools"
        echo "  - squashfs-tools"
        echo "  - rsync, git, make"
        echo "  - docker, docker-compose"
        ;;
esac

# Check if dependencies are available
echo ""
echo "Checking dependencies..."

DEPS=(xorriso wget curl make docker git)
MISSING=()

for dep in "${DEPS[@]}"; do
    if ! command -v $dep >/dev/null 2>&1; then
        MISSING+=($dep)
    else
        echo "✓ $dep"
    fi
done

if [ ${#MISSING[@]} -ne 0 ]; then
    echo ""
    echo "Error: Missing dependencies:"
    printf "  - %s\n" "${MISSING[@]}"
    exit 1
fi

# Check Docker service
if ! systemctl is-active --quiet docker; then
    echo "Warning: Docker service is not running"
    echo "Try: sudo systemctl start docker"
fi

# Create necessary directories
echo ""
echo "Creating directories..."
mkdir -p downloads build mnt

# Set permissions
echo "Setting up permissions..."
# The user needs to be in the docker group
if ! groups $USER | grep -q docker; then
    echo ""
    echo "Note: You have been added to the 'docker' group."
    echo "Please log out and log back in for this to take effect."
    echo "Or run: newgrp docker"
fi

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Log out and log back in (for Docker group membership)"
echo "2. Run: make help"
echo "3. Build your first ISO: make build-all HARDWARE_TYPE=up2"
echo ""
echo "Example usage:"
echo "  make download              # Download Ubuntu ISO"
echo "  make build-all HARDWARE_TYPE=up2  # Build custom ISO for UP² board"
echo "  make run-server            # Start HTTP configuration server"
echo "  make write-usb USB_DEVICE=/dev/sdX  # Write ISO to USB"
echo ""