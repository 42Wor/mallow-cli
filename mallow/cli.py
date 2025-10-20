# mallow/cli.py
"""
Defines the command-line interface, argument parsing, and command dispatching.
"""
import argparse
from . import commands

def create_parser():
    """Creates the main argument parser for the Mallow CLI."""
    parser = argparse.ArgumentParser(
        description="Mallow: Your Friendly Local LLM Server.",
        epilog="Soft-serve AI on your desktop. 🍮"
    )
    subparsers = parser.add_subparsers(dest="command", required=True, help="Available commands")

    # Parser for the 'run' command
    run_parser = subparsers.add_parser("run", help="Run a model and chat with it interactively.")
    run_parser.add_argument("model_name", help="The name of the model to run (e.g., 'phi-3:mini').")

    # Parser for the 'list' command
    subparsers.add_parser("list", help="List all available models to download.")

    # Parser for the 'get' command
    get_parser = subparsers.add_parser("get", help="Download a model to your local machine.")
    get_parser.add_argument("model_name", help="The name of the model to download.")
    
    # Parser for the 'serve' command
    serve_parser = subparsers.add_parser("serve", help="Serve a local model via a placeholder API.")
    serve_parser.add_argument("model_name", help="The name of the downloaded model to serve.")

    return parser

def main():
    """Main function to parse args and dispatch to the correct command handler."""
    commands.setup_directories()
    parser = create_parser()
    args = parser.parse_args()

    if args.command == "run":
        commands.handle_run(args.model_name)
    elif args.command == "list":
        commands.handle_list()
    elif args.command == "get":
        commands.handle_get(args.model_name)
    elif args.command == "serve":
        commands.handle_serve(args.model_name)