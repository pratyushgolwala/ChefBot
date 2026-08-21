# 🍳 ChefBot - AI Culinary Assistant

ChefBot is an intelligent, multi-language conversational culinary assistant powered by Retrieval-Augmented Generation (RAG). It combines a structured recipe database with semantic vector search (`sentence-transformers/all-MiniLM-L6-v2`) and OpenRouter/LLMs to deliver accurate recipe recommendations, step-by-step cooking instructions, ingredient substitutions, and multi-turn cooking guidance.

---

## 📁 Repository Structure

```
ChefBot/
├── chefbot/
│   ├── backend/               # FastAPI Python Backend
│   │   ├── main.py            # API routes, RAG engine, CORS & health checks
│   │   ├── recipes.json       # Structured recipe database with tags & instructions
│   │   └── requirements.txt   # Python backend dependencies
│   └── frontend/              # React (Vite) Web Application
│       ├── public/            # Static assets
│       ├── src/               # React components & styles
│       ├── .env.development   # Local dev environment config
│       ├── .env.production    # Production build config
│       └── package.json       # Frontend dependencies & scripts
├── .github/
│   └── workflows/
│       └── keepalive.yml      # GitHub Actions Cron to prevent Render backend from sleeping
├── start.sh                   # Unified startup script for backend & frontend
├── DEPLOY.md                  # Complete Render + Vercel Deployment & Keep-Alive Guide
└── CHEFBOT_DESCRIPTION.md     # Detailed architecture & feature documentation
```

---

## 🚀 Quickstart (Local Development)

### 1. Unified Startup Script
Start both Backend and Frontend together in one terminal:
```bash
./start.sh
```
*(Press `Ctrl + C` anytime to cleanly terminate both processes).*

You can also run them individually:
```bash
./start.sh backend     # Starts FastAPI on http://localhost:8000
./start.sh frontend    # Starts Vite on http://localhost:5173
```

---

## 🌐 Production Deployment

ChefBot is architected for zero-cost, scalable cloud deployment:

- **Backend:** Hosted on **Render** (FastAPI Web Service)
- **Frontend:** Hosted on **Vercel** (Global CDN for React/Vite)
- **Keep-Alive Cron:** **GitHub Actions / Cron-Job.org** (Pings `/health` every 10–14 min so Render free tier never sleeps)

👉 **For complete step-by-step instructions, see [DEPLOY.md](DEPLOY.md).**

---

## 🛠 Tech Stack

- **Frontend:** React 19, Vite, React Icons, Vanilla CSS Design System
- **Backend:** FastAPI, Uvicorn, Sentence-Transformers, NumPy, Python-Dotenv, Langdetect
- **AI & RAG:** OpenRouter API (`openai/gpt-3.5-turbo`), `all-MiniLM-L6-v2` Embeddings, Cosine Similarity
- **Deployment:** Render (Backend), Vercel (Frontend), GitHub Actions (Keep-Alive Cron)