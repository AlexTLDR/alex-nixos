#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="/etc/nixos"
BACKUP_DIR="/etc/nixos.backup"

echo -e "${GREEN}NixOS Configuration Installer${NC}"
echo "================================"
echo "This script will symlink ${SCRIPT_DIR} to ${TARGET_DIR}"
echo ""

# Check if we're running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: This script must be run as root${NC}" 
   echo "Please run: sudo $0"
   exit 1
fi

# Check if /etc/nixos exists
if [[ -e "$TARGET_DIR" ]]; then
    if [[ -L "$TARGET_DIR" ]]; then
        # It's already a symlink
        CURRENT_TARGET=$(readlink -f "$TARGET_DIR")
        if [[ "$CURRENT_TARGET" == "$SCRIPT_DIR" ]]; then
            echo -e "${GREEN}✓ Symlink already points to the correct location${NC}"
            exit 0
        else
            echo -e "${YELLOW}Warning: ${TARGET_DIR} is a symlink to ${CURRENT_TARGET}${NC}"
            read -p "Do you want to replace it? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Aborted."
                exit 1
            fi
            rm "$TARGET_DIR"
        fi
    else
        # It's a regular directory
        echo -e "${YELLOW}Warning: ${TARGET_DIR} exists and is not a symlink${NC}"
        read -p "Do you want to back it up to ${BACKUP_DIR}? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if [[ -e "$BACKUP_DIR" ]]; then
                echo -e "${RED}Error: Backup directory ${BACKUP_DIR} already exists${NC}"
                exit 1
            fi
            echo "Backing up ${TARGET_DIR} to ${BACKUP_DIR}..."
            mv "$TARGET_DIR" "$BACKUP_DIR"
            echo -e "${GREEN}✓ Backup created${NC}"
        else
            echo "Aborted."
            exit 1
        fi
    fi
fi

# Create the symlink
echo "Creating symlink ${TARGET_DIR} -> ${SCRIPT_DIR}..."
ln -s "$SCRIPT_DIR" "$TARGET_DIR"
echo -e "${GREEN}✓ Symlink created successfully${NC}"

# Check if hardware-configuration.nix exists
if [[ ! -f "${SCRIPT_DIR}/hardware-configuration.nix" ]]; then
    echo ""
    echo -e "${YELLOW}Warning: hardware-configuration.nix not found in ${SCRIPT_DIR}${NC}"
    
    if [[ -f "${BACKUP_DIR}/hardware-configuration.nix" ]]; then
        read -p "Copy hardware-configuration.nix from backup? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            cp "${BACKUP_DIR}/hardware-configuration.nix" "${SCRIPT_DIR}/hardware-configuration.nix"
            # Get the original user (who ran sudo)
            ORIGINAL_USER="${SUDO_USER:-$USER}"
            if [[ "$ORIGINAL_USER" != "root" ]]; then
                chown "$ORIGINAL_USER:$(id -gn $ORIGINAL_USER)" "${SCRIPT_DIR}/hardware-configuration.nix"
            fi
            echo -e "${GREEN}✓ hardware-configuration.nix copied${NC}"
        fi
    else
        echo "You'll need to generate it with: nixos-generate-config --show-hardware-config > ${SCRIPT_DIR}/hardware-configuration.nix"
    fi
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "You can now rebuild your system with:"
echo "  sudo nixos-rebuild switch --flake /etc/nixos#nixos"
echo ""
echo "Or from the config directory:"
echo "  cd /etc/nixos"
echo "  sudo nixos-rebuild switch --flake .#nixos"
