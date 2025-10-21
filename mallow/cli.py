import typer
from mallow import commands

app = typer.Typer(
    name="mallow",
    help="""
    Mallow: Your Friendly Local LLM Server ☁️

    Soft-serve AI on your desktop.
    """
)

@app.command()
def list():
    """
    Show all available official models.
    """
    commands.list_models()

@app.command()
def get(
    model_name: str = typer.Argument(..., help="The name of the model to download, e.g., 'llama3:8b'")
):
    """
    Download a model to your local machine.
    """
    commands.get_model(model_name)

@app.command()
def serve(
    model_name: str = typer.Argument(..., help="The name of the model to serve.")
):
    """
    (Coming Soon) Serve a model locally for API interaction.
    """
    print(f"✨ Feature coming soon! You will be able to serve '{model_name}' soon. ✨")