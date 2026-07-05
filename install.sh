#!/bin/bash

# Determine the absolute path of wherever the user cloned this repository
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Ensure the main script is executable
chmod +x "${SCRIPT_DIR}/run_parser.sh"

# Create a global command using a symlink
echo "Creating a global command link..."
if [ -w "/usr/local/bin" ]; then
    ln -sf "${SCRIPT_DIR}/run_parser.sh" /usr/local/bin/run_mineru_parser
else
    echo "Requesting sudo privileges to symlink into /usr/local/bin..."
    sudo ln -sf "${SCRIPT_DIR}/run_parser.sh" /usr/local/bin/run_mineru_parser
fi

echo ""
echo "=========================================================="
echo "✅ Installation Complete!"
echo "The command 'run_mineru_parser' is now available globally."
echo "You can run it manually in any terminal like this:"
echo "  run_mineru_parser path/to/document.pdf"
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
