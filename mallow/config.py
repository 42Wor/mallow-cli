from pathlib import Path

# The base directory for all Mallow files (~/.mallow)
MALLOW_DIR = Path.home() / ".mallow"

# The directory where models will be downloaded
MODELS_DIR = MALLOW_DIR / "models"

# The remote URL for the model manifest file
# --- CHANGE THIS LINE ---
MANIFEST_URL = "https://raw.githubusercontent.com/42Wor/mallow-cli/main/mallow/models.json"