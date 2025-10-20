# mallow/api.py
import requests
import json
from . import config

def fetch_manifest():
    """Fetches and parses the model manifest, bypassing caches."""
    try:
        # Add headers to prevent caching
        headers = {
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache'
        }
        
        console.print("☁️  Fetching latest manifest from GitHub...")
        response = requests.get(config.MANIFEST_URL, timeout=10, headers=headers)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        raise ConnectionError(f"Could not fetch model manifest: {e}")
    except json.JSONDecodeError:
        raise ValueError("Failed to parse the model manifest.")

# find_model_in_manifest function remains the same
def find_model_in_manifest(model_name: str, manifest: dict):
    """Searches for a model by name in the manifest."""
    for model in manifest.get("models", []):
        if model.get("name") == model_name:
            return model
    return None

# We also need to import the console to print the message
from rich.console import Console
console = Console()