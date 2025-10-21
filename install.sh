#!/bin/bash

# Mallow Installer Script for Linux and macOS
# --------------------------------------------

# --- Configuration ---
REPO_URL="https://github.com/42Wor/mallow-cli.git"
INSTALL_DIR="/opt/mallow-cli"
SYMLINK_PATH="/usr/local/bin/mallow"

# --- Colors for Logging ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Pacman Animation Function ---
# Takes one argument: the message to display.
pacman_animation() {
    local message="$1"
    local frames=("( o< )" "(  < )" "( <  )" "(<   )" "(   <)" "(  < )")
    local delay=0.1
    local duration=3 # seconds

    echo -ne "\n"
    tput civis # Hide cursor
    end_time=$((SECONDS + duration))
    while [ $SECONDS -lt $end_time ]; do
        for frame in "${frames[@]}"; do
            echo -ne "${BLUE}${frame}${NC} ${YELLOW}${message}${NC}\r"
            sleep $delay
        done
    done
    tput cnorm # Show cursor
    echo -e "\n${GREEN}✔ Done!${NC}"
}

# --- Main Script ---

# 1. Welcome Message
clear
echo -e "${GREEN}
  __  __       _          _ _ 
 |  \/  | __ _(_)_ __    | | |
 | |\/| |/ _\` | | '_ \   | | |
 | |  | | (_| | | | | |  |_|_|
 |_|  |_|\__,_|_|_| |_|  (_|_)
${NC}"
echo -e "${YELLOW}Welcome to the Mallow Installer! 🍬${NC}"
echo "This script will install Mallow on your system."
echo "You may be asked for your password to install to ${SYMLINK_PATH}."
echo ""

# 2. Check Dependencies
echo -e "[INFO] Checking for required tools (git, python3, pip)..."
command -v git >/dev/null 2>&1 || { echo -e "${RED}Error: git is not installed. Aborting.${NC}"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo -e "${RED}Error: python3 is not installed. Aborting.${NC}"; exit 1; }
command -v pip3 >/dev/null 2>&1 || { echo -e "${RED}Error: pip3 is not installed. Aborting.${NC}"; exit 1; }
echo -e "[INFO] All dependencies found."

# 3. Clone Repository
pacman_animation "Downloading Mallow from GitHub..."
if [ -d "/tmp/mallow-cli" ]; then
    rm -rf /tmp/mallow-cli
fi
git clone --depth 1 "$REPO_URL" /tmp/mallow-cli > /dev/null 2>&1

# 4. Move to Install Directory
echo -e "[INFO] Installing Mallow to ${INSTALL_DIR}..."
sudo rm -rf ${INSTALL_DIR}
sudo mv /tmp/mallow-cli ${INSTALL_DIR}

# 5. Install Python Dependencies in a Virtual Environment
echo -e "[INFO] Setting up a clean Python environment..."
sudo python3 -m venv ${INSTALL_DIR}/venv
echo -e "[INFO] Installing required packages..."
sudo ${INSTALL_DIR}/venv/bin/pip install -r ${INSTALL_DIR}/requirements.txt > /dev/null 2>&1

# 6. Create the Launcher Script
echo -e "[INFO] Creating the 'mallow' command..."
LAUNCHER_SCRIPT="#!/bin/bash\nexec ${INSTALL_DIR}/venv/bin/python3 ${INSTALL_DIR}/mallow.py \"\$@\""
echo -e "${LAUNCHER_SCRIPT}" | sudo tee ${SYMLINK_PATH} > /dev/null
sudo chmod +x ${SYMLINK_PATH}

# 7. Success Message
echo -e "\n${GREEN}-------------------------------------------${NC}"
echo -e "${GREEN}  🍬 Mallow has been successfully installed! 🍬${NC}"
echo -e "${GREEN}-------------------------------------------${NC}"
echo -e "You can now run Mallow from anywhere by typing:"
echo -e "\n  ${YELLOW}mallow list${NC}"
echo -e "\nEnjoy your soft-serve AI! ✨"