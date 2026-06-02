#!/bin/bash

# Chatbot Application Runner
# Run this script to start both backend and frontend

echo "🚀 Starting Hugging Face Chatbot Application..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo -e "${YELLOW}⚠️  Virtual environment not found. Creating...${NC}"
    python3 -m venv .venv
    echo -e "${GREEN}✅ Virtual environment created${NC}"
fi

# Activate virtual environment
echo -e "${BLUE}🔧 Activating virtual environment...${NC}"
source .venv/bin/activate

# Install Python dependencies if needed
echo -e "${BLUE}📦 Checking Python dependencies...${NC}"
pip install -r requirements.txt

# Check if frontend node_modules exists
if [ ! -d "huggingface_chatbot/frontend/node_modules" ]; then
    echo -e "${YELLOW}⚠️  Frontend dependencies not found. Installing...${NC}"
    cd huggingface_chatbot/frontend
    npm install
    cd ../..
    echo -e "${GREEN}✅ Frontend dependencies installed${NC}"
fi

# Start backend in background
echo -e "${BLUE}⚙️  Starting FastAPI backend on port 8000...${NC}"
cd huggingface_chatbot/backend
uvicorn main:app --reload --port 8000 &
BACKEND_PID=$!
cd ../..

# Wait a moment for backend to start
sleep 3

# Start frontend in background
echo -e "${BLUE}🎨 Starting React frontend on port 5173...${NC}"
cd huggingface_chatbot/frontend
npm run dev &
FRONTEND_PID=$!
cd ../..

echo -e "${GREEN}✅ Both services started!${NC}"
echo ""
echo -e "${GREEN}📊 Application Status:${NC}"
echo -e "  Backend:  ${GREEN}http://localhost:8000${NC}"
echo -e "  Frontend: ${GREEN}http://localhost:5173${NC}"
echo -e "  API Docs: ${GREEN}http://localhost:8000/docs${NC}"
echo ""
echo -e "${YELLOW}📝 First time setup notes:${NC}"
echo -e "  • The DialoGPT model will download on first run (≈1.5GB)"
echo -e "  • This may take several minutes depending on your internet speed"
echo -e "  • Subsequent starts will be much faster"
echo ""
echo -e "${BLUE}🛑 To stop both services, press Ctrl+C${NC}"

# Trap Ctrl+C to clean up
trap 'echo -e "\n${RED}🛑 Stopping services...${NC}"; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit 0' INT

# Keep script running
wait