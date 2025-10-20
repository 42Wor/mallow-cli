#!/bin/bash
set -e

# --- Configuration ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

MALLOW_ENV_DIR="$HOME/.mallow_env"
BIN_DIR="$HOME/.local/bin"
REPO_URL="https://github.com/42Wor/mallow-cli/archive/refs/heads/main.zip"
LOG_FILE="mallow-install.log"
# --- End Configuration ---

# --- ASCII Progress Bar Function ---
function draw_progress_bar {
    local pid=$1
    local duration=90
    local width=40
    local start_time=$(date +%s)

    while kill -0 $pid 2>/dev/null; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        local percent=$((elapsed * 100 / duration))
        if [ "$percent" -gt 100 ]; then percent=100; fi
        local filled_width=$((width * percent / 100))

        local bar="["
        bar+="$(printf '#%.0s' $(seq 1 $filled_width))"
        if [ $filled_width -lt $width ]; then bar+=">"; fi
        bar+="$(printf -- '-%.0s' $(seq 1 $((width - filled_width - 1)) ))"
        bar+="]"

        printf "\r${bar} ${percent}%%"
        sleep 0.2
    done
    printf "\r[$(printf '#%.0s' $(seq 1 $width))] 100%% \n"
}


# --- Main Script ---
echo -e "${YELLOW}Starting fully automated Mallow installation...${NC}"

# 1. Create virtual environment
python3 -m venv "$MALLOW_ENV_DIR" > /dev/null

# 2. Install the project
"$MALLOW_ENV_DIR/bin/pip" install --no-input "$REPO_URL" > "$LOG_FILE" 2>&1 &
PID=$!
echo "Installing packages..."
draw_progress_bar $PID
wait $PID
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo -e "❌ ${YELLOW}Installation failed.${NC}"
    echo "Please check the log file for details: ${YELLOW}${LOG_FILE}${NC}"
    exit $EXIT_CODE
else
    echo "✅ Packages installed successfully."
fi

# 3. Link the executable
mkdir -p "$BIN_DIR"
ln -sf "$MALLOW_ENV_DIR/bin/mallow" "$BIN_DIR/mallow"

# --- THIS IS THE NEW, FULLY AUTOMATED PART ---
# 4. Automatically configure the user's shell PATH
echo "Configuring your shell environment..."
CONFIG_FILE=""
SHELL_NAME=$(basename "$SHELL")

if [ "$SHELL_NAME" = "zsh" ]; then
    CONFIG_FILE="$HOME/.zshrc"
elif [ "$SHELL_NAME" = "bash" ]; then
    CONFIG_FILE="$HOME/.bashrc"
    # For non-interactive shells, .bash_profile might be used, so we check that too
    if [ ! -f "$HOME/.bashrc" ]; then
        CONFIG_FILE="$HOME/.bash_profile"
    fi
else
    # Fallback for other shells like fish, ksh, etc.
    echo -e "${YELLOW}Could not detect your shell configuration file.${NC}"
    echo "Please add the following directory to your PATH manually:"
    echo -e "  ${CYAN}${BIN_DIR}${NC}"
fi

if [ -n "$CONFIG_FILE" ]; then
    # The command to add to the config file
    PATH_EXPORT_CMD="export PATH=\"\$HOME/.local/bin:\$PATH\""
    
    # Check if the PATH is already configured. If not, add it.
    if ! grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$CONFIG_FILE"; then
        echo -e "\n# Add Mallow and other local binaries to PATH" >> "$CONFIG_FILE"
        echo "$PATH_EXPORT_CMD" >> "$CONFIG_FILE"
        echo "✅ Your ${CYAN}${CONFIG_FILE}${NC} has been updated."
    else
        echo "✅ Your PATH is already configured correctly."
    fi
fi
# --- END OF AUTOMATED PART ---

# 5. Final instructions
echo -e "\n${GREEN}🎉 Mallow has been successfully installed!${NC}"
echo -e "${YELLOW}IMPORTANT:${NC} You must ${CYAN}open a new terminal${NC} for the 'mallow' command to be available."
echo "Once in a new terminal, you can run commands from any directory:"
echo -e "  ${YELLOW}mallow list${NC}"