#!/bin/bash

# Meta Ads MCP Server - Easy Installer
# This script automates the setup of the Meta Ads MCP server for Claude Desktop.

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Meta Ads MCP Server Installer ===${NC}"

# Helper function to read input safely
ask_user() {
    local prompt="$1"
    # read -p outputs prompt to stderr, so it won't be captured by $()
    if [ -t 0 ]; then
        read -r -p "$prompt" REPLY
    else
        read -r -p "$prompt" REPLY < /dev/tty
    fi
    echo "$REPLY"
}

# 0. Check context and Clone if needed (Standalone Mode)
if [ ! -f "requirements.txt" ] && [ ! -f "meta_ads_mcp.py" ]; then
    echo -e "${BLUE}[0/6] Bootstrapping...${NC}"
    
    # Check for git first
    if ! command -v git &> /dev/null; then
        echo -e "${RED}Error: git is not installed.${NC}"
        echo "Please install git and try again."
        exit 1
    fi

    echo -e "${YELLOW}Running in standalone mode. Cloning repository...${NC}"
    
    TARGET_DIR="meta-mcp-server"
    
    if [ -d "$TARGET_DIR" ]; then
        echo -e "${YELLOW}Directory '$TARGET_DIR' already exists.${NC}"
        OVERWRITE=$(ask_user "Overwrite? (y/n): ")
        
        if [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
            rm -rf "$TARGET_DIR"
            echo -e "${YELLOW}Removed existing directory.${NC}"
        else
            echo -e "${GREEN}Using existing directory.${NC}"
        fi
    fi
    
    if [ ! -d "$TARGET_DIR" ]; then
        git clone https://github.com/Sola-Wood-Flowers/meta-mcp-server.git "$TARGET_DIR"
    fi
    
    cd "$TARGET_DIR"
    echo -e "${GREEN}✓ Repository ready in ./$TARGET_DIR${NC}"
fi

# 1. Install Python if missing (macOS/Linux)
echo -e "\n${BLUE}[1/6] Checking system requirements...${NC}"

install_python() {
    OS="$(uname -s)"
    if [[ "$OS" == "Darwin" ]]; then
        if command -v brew &> /dev/null; then
            echo -e "${YELLOW}Installing Python via Homebrew...${NC}"
            # Redirect stdin to prevent brew from eating the pipe
            brew install python < /dev/null
            
            # Add Homebrew python to PATH for this session if needed
            if [ -f "/opt/homebrew/bin/python3" ]; then
                export PATH="/opt/homebrew/bin:$PATH"
            elif [ -f "/usr/local/bin/python3" ]; then
                export PATH="/usr/local/bin:$PATH"
            fi
        else
            echo -e "${RED}Error: Python 3 not found and Homebrew is missing.${NC}"
            echo "Please install Homebrew (https://brew.sh) or Python 3 manually."
            exit 1
        fi
    elif [[ "$OS" == "Linux" ]]; then
        if command -v apt-get &> /dev/null; then
            echo -e "${YELLOW}Installing Python via apt...${NC}"
            # Redirect stdin to prevent apt from eating the pipe
            sudo apt-get update < /dev/null && sudo apt-get install -y python3 python3-pip python3-venv < /dev/null
        else
            echo -e "${RED}Error: Python 3 not found and could not detect apt.${NC}"
            echo "Please install Python 3 manually."
            exit 1
        fi
    else
        echo -e "${RED}Error: Python 3 not found.${NC}"
        echo "Please install Python 3 manually."
        exit 1
    fi
}

if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}Python 3 not found. Attempting to install...${NC}"
    install_python
else
    # Check version
    PY_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    PY_MAJOR=$(echo "$PY_VERSION" | cut -d. -f1)
    PY_MINOR=$(echo "$PY_VERSION" | cut -d. -f2)
    
    if [ "$PY_MAJOR" -lt 3 ] || ([ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -lt 10 ]); then
        echo -e "${YELLOW}Python version $PY_VERSION is too old (need 3.10+). Attempting upgrade...${NC}"
        install_python
    else
        echo -e "${GREEN}✓ Python $PY_VERSION found.${NC}"
    fi
fi

# Ensure pip is available
if ! command -v pip3 &> /dev/null; then
    echo -e "${YELLOW}pip3 not found. Installing...${NC}"
    install_python
fi

# 2. Create Virtual Environment
echo -e "\n${BLUE}[2/6] Setting up virtual environment...${NC}"

if [ -d "venv" ]; then
    echo -e "${YELLOW}Virtual environment 'venv' already exists. Recreating to ensure clean state...${NC}"
    rm -rf venv
fi

python3 -m venv venv
echo -e "${GREEN}✓ Virtual environment created.${NC}"

# Activate venv
source venv/bin/activate

# 3. Upgrade pip and Install Dependencies
echo -e "\n${BLUE}[3/6] Installing dependencies...${NC}"

echo "Upgrading pip..."
pip install --upgrade pip

if [ -f "requirements.txt" ]; then
    echo "Installing requirements..."
    pip install -r requirements.txt
    echo -e "${GREEN}✓ Dependencies installed.${NC}"
else
    echo -e "${RED}Error: requirements.txt not found!${NC}"
    exit 1
fi

# 4. Configure Meta Access Token
echo -e "\n${BLUE}[4/6] Configuring Meta Access Token...${NC}"

ENV_FILE=".env"
UPDATE_TOKEN="y"

if [ -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}.env file already exists.${NC}"
    UPDATE_TOKEN=$(ask_user "Do you want to update the token? (y/n): ")
fi

if [[ "$UPDATE_TOKEN" =~ ^[Yy]$ ]]; then
    echo -e "\nPlease enter your Meta Access Token."
    echo "You can get one from: https://developers.facebook.com/tools/explorer/"
    META_TOKEN=$(ask_user "Token: ")

    if [ -z "$META_TOKEN" ]; then
        if [ ! -f "$ENV_FILE" ]; then
             echo -e "${YELLOW}No token entered. Creating empty .env${NC}"
             touch "$ENV_FILE"
        fi
    else
        echo "META_ACCESS_TOKEN=$META_TOKEN" > "$ENV_FILE"
        echo -e "${GREEN}✓ Token saved to .env${NC}"
    fi
fi

# 5. Configure Claude Desktop
echo -e "\n${BLUE}[5/6] Configuring Claude Desktop...${NC}"

# Detect OS and set config path
OS="$(uname -s)"
if [[ "$OS" == "Darwin" ]]; then
    CONFIG_DIR="$HOME/Library/Application Support/Claude"
elif [[ "$OS" == "Linux" && -d "/mnt/c/Users" ]]; then
    # WSL support
    WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
    CONFIG_DIR="/mnt/c/Users/$WIN_USER/AppData/Roaming/Claude"
    echo -e "${YELLOW}WSL detected. Configuring for Windows user: $WIN_USER${NC}"
else
    CONFIG_DIR="$HOME/.config/Claude"
fi

CONFIG_FILE="$CONFIG_DIR/claude_desktop_config.json"

# Get absolute path to the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MCP_SCRIPT_PATH="$SCRIPT_DIR/meta_ads_mcp.py"
PYTHON_PATH="$SCRIPT_DIR/venv/bin/python" # Use venv python

# Check if config exists
if [ ! -d "$CONFIG_DIR" ]; then
    echo -e "${YELLOW}Config directory not found. Creating: $CONFIG_DIR${NC}"
    mkdir -p "$CONFIG_DIR"
fi

echo "Configuring: $CONFIG_FILE"

# Load environment variables from .env if it exists
if [ -f "$ENV_FILE" ]; then
    echo "Loading configuration from $ENV_FILE..."
    # Export variables from .env so python script can see them
    set -a
    source "$ENV_FILE"
    set +a
fi

# Prepare the JSON snippet for this server
python3 -c "
import json
import os
import sys

config_path = '$CONFIG_FILE'
server_name = 'meta-ads'
python_path = '$PYTHON_PATH'
script_path = '$MCP_SCRIPT_PATH'
meta_token = os.getenv('META_ACCESS_TOKEN', '')

if not meta_token:
    print('Warning: META_ACCESS_TOKEN not found in environment.')

# Load existing config or create new
config = {}
if os.path.exists(config_path):
    try:
        with open(config_path, 'r') as f:
            content = f.read().strip()
            if content:
                config = json.loads(content)
    except Exception as e:
        print(f'Warning: Could not read existing config: {e}')

if 'mcpServers' not in config:
    config['mcpServers'] = {}

# Update/Add our server config
config['mcpServers'][server_name] = {
    'command': python_path,
    'args': [script_path],
    'env': {
        'META_ACCESS_TOKEN': meta_token
    }
}

# Write back
try:
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)
    print(f'Successfully updated {config_path}')
except Exception as e:
    print(f'Error writing config: {e}')
    sys.exit(1)
"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Claude Desktop configuration updated.${NC}"
else
    echo -e "${RED}Failed to update Claude Desktop configuration.${NC}"
fi

echo -e "\n${BLUE}=== Installation Complete! ===${NC}"
echo -e "Please restart Claude Desktop to apply changes."
echo -e "To verify, ask Claude: 'List my Meta ad accounts'"
