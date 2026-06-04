# ChefBot Frontend Deployment on Vercel

Deploy your React frontend on Vercel to connect with your Railway backend.

**Cost**: Free tier available  
**Time to deploy**: 5 minutes  
**Features**: Global CDN, auto HTTPS, zero config

---

## Prerequisites

- Vercel account (free at https://vercel.com)
- GitHub repo with frontend code (already pushed ✅)
- Railway backend URL: `https://chefbot-production-8ebc.up.railway.app` ✅

---

## Step-by-Step Deployment

### Step 1: Create Vercel Account

1. Go to https://vercel.com
2. Click **"Sign Up"**
3. Select **"Continue with GitHub"**
4. Authorize Vercel to access your repos

### Step 2: Import Project

1. In Vercel dashboard, click **"New Project"**
2. Search for **"ChefBot"**
3. Click **"Import"**

### Step 3: Configure Project

**Project Settings:**
- **Name**: `chefbot-frontend` (or any name)
- **Framework**: `Vite`
- **Root Directory**: `./chefbot/frontend` (Vercel auto-detects this)

### Step 4: Set Environment Variables

⚠️ **IMPORTANT**: This step connects your frontend to your Railway backend!

1. In the import dialog, scroll to **"Environment Variables"**
2. Add the backend URL:

```
Variable Name: VITE_BACKEND_URL
Value: https://chefbot-production-8ebc.up.railway.app
```

3. Click **"Deploy"**

### Step 5: Wait for Deployment

Vercel will:
1. Clone your repo
2. Install dependencies
3. Build the React app
4. Deploy to global CDN

Watch the deployment logs. When complete, you'll get a URL:

```
https://chefbot-frontend.vercel.app
```

---

## Verify Deployment

### 1. Open Your Frontend

```
https://chefbot-frontend.vercel.app
```

### 2. Test Chat

1. Type a message: "How do I make butter chicken?"
2. Wait for response from backend
3. Should get a recipe!

### 3. Check Language Switching

1. Change language from dropdown
2. Type another message
3. Should respond in chosen language

### 4. View Console

1. Open browser DevTools (F12)
2. Go to Console tab
3. Should show no errors
4. Should see successful API calls

---

## Environment Variable Configuration

### Using `.env` Files

Your frontend already has `.env` files configured:

**`.env.production`** (for Vercel):
```
VITE_BACKEND_URL=https://chefbot-production-8ebc.up.railway.app
```

**`.env.development`** (for local dev):
```
VITE_BACKEND_URL=http://localhost:8000
```

### How It Works

When you run:
- **Locally**: Uses `http://localhost:8000` (dev)
- **Vercel**: Uses `https://chefbot-production-8ebc.up.railway.app` (production)

---

## How the Frontend Connects to Backend

The frontend code now does this:

```javascript
// App.jsx
const API_BASE_URL = import.meta.env.VITE_BACKEND_URL || 'https://chefbot-production-8ebc.up.railway.app'

// When user sends message:
const res = await fetch(`${API_BASE_URL}/chat`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ message, session_id, language }),
})
```

**What happens:**
1. Frontend sends request to: `https://chefbot-production-8ebc.up.railway.app/chat`
2. Backend processes message using RAG
3. Backend returns response
4. Frontend displays in chat

---

## Troubleshooting

### Issue: App Deploys but Shows Blank Page

**Cause**: Build failed or frontend can't connect to backend

**Fix**:
1. Go to Vercel dashboard
2. Click your project
3. Go to "Deployments" tab
4. Check the build logs for errors
5. Redeploy

### Issue: Chat Returns Error - "Unable to connect"

**Cause**: Backend URL is wrong or backend is down

**Fix**:
1. Check VITE_BACKEND_URL environment variable in Vercel
2. Verify it's: `https://chefbot-production-8ebc.up.railway.app`
3. Test backend health: `curl https://chefbot-production-8ebc.up.railway.app/health`
4. If backend is down, deploy on Railway first

### Issue: Slow Initial Load

**Cause**: Railway backend cold starting on first request

**Fix**:
1. This is normal on free tiers
2. First request ~2-3 seconds
3. Subsequent requests are faster
4. Upgrade Railway to paid for instant response

### Issue: 403 CORS Error

**Cause**: Backend CORS configuration issue

**Fix**:
1. Backend needs to allow Vercel domain
2. Update backend `main.py` if needed:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://chefbot-frontend.vercel.app", "http://localhost:3000"],
    allow_methods=["*"],
    allow_headers=["*"],
)
```

Then redeploy backend on Railway.

---

## Deployment Checklist

- [ ] Vercel account created
- [ ] ChefBot repo imported to Vercel
- [ ] Root directory set to `./chefbot/frontend`
- [ ] Environment variable added: `VITE_BACKEND_URL=https://chefbot-production-8ebc.up.railway.app`
- [ ] Deployment successful
- [ ] Frontend URL accessible
- [ ] Chat works with backend
- [ ] Language switching works
- [ ] No console errors

---

## Your URLs After Deployment

| Component | URL |
|-----------|-----|
| **Frontend** | `https://chefbot-frontend.vercel.app` |
| **Backend** | `https://chefbot-production-8ebc.up.railway.app` |
| **Backend API Docs** | `https://chefbot-production-8ebc.up.railway.app/docs` |

---

## Cost

**Vercel Free Tier:**
- ✅ Unlimited bandwidth
- ✅ Global CDN
- ✅ Auto HTTPS
- ✅ 100 GB/month data transfer
- ✅ Fast deploys

**Perfect for ChefBot!**

---

## Update Frontend Code

If you need to change the backend URL later:

### Option 1: Update `.env.production`

```
VITE_BACKEND_URL=https://your-new-backend-url.com
```

Then:
```bash
git add .env.production
git commit -m "Update backend URL"
git push origin main
# Vercel auto-redeploys!
```

### Option 2: Update in Vercel Dashboard

1. Go to Vercel project settings
2. Go to "Environment Variables"
3. Update `VITE_BACKEND_URL`
4. Redeploy

---

## Monitoring

### View Deployment Logs

1. Vercel dashboard → Your project
2. Click "Deployments" tab
3. Click latest deployment
4. View build logs

### View Frontend Performance

1. Vercel dashboard → Your project
2. Click "Monitoring" tab
3. See performance metrics

### View Backend API Calls

1. Open browser DevTools (F12)
2. Go to "Network" tab
3. Send a message
4. See API call to `https://chefbot-production-8ebc.up.railway.app/chat`

---

## Local Development

To test locally before deploying to Vercel:

```bash
cd chefbot/frontend

# Install dependencies
npm install

# Run dev server (uses .env.development)
npm run dev

# Open http://localhost:5173
```

The app will use `http://localhost:8000` (make sure backend is running locally!)

---

## Next Steps

1. ✅ Deploy frontend on Vercel
2. ✅ Frontend connects to Railway backend
3. ✅ Test end-to-end
4. ✅ Share your live URL: `https://chefbot-frontend.vercel.app`
5. ✅ Monitor performance
6. ✅ Upgrade to paid if needed

---

## End-to-End Testing Checklist

After deployment, test everything:

- [ ] Frontend loads without errors
- [ ] Can type a message
- [ ] Backend responds with recipe
- [ ] Language dropdown works
- [ ] Can switch languages mid-chat
- [ ] Messages display with timestamps
- [ ] User messages on right, bot on left
- [ ] "New Chat" button clears history
- [ ] No console errors (F12)
- [ ] API calls show correct backend URL

---

## Success Indicators

✅ You're ready when:

1. Frontend page loads at Vercel URL
2. You can type a message
3. Backend responds with recipes
4. Language switching works
5. No errors in browser console
6. Network tab shows successful API calls

---

## Summary

**Vercel is perfect for frontend because:**
- ✅ Free tier is generous
- ✅ Global CDN (fast worldwide)
- ✅ Auto deploys on git push
- ✅ Environment variables support
- ✅ Easy to update
- ✅ Great monitoring

**Total Time:** 5 minutes

**Cost:** Free

---

**Your live ChefBot is ready!** 🚀

**Frontend**: https://chefbot-frontend.vercel.app  
**Backend**: https://chefbot-production-8ebc.up.railway.app

Now share with friends! 🎉
