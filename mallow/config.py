# mallow/config.py
"""
Central configuration file for Mallow.
Stores paths, URLs, and server settings.
"""
from pathlib import Path

# The remote manifest URL where the list of models is stored.
MANIFEST_URL = "https://github.com/42Wor/mallow-cli/blob/a82d37eabf2122f77c792b427d3e2899a4f60a86/mallow/models.json?raw=true"

# The local directory where Mallow will store models and config.
MALLOW_HOME = Path.home() / ".mallow"
MODELS_DIR = MALLOW_HOME / "models"

# API server configuration (for the 'serve' command)
SERVER_HOST = "127.0.0.1"
SERVER_PORT = 11344