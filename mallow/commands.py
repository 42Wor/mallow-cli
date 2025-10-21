from rich.console import Console
from rich.table import Table
from rich.live import Live
from rich.spinner import Spinner
from huggingface_hub import snapshot_download
import os

from mallow import api
from mallow import config

console = Console()

def list_models():
    """Fetches and displays the available models in a table."""
    with console.status("☁️  Fetching model manifest..."):
        manifest = api.fetch_models_manifest()

    if not manifest or "models" not in manifest:
        console.print("[bold red]Failed to retrieve model list.[/bold red]")
        return

    table = Table(title="🍬 Mallow Official Models")
    table.add_column("Name", style="cyan", no_wrap=True)
    table.add_column("Description", style="magenta")
    table.add_column("Size", justify="right", style="green")

    for model in manifest["models"]:
        table.add_row(model["name"], model["description"], model["size"])

    console.print(table)

def get_model(model_name: str):
    """Downloads a model from the Hugging Face Hub."""
    # Ensure the base directories exist
    config.MALLOW_DIR.mkdir(parents=True, exist_ok=True)
    config.MODELS_DIR.mkdir(parents=True, exist_ok=True)

    model_path = config.MODELS_DIR / model_name.replace(":", "-") # Use a filesystem-friendly name

    if model_path.exists():
        console.print(f"✅ Model '[bold cyan]{model_name}[/bold cyan]' already exists locally.")
        return

    console.print(f"🔍 Searching for '[bold cyan]{model_name}[/bold cyan]' in manifest...")
    manifest = api.fetch_models_manifest()

    if not manifest:
        return

    model_info = next((m for m in manifest["models"] if m["name"] == model_name), None)

    if not model_info:
        console.print(f"[bold red]Error:[/bold red] Model '{model_name}' not found in the official list.")
        console.print("Run 'mallow list' to see all available models.")
        return

    hf_path = model_info["huggingFacePath"]
    console.print(f"🔥 Found model. Preparing to download from Hugging Face: [bold blue]{hf_path}[/bold blue]")

    spinner = Spinner("dots", text=f" Downloading {model_name}...")
    with Live(spinner, console=console, transient=True, vertical_overflow="visible") as live:
        try:
            # The snapshot_download function will print its own progress
            snapshot_download(
                repo_id=hf_path,
                local_dir=model_path,
                local_dir_use_symlinks=False, # Recommended for Windows compatibility
            )
        except Exception as e:
            console.print(f"\n[bold red]Download failed![/bold red]")
            console.print(f"Error: {e}")
            # Clean up partial download
            if model_path.exists():
                import shutil
                shutil.rmtree(model_path)
            return

    console.print(f"\n✅ Successfully got [bold cyan]{model_name}[/bold cyan]!")
    console.print(f"   Saved to: {model_path}")