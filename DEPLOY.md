# ChefBot Deployment Guide

Simple deployment without Docker.

---

## Local Development

### Start Backend

```bash
bash start-backend.sh
```

Backend will run at: `http://localhost:8000`

### Start Frontend (new terminal)

```bash
bash start-frontend.sh
```

Frontend will run at: `http://localhost:5174`

---

## Production Deployment (Railway)

### Step 1: Create New Service

- Go to Railway
- New Project → Deploy from GitHub
- Select ChefBot repo

### Step 2: Configure Settings

**Settings → Source**
- **Root Directory**: `chefbot/backend`
- **Branch**: `main`

**Settings → Build**
- **Builder**: `Python`
- **Build Command**: `pip install -r requirements.txt`
- **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`

### Step 3: Add Environment Variables

**Variables tab:**
```
OPENROUTER_API_KEY = sk_live_your_actual_key
```

### Step 4: Deploy

Click **"Deploy"** and wait 2-3 minutes.

Your backend URL will be shown in Railway dashboard.

---

## Frontend on Vercel

1. Go to Vercel → Import Project
2. Select ChefBot repo
3. **Root Directory**: `chefbot/frontend`
4. **Environment Variables**:
   ```
   VITE_BACKEND_URL=https://your-railway-backend-url.com
   ```
5. Deploy!

---

## Testing

### Backend Health Check

```bash
curl https://your-railway-url/health
```

Expected:
```json
{"status": "healthy"}
```

### API Documentation

```
https://your-railway-url/docs
```

---

## That's It! 🚀

No Docker. Pure Python + Node deployment.

