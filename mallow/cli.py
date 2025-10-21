# mallow-cli/mallow/cli.py

import typer
from typing_extensions import Annotated
from mallow import commands

app = typer.Typer(
    name="mallow",
    help="""
☁️ Mallow: Your Friendly Local LLM Server ☁️

Soft-serve AI on your desktop. Easy to use, easy to customize.
""",
    rich_markup_mode="markdown"
)

@app.command()
def list():
    """
    📜 Show all available official models from the Mallow registry.
    """
    commands.list_models()

@app.command()
def get(
    model_name: Annotated[str, typer.Argument(
        help="The name of the model to download, e.g., 'llama3:8b'.",
        show_default=False
    )]
):
    """
    📥 Download a model from the registry to your local machine.

    Checks if the model already exists before downloading.
    """
    commands.get_model(model_name)

@app.command()
def serve(
    model_name: Annotated[str, typer.Argument(
        help="The name of the local model to serve.",
        show_default=False
    )]
):
    """
    🔥 (Coming Soon) Serve a local model on an API endpoint.
    """
    print(f"✨ Feature coming soon! You will be able to serve '{model_name}' soon. ✨")

# --- NEW COMMAND ---
@app.command()
def help(
    command_name: Annotated[str, typer.Argument(
        help="The command you need help with.",
        show_default=False
    )] = None
):
    """
    🍬 Get detailed, friendly help for Mallow commands.
    """
    commands.show_help_manual(command_name)