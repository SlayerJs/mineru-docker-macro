# Universal MinerU PDF Parser

This repository provides a universal, hardware-agnostic Docker pipeline to convert scientific PDF files into Markdown using the [MinerU](https://github.com/opendatalab/MinerU) deep learning library. It automatically handles hardware detection (NVIDIA, AMD, Apple Silicon, or CPU) to run the optimal configuration.

## Installation & Setup

Because this pipeline runs entirely inside Docker, there are no heavy Python dependencies or ML libraries to install locally on your machine.

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/mineru-docker-macro.git
   cd mineru-docker-macro
   ```

2. **Ensure Docker is installed**:
   Make sure Docker is installed and currently running on your system. You can download it from [Docker's official website](https://www.docker.com/).

3. **Make the execution script executable** (Linux/macOS):
   ```bash
   chmod +x run_parser.sh
   ```

4. **VS Code Setup** (Optional but Recommended):
   If you want to use the 1-click status bar execution feature, open this repository folder in VS Code and install the **Action Buttons** extension (e.g., `seunlanlege.action-buttons`). The project configuration for this button is already provided in `.vscode/settings.json`.

## Hardware Support

The pipeline auto-detects your hardware and builds the appropriate Docker image on the fly:
- **NVIDIA GPUs**: Leverages `nvidia/cuda` base image and runs with `--gpus all`. Requires `nvidia-smi` to be available.
- **AMD GPUs**: Uses a ROCm PyTorch base image and maps `/dev/kfd` and `/dev/dri` device files. Requires `rocm-smi` to be available.
- **Apple Silicon (Mac)**: Leverages an ARM64-compatible environment natively on macOS.
- **CPU Only**: If no specialized hardware is detected, it gracefully falls back to a standard CPU-based execution.

## Usage Instructions

There are two ways to use this repository to process your PDFs:

### 1. Using VS Code (Recommended)

This repository includes a pre-configured VS Code task that allows you to trigger the pipeline with a single click.

1. Open the `.pdf` file you want to convert in VS Code so that it is your currently active editor tab.
2. Click the `▶ Run Universal MinerU Parse` button located in the blue VS Code status bar at the bottom of the screen.
3. A terminal will pop up showing the progress of Docker building and running.
4. Once completed, the converted Markdown file and extracted images will be saved in the `output_markdown/` directory at the root of the project.

### 2. Using the Command Line

If you prefer to run the script manually from your terminal, you can directly invoke the `run_parser.sh` script:

```bash
# Run the script with the path to your PDF
./run_parser.sh path/to/your/document.pdf
```

Just like the VS Code command, the parsed output will be generated inside the `output_markdown/` directory.

## Pipeline Workflow

When you execute the script, it automatically performs the following steps:
1. Detects your hardware environment (`nvidia-smi`, `rocm-smi`, or `uname`).
2. Builds the respective Docker image from the files in the `docker/` directory.
3. Runs the MinerU processing container, mounting your current workspace.
4. Triggers `clean_artifacts.py` to post-process the Markdown file (removing inline equation images and standardizing relative image path tags).

## AI Model Caching & Storage

MinerU utilizes large computer vision and optical character recognition (OCR) models to parse documents. To ensure these massive models are not re-downloaded every single time you parse a PDF, this repository automatically uses a **Docker Named Volume** (`mineru_model_cache`).

This securely stores the downloaded models deep inside Docker's internal managed storage (e.g., `/var/lib/docker/volumes/` on Linux). 
- **Performance**: The models are only downloaded once during your very first run. All subsequent runs instantly reuse the cached models.
- **Safety**: Because they are safely managed by Docker, standard OS disk cleaners (like CleanMyMac, Windows Disk Cleanup, or BleachBit) will **not** accidentally delete them. 
- **Removal**: If you ever want to clear space and delete these AI models manually, you must explicitly run `docker volume rm mineru_model_cache` or `docker system prune --volumes`.
