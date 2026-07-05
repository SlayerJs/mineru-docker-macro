#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <input_pdf_path>"
    exit 1
fi

INPUT_PDF="$1"
WORKSPACE_DIR="$(pwd)"
BASENAME="$(basename "$INPUT_PDF")"

if command -v nvidia-smi &> /dev/null; then
    echo "NVIDIA GPU found. Building Docker image..."
    docker build -t mineru-nvidia -f docker/Dockerfile.nvidia .
    
    echo "Running MinerU Docker container..."
    docker run --rm --gpus all -v mineru_model_cache:/root -v "${WORKSPACE_DIR}":/workspace mineru-nvidia -b pipeline -p "/workspace/${BASENAME}" -o "/workspace/output_markdown"
    
    echo "Running Python cleanup script..."
    python3 clean_artifacts.py "${WORKSPACE_DIR}/output_markdown"
elif command -v rocm-smi &> /dev/null; then
    echo "AMD GPU found. Building Docker image..."
    docker build -t mineru-amd -f docker/Dockerfile.amd .
    
    echo "Running MinerU Docker container..."
    docker run --rm --device=/dev/kfd --device=/dev/dri --group-add=video -v mineru_model_cache:/root -v "${WORKSPACE_DIR}":/workspace mineru-amd -b pipeline -p "/workspace/${BASENAME}" -o "/workspace/output_markdown"
    
    echo "Running Python cleanup script..."
    python3 clean_artifacts.py "${WORKSPACE_DIR}/output_markdown"
elif [ "$(uname -s)" = "Darwin" ]; then
    echo "Apple hardware found. Building Docker image..."
    docker build -t mineru-apple -f docker/Dockerfile.apple .
    
    echo "Running MinerU Docker container..."
    docker run --rm -v mineru_model_cache:/root -v "${WORKSPACE_DIR}":/workspace mineru-apple -b pipeline -p "/workspace/${BASENAME}" -o "/workspace/output_markdown"
    
    echo "Running Python cleanup script..."
    python3 clean_artifacts.py "${WORKSPACE_DIR}/output_markdown"
else
    echo "No specific hardware GPU detected. Building CPU fallback Docker image..."
    docker build -t mineru-cpu -f docker/Dockerfile.cpu .
    
    echo "Running MinerU Docker container..."
    docker run --rm -v mineru_model_cache:/root -v "${WORKSPACE_DIR}":/workspace mineru-cpu -b pipeline -p "/workspace/${BASENAME}" -o "/workspace/output_markdown"
    
    echo "Running Python cleanup script..."
    python3 clean_artifacts.py "${WORKSPACE_DIR}/output_markdown"
fi
