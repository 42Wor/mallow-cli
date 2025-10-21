from rich.console import Console
from rich.table import Table
from rich.live import Live
from rich.spinner import Spinner
from rich.panel import Panel
from huggingface_hub import snapshot_download
import os
import shutil

from mallow import api
from mallow import config

console = Console()

# --- (list_models and get_model functions are unchanged) ---
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
    config.MALLOW_DIR.mkdir(parents=True, exist_ok=True)
    config.MODELS_DIR.mkdir(parents=True, exist_ok=True)

    model_path = config.MODELS_DIR / model_name.replace(":", "-")

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
            snapshot_download(
                repo_id=hf_path,
                local_dir=model_path,
                local_dir_use_symlinks=False,
            )
        except Exception as e:
            console.print(f"\n[bold red]Download failed![/bold red]")
            console.print(f"Error: {e}")
            if model_path.exists():
                shutil.rmtree(model_path)
            return

    console.print(f"\n✅ Successfully got [bold cyan]{model_name}[/bold cyan]!")
    console.print(f"   Saved to: {model_path}")


def show_help_manual(command: str = None):
    """Displays a detailed, user-friendly help manual for commands."""
    
    if not command:
        # ... (General help text is unchanged)
        general_text = """
[bold]Welcome to Mallow, your friendly local LLM server![/bold] 🍬

Mallow makes it easy to download and run language models on your own machine.

[bold]Core Commands:[/bold]
  [cyan]list[/cyan]    - See all the official models you can download.
  [cyan]get[/cyan]     - Download a model to your computer.
  [cyan]serve[/cyan]   - (Coming Soon) Serve a downloaded model on a local API.

For detailed help on a specific command, run:
[yellow]mallow help <command_name>[/yellow] (e.g., `mallow help get`)
"""
        panel = Panel(general_text, title=" marshmallow Manual ", border_style="blue", expand=False)
    
    elif command == "list":
        # ... (List help text is unchanged)
        list_text = """
[bold]Command: `list`[/bold] 📜

Shows a table of all the official models available in the Mallow registry.

[bold]Usage:[/bold]
  [yellow]mallow list[/yellow]

This command checks the central Mallow model list online and displays the model names, descriptions, and sizes. Use the 'Name' from this list in the `mallow get` command.
"""
        panel = Panel(list_text, title=" Help for: list ", border_style="blue", expand=False)
        
    elif command == "get":
        # ... (Get help text is unchanged)
        get_text = """
[bold]Command: `get`[/bold] 📥

Downloads a model from the Mallow registry and saves it to your local machine.

[bold]Usage:[/bold]
  [yellow]mallow get [MODEL_NAME][/yellow]

[bold]Arguments:[/bold]
  [cyan]MODEL_NAME[/cyan]  The name of the model you want to download. This must be one of the names from the `mallow list` command.

[bold]Examples:[/bold]
  [green]# Download the small 'tinystories' model[/green]
  [yellow]mallow get tinystories:33m[/yellow]

  [green]# Download Meta's Llama 3 model[/green]
  [yellow]mallow get llama3:8b[/yellow]
"""
        panel = Panel(get_text, title=" Help for: get ", border_style="blue", expand=False)

    # --- ADD THIS NEW BLOCK ---
    elif command == "serve":
        serve_text = """
[bold]Command: `serve`[/bold] 🔥 [yellow](Coming Soon)[/yellow]

Serves a downloaded model on a local API endpoint, making it available for applications to use.

[bold]Usage:[/bold]
  [yellow]mallow serve [MODEL_NAME][/yellow]

[bold]Arguments:[/bold]
  [cyan]MODEL_NAME[/cyan]  The name of a model you have already downloaded with `mallow get`.

[bold]What it will do:[/bold]
This command will load the model into memory and start a web server (like Ollama). You can then send API requests to `http://localhost:11344` to get completions from the model.

[bold]Example:[/bold]
  [green]# First, make sure you have the model[/green]
  [yellow]mallow get llama3:8b[/yellow]

  [green]# Then, serve it[/green]
  [yellow]mallow serve llama3:8b[/yellow]
"""
        panel = Panel(serve_text, title=" Help for: serve ", border_style="blue", expand=False)
    # --- END OF NEW BLOCK ---

    else:
        console.print(f"[bold red]Error:[/bold red] Unknown command '{command}'.")
        console.print("Run `mallow help` to see all available commands.")
        return

    console.print(panel)