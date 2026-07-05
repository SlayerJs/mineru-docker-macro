#!/bin/bash

# Determine the absolute path of wherever the user cloned this repository
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

INSTALL_DIR="/opt/mineru-parser"

echo "Installing MinerU Universal Parser to ${INSTALL_DIR}..."
echo "We need administrator permissions to copy files to a permanent system directory."

# Create the installation directory
sudo mkdir -p "${INSTALL_DIR}"

# Copy the required files to make it independent of this repository
sudo cp "${SCRIPT_DIR}/run_parser.sh" "${INSTALL_DIR}/"
sudo cp "${SCRIPT_DIR}/clean_artifacts.py" "${INSTALL_DIR}/"
sudo cp -r "${SCRIPT_DIR}/docker" "${INSTALL_DIR}/"

# Ensure the main script is executable
sudo chmod +x "${INSTALL_DIR}/run_parser.sh"

# Create a global command using a symlink
echo "Creating a global command link in /usr/local/bin..."
sudo ln -sf "${INSTALL_DIR}/run_parser.sh" /usr/local/bin/run_mineru_parser

echo ""
echo "=========================================================="
echo "✅ Installation Complete!"
echo "The pipeline has been permanently installed to ${INSTALL_DIR}."
echo "The command 'run_mineru_parser' is now available globally."
echo "You can now safely DELETE this original downloaded repository!"
echo "=========================================================="
echo ""
echo "To set up the global VS Code button, paste the following into"
echo "your Global User Tasks (Ctrl+Shift+P -> 'Tasks: Open User Tasks'):"
echo ""
echo '{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Convert PDF with MinerU (Universal)",
            "type": "shell",
            "command": "run_mineru_parser '"'""\${file}""'"'",
            "presentation": {
                "echo": false,
                "reveal": "always",
                "focus": true,
                "panel": "dedicated"
            }
        }
    ]
}'
