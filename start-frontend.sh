#!/bin/bash

# ChefBot Frontend - Start Script
# Simple, no Docker, just Node + Vite

set -e

echo "================================"
echo "  ChefBot Frontend - Starting"
echo "================================"
echo

# Check if Node is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed"
    exit 1
fi

echo "✓ Node $(node --version)"
echo "✓ npm $(npm --version)"

cd chefbot/frontend

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo
    echo "Installing dependencies..."
    npm install
fi

echo "✓ Dependencies installed"

# Start the frontend
echo
echo "================================"
echo "  Starting Vite Dev Server"
echo "================================"
echo
echo "Frontend running at:"
echo "  http://localhost:5174"
echo
echo "Make sure backend is running at:"
echo "  http://localhost:8000"
echo
echo "Press Ctrl+C to stop"
echo

npm run dev
