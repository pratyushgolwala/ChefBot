@echo off
REM ChefBot Local Development Starter Script for Windows

setlocal enabledelayedexpansion

echo.
echo =====================================
echo   ChefBot - Local Development Setup
echo =====================================
echo.

REM Check if .env exists
if not exist .env (
    echo WARNING: .env file not found!
    echo Creating from template...
    copy .env.example .env
    echo Please edit .env and add your OPENROUTER_API_KEY
    echo Get key from: https://openrouter.ai
    pause
    exit /b 1
)

REM Check for API key
findstr /M "OPENROUTER_API_KEY=sk_" .env >nul
if errorlevel 1 (
    echo WARNING: OPENROUTER_API_KEY not configured in .env
    echo Get your key from: https://openrouter.ai
    pause
    exit /b 1
)

echo [OK] Environment configured
echo.

REM Setup Python backend
echo Setting up backend...
if not exist .venv (
    python -m venv .venv
    echo [OK] Virtual environment created
)

call .venv\Scripts\activate
pip install -q -r requirements.txt
echo [OK] Backend dependencies installed
echo.

REM Setup Node frontend
echo Setting up frontend...
cd chefbot\frontend
if not exist node_modules (
    npm install -q
    echo [OK] Frontend dependencies installed
) else (
    echo [OK] Frontend dependencies already installed
)
cd ..\..
echo.

echo =====================================
echo [OK] Setup complete!
echo =====================================
echo.
echo Starting ChefBot...
echo.

REM Start backend
echo Backend starting on http://localhost:8000
start "" cmd /k "cd chefbot\backend && uvicorn main:app --reload --port 8000"

REM Give backend time to start
timeout /t 2 /nobreak

REM Start frontend
echo Frontend starting on http://localhost:5174
start "" cmd /k "cd chefbot\frontend && npm run dev"

echo.
echo =====================================
echo   ChefBot is running! [ICON]
echo =====================================
echo.
echo   Frontend: http://localhost:5174
echo   Backend:  http://localhost:8000
echo   API Docs: http://localhost:8000/docs
echo.
echo   Press Ctrl+C in each terminal to stop
echo.
pause
