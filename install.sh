#!/bin/bash
set -e

# --- Configuration ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

MALLOW_ENV_DIR="$HOME/.mallow_env"
BIN_DIR="$HOME/.local/bin"
# The GitHub repository URL now points to the ZIP archive of the main branch
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
echo -e "${YELLOW}Installing Mallow via HTTPS...${NC}"

# Create virtual environment silently
python3 -m venv "$MALLOW_ENV_DIR" > /dev/null

# Install the project in the background from the ZIP URL
"$MALLOW_ENV_DIR/bin/pip" install --no-input "$REPO_URL" > "$LOG_FILE" 2>&1 &
PID=$!

echo "Installing packages..."
draw_progress_bar $PID

# Wait for pip to finish and check its exit code
wait $PID
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo -e "❌ ${YELLOW}Installation failed.${NC}"
    echo "Please check the log file for details: ${YELLOW}${LOG_FILE}${NC}"
    exit $EXIT_CODE
else
    echo "✅ Packages installed successfully."
fi

# Link the command to the user's path
echo "Adding 'mallow' command to your system path..."
mkdir -p "$BIN_DIR"
ln -sf "$MALLOW_ENV_DIR/bin/mallow" "$BIN_DIR/mallow"

# Check if PATH is configured
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo -e "\n${YELLOW}ACTION REQUIRED:${NC}"
    echo "To make the 'mallow' command work, add this line to your ~/.bashrc or ~/.zshrc:"
    echo -e "\n  ${GREEN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}\n"
    echo "Then, restart your terminal."
fi

echo -e "\n${GREEN}🎉 Mallow has been successfully installed!${NC}"
echo "You can now run the tool from anywhere using the 'mallow' command."