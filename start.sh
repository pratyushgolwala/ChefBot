#!/bin/bash

# ==============================================================================
# ChefBot Unified Start Script
# Usage:
#   ./start.sh          -> Start both Backend & Frontend concurrently
#   ./start.sh backend  -> Start only Backend (FastAPI on port 8000)
#   ./start.sh frontend -> Start only Frontend (Vite on port 5173/5174)
# ==============================================================================

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$PROJECT_ROOT/chefbot/backend"
FRONTEND_DIR="$PROJECT_ROOT/chefbot/frontend"

start_backend() {
    echo "================================"
    echo "  🍳 Starting ChefBot Backend"
    echo "================================"
    
    if ! command -v python3 &> /dev/null; then
        echo "❌ Python 3 is not installed"
        exit 1
    fi
    echo "✓ Python $(python3 --version)"

    cd "$BACKEND_DIR"

    # Setup Virtual Environment if missing
    if [ ! -d "venv" ] && [ ! -d "$PROJECT_ROOT/venv" ]; then
        echo "Creating Python virtual environment in $BACKEND_DIR/venv..."
        python3 -m venv venv
    fi

    if [ -d "venv" ]; then
        source venv/bin/activate
    elif [ -d "$PROJECT_ROOT/venv" ]; then
        source "$PROJECT_ROOT/venv/bin/activate"
    fi

    echo "✓ Virtual environment activated"
    echo "Installing/verifying dependencies..."
    pip install -q -r requirements.txt
    echo "✓ Dependencies ready"

    echo "Backend running at: http://localhost:8000"
    echo "Swagger Docs at:    http://localhost:8000/docs"
    echo "--------------------------------"
    exec uvicorn main:app --reload --host 0.0.0.0 --port 8000
}

start_frontend() {
    echo "================================"
    echo "  💻 Starting ChefBot Frontend"
    echo "================================"

    if ! command -v node &> /dev/null; then
        echo "❌ Node.js is not installed"
        exit 1
    fi
    echo "✓ Node $(node --version)"
    echo "✓ npm $(npm --version)"

    cd "$FRONTEND_DIR"

    if [ ! -d "node_modules" ]; then
        echo "Installing npm dependencies..."
        npm install
    fi
    echo "✓ Dependencies ready"

    echo "Frontend starting at: http://localhost:5173"
    echo "--------------------------------"
    exec npm run dev
}

# Subcommand handling
MODE="${1:-all}"

case "$MODE" in
    backend)
        start_backend
        ;;
    frontend)
        start_frontend
        ;;
    all)
        echo "=================================================="
        echo "  🚀 Starting ChefBot Fullstack (Backend + Frontend)"
        echo "=================================================="

        # Trap SIGINT/SIGTERM to cleanly kill both processes
        trap 'echo -e "\n🛑 Stopping ChefBot..."; kill 0; exit 0' SIGINT SIGTERM EXIT

        # Start backend in background
        (
            start_backend
        ) &
        BACKEND_PID=$!

        # Short pause before starting frontend
        sleep 2

        # Start frontend in background
        (
            start_frontend
        ) &
        FRONTEND_PID=$!

        # Wait for all background jobs
        wait
        ;;
    *)
        echo "Usage: $0 [all|backend|frontend]"
        exit 1
        ;;
esac
