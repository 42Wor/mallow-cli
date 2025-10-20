# Mallow

**Tagline:** *Soft-serve AI on your desktop.*

Mallow is a friendly, simple command-line tool for downloading and running large language models (LLMs) on your own machine. Inspired by the simplicity of Ollama, Mallow makes local AI easy and approachable.

## Features

-   **Simple Commands:** An intuitive interface for managing models.
-   **Interactive Chat:** Run models and chat with them directly in your terminal.
-   **Auto-Download:** Automatically fetches models from Hugging Face the first time you run them.
-   **GPU Acceleration:** Automatically uses your GPU if detected (via PyTorch and `accelerate`).

## Quick Start

### 1. Prerequisites

-   Python 3.8+
-   Git

### 2. Installation

First, clone the repository and navigate into the project directory:
```bash
git clone <your-repo-url>
cd mallow-cli
```

Next, create a virtual environment and install the required packages:
```bash
# Create and activate a virtual environment
python3 -m venv venv
source venv/bin/activate
# On Windows, use: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 3. Usage

Mallow is easy to use. The main entry point is the `mallow.py` script.

#### List Available Models

See all the models Mallow knows how to download.
```bash
python3 mallow.py list
```

#### Run a Model

This is the main command. It will download the model if you don't have it, then start an interactive chat session.
```bash
python3 mallow.py run phi-3:mini
```
Once the model is loaded, you'll see a prompt. Start chatting!
```
✅ Model loaded! Type your prompt. (Send an empty prompt or type '/bye' to exit)
>>> Tell me a joke about marshmallows
```

To exit the chat, type `/bye` or press `Ctrl+C`.

#### Download a Model (Optional)

If you only want to download a model without running it immediately, use the `get` command.
```bash
python3 mallow.py get codegemma:2b
```

## How It Works

-   **Manifest File:** Mallow uses a remote JSON file to know which models are available and where to find them on Hugging Face.
-   **Local Storage:** All downloaded models are stored in a `.mallow/models/` directory in your user's home folder.
-   **Inference Engine:** It uses the Hugging Face `transformers` library with PyTorch to load and run the models efficiently on your hardware.
