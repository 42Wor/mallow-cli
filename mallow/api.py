import requests
from rich.console import Console

from mallow import config

console = Console()

def fetch_models_manifest():
    """Fetches the official list of models from the remote manifest."""
    try:
        response = requests.get(config.MANIFEST_URL, timeout=10)
        response.raise_for_status()  # Raises an HTTPError for bad responses (4xx or 5xx)
        return response.json()
    except requests.exceptions.RequestException as e:
        console.print(f"[bold red]Error:[/bold red] Could not fetch model list. Check your connection.")
        console.print(f"Details: {e}")
        return None