#!/usr/bin/python3
# Copyright (c) 2023-2024 iiPython

# Modules
import os
import subprocess
from sys import argv
from pathlib import Path

# Config options
PYINSTALLER_OPTS = "--onefile"
PYINSTALLER_ICON = ""  # Leave EMPTY for no icon, otherwise this should be the path to the icon file

# Check for arguments
def show_help() -> None:
    exit("usage: ./build.py <file path>")

argv = argv[1:]
if (argv + ["help"])[0] == "help":
    show_help()

# Check file existance
file = Path(argv[0])
if not file.is_file():
    exit("ERROR: specified file does not exist.")

# Generate the spec file
icon_options = ["-i", PYINSTALLER_ICON] if PYINSTALLER_ICON else []
subprocess.run([Path.home() / ".local/bin/pyi-makespec", PYINSTALLER_OPTS, *icon_options, file])

# Compile to an exe
subprocess.run(["docker", "run", "-v", f"{os.getcwd()}:/src/", "iipython-pyinstaller"])
print(f"\n[+] EXE has been written to dist/windows/{file.with_suffix('.exe').name}")
