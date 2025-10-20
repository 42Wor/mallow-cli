#!/bin/bash
set -e

# --- Configuration & Colors ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Define the hidden system directory for the virtual environment
MALLOW_ENV_DIR="$HOME/.mallow_env"
# Define the standard user binary directory
BIN_DIR="$HOME/.local/bin"

LOG_FILE="install.log"

# --- Spinner Function ---
spinner() {
    local msg="$1"
    local pid=$2
    local spin='⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    tput civis
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % ${#spin} ))
        printf "\r${spin:$i:1} ${msg}"
        sleep 0.1
    done
    tput cnorm
    printf "\r"
}

# --- Main Script ---
echo -e "${YELLOW}Starting Mallow system installation...${NC}"

# 1. Create the virtual environment in the hidden system directory
echo "Setting up virtual environment in ${CYAN}${MALLOW_ENV_DIR}${NC}..."
python3 -m venv "$MALLOW_ENV_DIR" &> /dev/null
echo "✅ Virtual environment created."

# 2. Install the project into the new environment
echo "Installing Mallow and its dependencies..."
# Run pip install in the background from the new environment
"$MALLOW_ENV_DIR/bin/pip" install -e . > "$LOG_FILE" 2>&1 &
PID=$!
spinner "Installing packages..." $PID
wait $PID
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo -e "❌ ${YELLOW}Installation failed.${NC}"
    echo "Please check the log file for details: ${YELLOW}${LOG_FILE}${NC}"
    exit $EXIT_CODE
else
    echo "✅ Packages installed successfully."
fi

# 3. Make the 'mallow' command available system-wide for the user
echo "Adding 'mallow' command to your system path..."
mkdir -p "$BIN_DIR" # Ensure the bin directory exists
# Create a symbolic link from the installed script to the user's bin folder
ln -sf "$MALLOW_ENV_DIR/bin/mallow" "$BIN_DIR/mallow"
echo "✅ Command linked to ${CYAN}${BIN_DIR}/mallow${NC}."

# 4. Check if BIN_DIR is in the user's PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo -e "\n${YELLOW}ACTION REQUIRED:${NC}"
    echo "Your PATH does not seem to include ${CYAN}${BIN_DIR}${NC}."
    echo "Please add the following line to your shell configuration file (e.g., ~/.bashrc, ~/.zshrc):"
    echo -e "\n  ${GREEN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}\n"
    echo "Then, restart your terminal for the change to take effect."
else
    echo "✅ Your PATH is configured correctly."
fi

echo -e "\n${GREEN}🎉 Mallow has been successfully installed!${NC}"
echo "You can now run the tool from anywhere using the 'mallow' command."
echo "Example: ${YELLOW}mallow list${NC}"