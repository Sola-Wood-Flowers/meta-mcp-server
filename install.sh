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

# Check for Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed.${NC}"
    echo "Please install git and try again."
    exit 1
fi

# 0. Check context and Clone if needed (Standalone Mode)
if [ ! -f "requirements.txt" ] && [ ! -f "meta_ads_mcp.py" ]; then
    echo -e "${BLUE}[0/5] Bootstrapping...${NC}"
    echo -e "${YELLOW}Running in standalone mode. Cloning repository...${NC}"
    
    TARGET_DIR="meta-mcp-server"
    
    if [ -d "$TARGET_DIR" ]; then
        echo -e "${YELLOW}Directory '$TARGET_DIR' already exists.${NC}"
        # Prompt for overwrite, reading from TTY to support pipe
        echo -n "Directory exists. Overwrite? (y/n): "
        if [ -t 0 ]; then
            read -r OVERWRITE
        else
            read -r OVERWRITE < /dev/tty
        fi
        
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

# 1. Check Prerequisites
echo -e "\n${BLUE}[1/5] Checking prerequisites...${NC}"

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: python3 is not installed.${NC}"
    echo "Please install Python 3.10 or higher and try again."
    exit 1
fi

if ! command -v pip3 &> /dev/null; then
    echo -e "${RED}Error: pip3 is not installed.${NC}"
    echo "Please install pip3 and try again."
    exit 1
fi

echo -e "${GREEN}✓ Python and pip found.${NC}"

# 2. Create Virtual Environment
echo -e "\n${BLUE}[2/5] Setting up virtual environment...${NC}"

if [ -d "venv" ]; then
    echo -e "${YELLOW}Virtual environment 'venv' already exists. Skipping creation.${NC}"
else
    python3 -m venv venv
    echo -e "${GREEN}✓ Virtual environment created.${NC}"
fi

# Activate venv
source venv/bin/activate

# 3. Install Dependencies
echo -e "\n${BLUE}[3/5] Installing dependencies...${NC}"

if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    echo -e "${GREEN}✓ Dependencies installed.${NC}"
else
    echo -e "${RED}Error: requirements.txt not found!${NC}"
    exit 1
fi

# 4. Configure Meta Access Token
echo -e "\n${BLUE}[4/5] Configuring Meta Access Token...${NC}"

ENV_FILE=".env"

if [ -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}.env file already exists.${NC}"
    echo -n "Do you want to update the token? (y/n): "
    if [ -t 0 ]; then
        read -r UPDATE_TOKEN
    else
        read -r UPDATE_TOKEN < /dev/tty
    fi
else
    UPDATE_TOKEN="y"
fi

if [[ "$UPDATE_TOKEN" =~ ^[Yy]$ ]]; then
    echo -e "\nPlease enter your Meta Access Token."
    echo "You can get one from: https://developers.facebook.com/tools/explorer/"
    echo -n "Token: "
    if [ -t 0 ]; then
        read -r META_TOKEN
    else
        read -r META_TOKEN < /dev/tty
    fi

    if [ -z "$META_TOKEN" ]; then
        echo -e "${YELLOW}No token entered. Skipping .env creation.${NC}"
    else
        echo "META_ACCESS_TOKEN=$META_TOKEN" > "$ENV_FILE"
        echo -e "${GREEN}✓ Token saved to .env${NC}"
    fi
fi

# 5. Configure Claude Desktop
echo -e "\n${BLUE}[5/5] Configuring Claude Desktop...${NC}"

# Detect OS and set config path
OS="$(uname)"
if [[ "$OS" == "Darwin" ]]; then
    CONFIG_DIR="$HOME/Library/Application Support/Claude"
elif [[ "$OS" == "Linux" && -d "/mnt/c/Users" ]]; then
    # WSL support - trying to find Windows Claude config
    WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
    CONFIG_DIR="/mnt/c/Users/$WIN_USER/AppData/Roaming/Claude"
    echo -e "${YELLOW}WSL detected. Attempting to configure Windows Claude Desktop for user: $WIN_USER${NC}"
else
    # Linux native (rare for Claude Desktop currently, but falling back to standard XDG)
    CONFIG_DIR="$HOME/.config/Claude"
fi

CONFIG_FILE="$CONFIG_DIR/claude_desktop_config.json"

# Get absolute path to the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MCP_SCRIPT_PATH="$SCRIPT_DIR/meta_ads_mcp.py"
PYTHON_PATH="$SCRIPT_DIR/venv/bin/python"

# Check if config exists
if [ ! -d "$CONFIG_DIR" ]; then
    echo -e "${YELLOW}Claude Desktop configuration directory not found at: $CONFIG_DIR${NC}"
    echo "Creating directory..."
    mkdir -p "$CONFIG_DIR"
fi

echo "Configuring Claude Desktop at: $CONFIG_FILE"

# Prepare the JSON snippet for this server
# We use python to safely handle JSON manipulation
python3 -c "
import json
import os
import sys

config_path = '$CONFIG_FILE'
server_name = 'meta-ads'
python_path = '$PYTHON_PATH'
script_path = '$MCP_SCRIPT_PATH'
meta_token = os.getenv('META_ACCESS_TOKEN', '')

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
