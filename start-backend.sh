#!/bin/bash

# ChefBot Backend - Start Script
# Simple, no Docker, just Python + Uvicorn

set -e

echo "================================"
echo "  ChefBot Backend - Starting"
echo "================================"
echo

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed"
    exit 1
fi

echo "✓ Python $(python3 --version)"

# Install dependencies if needed
if [ ! -d "venv" ]; then
    echo
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

echo "✓ Virtual environment activated"

# Install/update requirements
echo
echo "Installing dependencies..."
pip install -q -r requirements.txt

echo "✓ Dependencies installed"

# Start the backend
echo
echo "================================"
echo "  Starting Uvicorn Server"
echo "================================"
echo
echo "Backend running at:"
echo "  http://localhost:8000"
echo
echo "API Documentation:"
echo "  http://localhost:8000/docs"
echo
echo "Press Ctrl+C to stop"
echo

cd chefbot/backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000
