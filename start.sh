#!/bin/bash

# ChefBot Local Development Starter Script

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  ChefBot - Local Development Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file not found!${NC}"
    echo -e "${YELLOW}Creating from template...${NC}"
    cp .env.example .env
    echo -e "${YELLOW}📝 Please edit .env and add your OPENROUTER_API_KEY${NC}"
    exit 1
fi

# Check for API key
if ! grep -q "OPENROUTER_API_KEY=sk_" .env; then
    echo -e "${YELLOW}⚠️  OPENROUTER_API_KEY not configured in .env${NC}"
    echo -e "${YELLOW}Get your key from: https://openrouter.ai${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Environment configured${NC}"

# Setup Python backend
echo -e "\n${BLUE}Setting up backend...${NC}"
if [ ! -d .venv ]; then
    python -m venv .venv
    echo -e "${GREEN}✓ Virtual environment created${NC}"
fi

source .venv/bin/activate
pip install -q -r requirements.txt
echo -e "${GREEN}✓ Backend dependencies installed${NC}"

# Setup Node frontend
echo -e "\n${BLUE}Setting up frontend...${NC}"
cd chefbot/frontend
if [ ! -d node_modules ]; then
    npm install -q
    echo -e "${GREEN}✓ Frontend dependencies installed${NC}"
else
    echo -e "${GREEN}✓ Frontend dependencies already installed${NC}"
fi
cd ../..

echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Setup complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "\n${YELLOW}Starting ChefBot...${NC}\n"

# Start backend in background
echo -e "${BLUE}Backend starting on http://localhost:8000${NC}"
cd chefbot/backend
uvicorn main:app --reload --port 8000 &
BACKEND_PID=$!
cd ../..

# Wait for backend to start
sleep 2

# Start frontend
echo -e "${BLUE}Frontend starting on http://localhost:5174${NC}"
cd chefbot/frontend
npm run dev &
FRONTEND_PID=$!
cd ../..

echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ChefBot is running! 🍳${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\n  🌐 Frontend: ${BLUE}http://localhost:5174${NC}"
echo -e "  📡 Backend:  ${BLUE}http://localhost:8000${NC}"
echo -e "  📚 API Docs: ${BLUE}http://localhost:8000/docs${NC}"
echo -e "\n  Press ${YELLOW}Ctrl+C${NC} to stop\n"

# Wait for processes
wait $BACKEND_PID $FRONTEND_PID
