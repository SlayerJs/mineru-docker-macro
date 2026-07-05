# Universal MinerU PDF Parser

This repository provides a universal, hardware-agnostic Docker pipeline to convert scientific PDF files into Markdown using the [MinerU](https://github.com/opendatalab/MinerU) deep learning library. It automatically handles hardware detection (NVIDIA, AMD, Apple Silicon, or CPU) to run the optimal configuration.

## System Requirements & OS Compatibility

Because this runs entirely inside Docker, there are no heavy Python dependencies or ML libraries to install locally! The script is designed to run seamlessly across all major operating systems:
- **Linux & macOS**: Works perfectly out-of-the-box using the native terminal.
- **Windows**: We strongly recommend installing **WSL2** (Windows Subsystem for Linux) and running the commands from a WSL terminal. Docker Desktop for Windows natively uses WSL2 as its backend, making this the smoothest and most compatible environment.

## Installation & Setup

1. **Ensure Docker is installed**:
   Make sure Docker is running. You can download it from [Docker's official website](https://www.docker.com/).

2. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/mineru-docker-macro.git
   cd mineru-docker-macro
   ```

3. **Run the Universal Installer**:
   To make the `run_mineru_parser` command available globally on your entire system (so you can run it from any folder), execute the installation script:
   ```bash
   ./install.sh
   ```
   *(Note: This will safely create a symlink in `/usr/local/bin` and might prompt for `sudo` password).*

4. **Global VS Code Setup** (Optional but Highly Recommended):
   If you want to use the 1-click status bar execution feature on *any* repository you open:
   - Install the **Action Buttons** extension (`seunlanlege.action-buttons`) in VS Code.
   - The `./install.sh` script will print out the exact JSON block you need to copy-paste into your VS Code **Global User Settings** and **Global Tasks**.

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

If you prefer to run the script manually from your terminal, you can directly invoke your newly installed global command from anywhere:

```bash
run_mineru_parser path/to/your/document.pdf
```

Just like the VS Code command, the parsed output will be generated inside an `output_markdown/` directory in whichever folder you ran the command.

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
