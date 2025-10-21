# mallow/config.py

from pathlib import Path

# The base directory for all Mallow files (~/.mallow)
MALLOW_DIR = Path.home() / ".mallow"

# The directory where models will be downloaded
MODELS_DIR = MALLOW_DIR / "models"


MANIFEST_URL = "https://github.com/42Wor/mallow-cli/blob/a82d37eabf2122f77c792b427d3e2899a4f60a86/mallow/models.json?raw=true"
