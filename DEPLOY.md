# 🚀 ChefBot Deployment Guide: Render + Vercel + Keep-Alive Cron

This guide covers deploying **ChefBot Backend** on [Render](https://render.com), **ChefBot Frontend** on [Vercel](https://vercel.com), and setting up a **Keep-Alive Cron** so the Render free tier never sleeps.

---

## 📑 Table of Contents
1. [Backend Deployment (Render)](#1-backend-deployment-render)
2. [Keep-Alive Cron Setup (Never Sleeps)](#2-keep-alive-cron-setup-so-backend-never-dies)
3. [Frontend Deployment (Vercel)](#3-frontend-deployment-vercel)
4. [Verifying End-to-End](#4-verifying-end-to-end)

---

## 1. Backend Deployment (Render)

Render provides free hosting for web services with automatic HTTPS and Git-based continuous deployment.

### Step-by-step Setup:
1. Log in to [Render Dashboard](https://dashboard.render.com/).
2. Click **New +** → **Web Service**.
3. Connect your GitHub repository (`ChefBot`).
4. Configure the Web Service settings:
   - **Name**: `chefbot-backend` (or your preferred name)
   - **Region**: Choose the closest region (e.g., *Oregon (US West)* or *Singapore*)
   - **Language / Runtime**: `Python 3`
   - **Root Directory**: `chefbot/backend`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`
   - **Instance Type**: `Free`

5. **Environment Variables** (under *Advanced* or *Environment* tab):
   Add the following:
   - `OPENROUTER_API_KEY`: `sk-or-v1-your_actual_key_here`
   - `PYTHON_VERSION`: `3.11.8` (recommended)

6. Click **Create Web Service**.

Render will build and deploy your service. Once deployed, note down your live backend URL (e.g., `https://chefbot-backend.onrender.com`).

---

## 2. Keep-Alive Cron Setup (So Backend Never Dies)

> 💡 **Render Free Tier Behavior**: Free web services spin down after **15 minutes** of inactivity. The next request can take 30–50 seconds to cold start. A simple cron ping every 10–14 minutes keeps the server warm 24/7.

### Option A: Free External Ping Service (Recommended - Zero Maintenance)
1. Go to [cron-job.org](https://cron-job.org/en/) (free forever) or [UptimeRobot](https://uptimerobot.com/).
2. Create a free account.
3. Click **Create Cronjob**:
   - **URL**: `https://<YOUR-RENDER-URL>.onrender.com/health` (e.g. `https://chefbot-backend.onrender.com/health`)
   - **Execution Schedule**: Every `10 minutes` (or `14 minutes`)
   - **Request Method**: `GET`
4. Save the cron job. Your backend will stay permanently warm.

---

### Option B: Built-in GitHub Actions Cron
The repository includes [.github/workflows/keepalive.yml](.github/workflows/keepalive.yml).

1. Push your repository to GitHub.
2. In your GitHub repo, go to **Settings** → **Secrets and variables** → **Actions**.
3. Click **New repository secret**:
   - **Name**: `BACKEND_HEALTH_URL`
   - **Value**: `https://<YOUR-RENDER-URL>.onrender.com/health`
4. Go to the **Actions** tab in GitHub and ensure workflows are enabled. The cron will automatically ping your backend every 14 minutes.

---

## 3. Frontend Deployment (Vercel)

Vercel provides blazing-fast static edge hosting with automatic global CDN for Vite/React.

### Step-by-step Setup:
1. Log in to [Vercel](https://vercel.com).
2. Click **Add New...** → **Project**.
3. Import your `ChefBot` GitHub repository.
4. In the **Configure Project** window:
   - **Framework Preset**: `Vite`
   - **Root Directory**: Click *Edit* and select `chefbot/frontend`
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`
   - **Install Command**: `npm install`
5. **Environment Variables**:
   Add:
   - **Key**: `VITE_BACKEND_URL`
   - **Value**: `https://<YOUR-RENDER-URL>.onrender.com` (your Render backend URL without trailing slash)
6. Click **Deploy**.

Vercel will output your live URL (e.g., `https://chefbot-frontend.vercel.app`).

---

## 4. Verifying End-to-End

### 1. Test Backend Health:
```bash
curl https://<YOUR-RENDER-URL>.onrender.com/health
```
Expected response:
```json
{
  "status": "healthy",
  "bot": "ChefBot with RAG + Multi-language",
  "recipes_loaded": 25
}
```

### 2. Test Frontend:
1. Open your Vercel URL in your browser.
2. Ask a question like: *"How do I make Butter Chicken?"* or switch the language to Hindi/Spanish.
3. Check browser console (`F12` → Network tab) to confirm requests are hitting your Render backend `/chat` endpoint.
