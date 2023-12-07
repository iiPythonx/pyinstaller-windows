#!/bin/bash

# Fail on errors.
set -e

# Move to /src
cd /src

# Install requirements (if they exist)
if [ -f requirements.txt ]; then
    pip install -r -U requirements.txt
fi

# Build with pyinstaller
pyinstaller --clean -y --dist ./dist/windows --workpath /tmp --upx-dir "C:\\" *.spec
chown -R --reference=. ./dist
