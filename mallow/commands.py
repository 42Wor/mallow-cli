# mallow/commands.py
"""
Contains the core logic for all CLI commands (list, get, run, serve).
"""
import sys
import torch
from . import api, config
from huggingface_hub import snapshot_download
from rich.console import Console
from rich.table import Table
from flask import Flask, jsonify, request
from transformers import AutoTokenizer, AutoModelForCausalLM, TextStreamer

console = Console()

def setup_directories():
    """Ensures the necessary local directories exist."""
    config.MALLOW_HOME.mkdir(exist_ok=True)
    config.MODELS_DIR.mkdir(exist_ok=True)

def handle_list():
    """Handles the 'mallow list' command."""
    try:
        manifest = api.fetch_manifest()
    except (ConnectionError, ValueError) as e:
        console.print(f"[bold red]Error:[/bold red] {e}")
        sys.exit(1)

    table = Table(title="🍡 Mallow Models", show_header=True, header_style="bold magenta")
    table.add_column("Name", style="cyan", no_wrap=True)
    table.add_column("Description", style="green")
    table.add_column("Size", justify="right", style="yellow")
    for model in manifest.get("models", []):
        table.add_row(model['name'], model['description'], model['size'])
    console.print(table)

def handle_get(model_name: str):
    """Downloads a model from Hugging Face if it doesn't exist locally."""
    sanitized_name = model_name.replace(":", "_")
    local_model_path = config.MODELS_DIR / sanitized_name
    if local_model_path.exists():
        console.print(f"✅ Model '[bold cyan]{model_name}[/bold cyan]' is already here!")
        return True

    try:
        manifest = api.fetch_manifest()
    except (ConnectionError, ValueError) as e:
        console.print(f"[bold red]Error:[/bold red] {e}")
        return False
        
    model_info = api.find_model_in_manifest(model_name, manifest)
    if not model_info:
        console.print(f"[bold red]Error:[/bold red] Model '[bold cyan]{model_name}[/bold cyan]' not found.")
        return False

    hf_path = model_info.get("huggingFacePath")
    console.print(f"🔥 Toasting '[bold cyan]{model_name}[/bold cyan]'...")
    
    # --- THIS IS THE NEW PART ---
    try:
        # Use a rich status spinner while preparing the download
        with console.status(f"[bold green]Connecting to Hugging Face Hub...", spinner="dots") as status:
            snapshot_download(
                repo_id=hf_path,
                local_dir=local_model_path,
                local_dir_use_symlinks=False,
                resume_download=True,
            )
    # --- END OF NEW PART ---
    except Exception as e:
        console.print(f"\n[bold red]Error downloading model:[/bold red] {e}")
        return False
        
    console.print(f"✅ Successfully got '[bold cyan]{model_name}[/bold cyan]'!")
    return True
def handle_run(model_name: str):
    """Handles the interactive 'mallow run' command."""
    # Step 1: Ensure model is downloaded
    if not handle_get(model_name):
        sys.exit(1) # Exit if download failed or model not found

    sanitized_name = model_name.replace(":", "_")
    local_model_path = config.MODELS_DIR / sanitized_name

    # Step 2: Load the model and tokenizer
    console.print(f"🔥 Warming up '[bold cyan]{model_name}[/bold cyan]'... (This may take a moment)")
    try:
        tokenizer = AutoTokenizer.from_pretrained(local_model_path)
        model = AutoModelForCausalLM.from_pretrained(
            local_model_path,
            device_map="auto",  # Use GPU if available, else CPU
            torch_dtype="auto", # Use appropriate precision
            trust_remote_code=True, # Required for some models like Phi-3
        )
        streamer = TextStreamer(tokenizer, skip_prompt=True, skip_special_tokens=True)
    except Exception as e:
        console.print(f"[bold red]Error loading model:[/bold red] {e}")
        sys.exit(1)

    console.print(f"✅ Model loaded! Type your prompt. (Send an empty prompt or type '/bye' to exit)")
    
    # Step 3: Interactive chat loop
    while True:
        try:
            prompt = console.input("[bold cyan]>>> [/bold cyan]")
            if not prompt.strip() or prompt.lower() in ["/bye", "exit", "quit"]:
                console.print("👋 Bye!")
                break
            
            inputs = tokenizer(prompt, return_tensors="pt").to(model.device)
            _ = model.generate(**inputs, streamer=streamer, max_new_tokens=1024)
        except KeyboardInterrupt:
            console.print("\n👋 Bye!")
            break
        except Exception as e:
            console.print(f"\n[bold red]An error occurred during generation:[/bold red] {e}")

def handle_serve(model_name: str):
    """Serves a model via a placeholder Flask API."""
    sanitized_name = model_name.replace(":", "_")
    local_model_path = config.MODELS_DIR / sanitized_name
    if not local_model_path.exists():
        console.print(f"[bold red]Error:[/bold red] Model '[bold cyan]{model_name}[/bold cyan]' not found.")
        sys.exit(1)

    console.print(f"🔥 Serving model '[bold cyan]{model_name}[/bold cyan]'...")
    console.print(f"✅ API server running on http://{config.SERVER_HOST}:{config.SERVER_PORT}")
    
    app = Flask(__name__)
    @app.route('/api/generate', methods=['POST'])
    def generate():
        prompt = request.json.get('prompt', '')
        response_text = f"This is a placeholder response for '{prompt}' using model {model_name}."
        return jsonify({"model": model_name, "response": response_text})
        
    import logging
    log = logging.getLogger('werkzeug')
    log.setLevel(logging.ERROR)
    app.run(host=config.SERVER_HOST, port=config.SERVER_PORT)