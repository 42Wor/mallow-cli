# mallow/api.py
"""
Handles all external API communications, primarily fetching the model manifest.
"""
import requests
import json
from . import config

def fetch_manifest():
    """Fetches and parses the model manifest from the remote URL."""
    try:
        response = requests.get(config.MANIFEST_URL, timeout=10)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        raise ConnectionError(f"Could not fetch model manifest: {e}")
    except json.JSONDecodeError:
        raise ValueError("Failed to parse the model manifest.")

def find_model_in_manifest(model_name: str, manifest: dict):
    """Searches for a model by name in the manifest."""
    for model in manifest.get("models", []):
        if model.get("name") == model_name:
            return model
    return None