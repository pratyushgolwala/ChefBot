@echo off
echo Starting Hugging Face Chatbot Application...
echo.

REM Check if virtual environment exists
if not exist ".venv" (
    echo Creating virtual environment...
    python -m venv .venv
    echo Virtual environment created
)

REM Activate virtual environment
echo Activating virtual environment...
call .venv\Scripts\activate.bat

REM Install Python dependencies
echo Installing Python dependencies...
pip install -r requirements.txt

REM Check if frontend node_modules exists
if not exist "huggingface_chatbot\frontend\node_modules" (
    echo Installing frontend dependencies...
    cd huggingface_chatbot\frontend
    call npm install
    cd ..\..
)

echo.
echo Starting FastAPI backend on port 8000...
start cmd /k "cd huggingface_chatbot\backend && uvicorn main:app --reload --port 8000"

timeout /t 3 /nobreak >nul

echo Starting React frontend on port 5173...
start cmd /k "cd huggingface_chatbot\frontend && npm run dev"

echo.
echo Application started!
echo.
echo Backend:  http://localhost:8000
echo Frontend: http://localhost:5173
echo API Docs: http://localhost:8000/docs
echo.
echo First time setup notes:
echo - The DialoGPT model will download on first run ^(approx 1.5GB^)
echo - This may take several minutes depending on your internet speed
echo - Subsequent starts will be much faster
echo.
echo Press any key to exit this script (services will continue running)...
pause >nul