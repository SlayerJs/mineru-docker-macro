#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <input_pdf_path>"
    exit 1
fi

INPUT_PDF="$1"
# The directory where the user currently is (where the PDF lives)
WORKSPACE_DIR="$(pwd)"
# The directory where this script lives (so it can find Dockerfiles and clean_artifacts.py)
SCRIPT_DIR="$(python3 -c 'import os, sys; print(os.path.dirname(os.path.realpath(sys.argv[1])))' "${BASH_SOURCE[0]}")"
BASENAME="$(basename "$INPUT_PDF")"

if command -v nvidia-smi &> /dev/null; then
    echo "NVIDIA GPU found. Building Docker image..."
    docker build -t mineru-nvidia -f "${SCRIPT_DIR}/docker/Dockerfile.nvidia" "${SCRIPT_DIR}"
    
    echo "Running MinerU Docker container..."
    docker run --rm --gpus all -v mineru_model_cache:/root -v "${WORKSPACE_DIR}":/workspace mineru-nvidia -b pipeline -p "/workspace/${BASENAME}" -o "/workspace/output_markdown"
    
    echo "Running Python cleanup script..."
    python3 "${SCRIPT_DIR}/clean_artifacts.py" "${WORKSPACE_DIR}/output_markdown"
elif command -v rocm-smi &> /dev/null; then
    echo "AMD GPU found. Building Docker image..."
    docker build -t mineru-amd -f "${SCRIPT_DIR}/docker/Dockerfile.amd" "${SCRIPT_DIR}"
    
    echo "Running MinerU Docker container..."
    docker run --rm --device=/dev/kfd --device=/dev/dri --group-add=video -v mineru_model_cache:/root -v "${WORKSPACE_DIR}":/workspace mineru-amd -b pipeline -p "/workspace/${BASENAME}" -o "/workspace/output_markdown"
    
    echo "Running Python cleanup script..."
    python3 "${SCRIPT_DIR}/clean_artifacts.py" "${WORKSPACE_DIR}/output_markdown"
elif [ "$(uname -s)" = "Darwin" ]; then
    echo "Apple hardware found. Building Docker image..."
    docker build -t mineru-apple -f "${SCRIPT_DIR}/docker/Dockerfile.apple" "${SCRIPT_DIR}"
    
    echo "Running MinerU Docker container..."
    docker run --rm -v mineru_model_cache:/root -v "${WORKSPACE_DIR}":/workspace mineru-apple -b pipeline -p "/workspace/${BASENAME}" -o "/workspace/output_markdown"
    
    echo "Running Python cleanup script..."
    python3 "${SCRIPT_DIR}/clean_artifacts.py" "${WORKSPACE_DIR}/output_markdown"
else
    echo "No specific hardware GPU detected. Building CPU fallback Docker image..."
    docker build -t mineru-cpu -f "${SCRIPT_DIR}/docker/Dockerfile.cpu" "${SCRIPT_DIR}"
    
    echo "Running MinerU Docker container..."
    docker run --rm -v mineru_model_cache:/root -v "${WORKSPACE_DIR}":/workspace mineru-cpu -b pipeline -p "/workspace/${BASENAME}" -o "/workspace/output_markdown"
    
    echo "Running Python cleanup script..."
    python3 "${SCRIPT_DIR}/clean_artifacts.py" "${WORKSPACE_DIR}/output_markdown"
fi
