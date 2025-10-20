# mallow/config.py
"""
Central configuration file for Mallow.
Stores paths, URLs, and server settings.
"""
from pathlib import Path

# The remote manifest URL where the list of models is stored.
MANIFEST_URL = "https://gist.githubusercontent.com/gadicc/d7f1413158c55893361138ac2a54b391/raw/models.json"

# The local directory where Mallow will store models and config.
MALLOW_HOME = Path.home() / ".mallow"
MODELS_DIR = MALLOW_HOME / "models"

# API server configuration (for the 'serve' command)
SERVER_HOST = "127.0.0.1"
SERVER_PORT = 11344