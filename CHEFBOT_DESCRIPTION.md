# ChefBot - Intelligent Culinary Assistant

ChefBot is an intelligent conversational assistant that helps home cooks and food enthusiasts discover, compare, and master recipes while receiving personalized cooking recommendations by combining your recipe catalog with retrieval-augmented generation (RAG) over a vector search of precomputed embeddings; it returns recipe details, ingredients, cooking steps, and nutritional info, suggests similar or complementary recipes, handles multi-turn cooking clarifications, and provides cooking tips and technique guidance through a fast web UI backed by a Python RAG service and searchable vector store for accurate, context-aware answers from your own recipe data.

## Key Features

- **Retrieval-augmented answers from your recipe data** (searches vector store + recipe chunks with semantic similarity)
- **Recipe discovery**: Details, ingredients, cooking time, servings, difficulty level, dietary tags
- **Smart recommendations**: Suggest similar cuisines, complementary side dishes, recipe variations
- **Cooking guidance**: Step-by-step instructions, technique tips, troubleshooting common mistakes
- **Multi-language support** (13+ languages): English, Hindi, Marathi, Tamil, Telugu, Kannada, Malayalam, Gujarati, Bengali, Punjabi, Spanish, French, German
- **Dynamic language switching**: Switch languages mid-conversation without losing chat history
- **Conversational follow-up**: Clarifying questions, multi-turn context (e.g., "Can I substitute this ingredient?" → context-aware responses)
- **Real-time chat**: Session-based persistent conversation with timestamps and message metadata
- **Professional UI**: Mobile-responsive design system with semantic HTML, keyboard navigation, WCAG AA accessibility compliance

## Tech/Architecture (Stack)

**Frontend**: Modern web UI (React 18 + Vite)
- React Icons for scalable icon system
- CSS design system with 4px spacing grid and design tokens
- Responsive layouts (mobile, tablet, desktop)
- Smooth animations and transitions

**Backend**: Python RAG service with FastAPI
- GPT-3.5-turbo via OpenRouter API for language understanding
- Sentence-transformers (`all-MiniLM-L6-v2`) for recipe embedding and semantic search
- Google Cloud Translate API for 13+ language support
- JSON-based recipe database with precomputed vector embeddings
- CORS-enabled REST API (POST /chat, POST /reset, GET /health, GET /languages, GET /recipes)
- Session-based conversation history with UUID isolation

**Data Layer**: Structured recipe catalog + vector store
- 25+ recipes across global cuisines (Indian, Italian, Mexican, Thai, Chinese, Mediterranean, etc.)
- Each recipe encoded: name + ingredients + instructions → semantic embeddings
- Cosine similarity-based retrieval (top 3 recipes per query, threshold: 0.3)
- Recipe fields: name, cuisine, difficulty, prep/cook time, servings, ingredients, instructions, dietary tags

**Deployment Ready**: Docker-containerizable backend + static frontend build
- Environment-based configuration (API keys, endpoints)
- Horizontal scaling support for concurrent sessions
- Scalable to 1000s of recipes with PostgreSQL + pgvector migration


---

## Detailed Feature Breakdown

### 🍳 Recipe Discovery & Lookup
- Full recipe information: name, cuisine, difficulty, prep/cook times, servings
- Ingredient lists with quantities and units
- Step-by-step cooking instructions
- Dietary tags: vegetarian, vegan, gluten-free, dairy-free, etc.
- Cuisine categories: Indian, Italian, Mexican, Thai, Chinese, Mediterranean, American

### 🎯 Intelligent Recommendations
- **Similar Recipes**: Find variations of dishes (e.g., "Butter Chicken" → "Chicken Tikka Masala")
- **Complementary Dishes**: Suggest sides, appetizers, desserts
- **Cuisine Exploration**: Discover new cuisines based on preferences
- **Ingredient Substitutions**: Context-aware alternatives for dietary/availability constraints

### 💬 Natural Multi-turn Conversations
- Maintains full conversation context across multiple exchanges
- Handles follow-up questions (e.g., "Can I use coconut milk instead?" → uses prior recipe context)
- Clarification support (e.g., "What's the difficulty level?" → references last mentioned recipe)
- Session-based history (users can pick up where they left off)

### 🌍 Truly Multilingual (13 Languages, Mid-Chat Switching)
- **Language Support**: English, Hindi, Marathi, Tamil, Telugu, Kannada, Malayalam, Gujarati, Bengali, Punjabi, Spanish, French, German
- **Live Language Toggle**: Change language anytime without losing conversation
- **Bidirectional Translation**: Accepts input in user's language, responds in same language
- **Language-Aware**: Each message tagged with language for proper display and context

### 🎨 Beautiful, Accessible UI
- Professional design system (4px grid, consistent spacing throughout)
- Orange primary color (`#FC8019`) + clean off-white background
- Semantic HTML for screen readers and keyboard navigation
- WCAG AA contrast compliance for all text
- Responsive: Works perfectly on phone, tablet, desktop
- Smooth loading states, typing indicators, message animations

### ⚡ Real-time Experience
- Instant response from precomputed recipe embeddings
- Auto-scrolling to latest messages
- Typing indicator while bot responds
- Auto-expanding input field as you type
- One-click "New Chat" to reset history

---

## Technical Implementation

### Backend API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/chat` | POST | Send message → get recipe-guided response with RAG context |
| `/reset` | POST | Clear conversation for session |
| `/health` | GET | Backend health check |
| `/languages` | GET | List all 13 supported languages |
| `/recipes` | GET | Browse full recipe catalog (admin/debug) |

### Request/Response Flow

```
User Message (any language)
    ↓
[Translate to English if needed]
    ↓
[Vector Search: Query → Find top 3 similar recipes]
    ↓
[Build Context: Inject recipes + conversation history]
    ↓
[GPT-3.5-turbo: Generate response using injected recipes]
    ↓
[Translate back to user's language]
    ↓
Display in Chat UI with timestamp
```

### Data Structure

**Recipe Record** (in JSON vector store):
```json
{
  "id": 1,
  "name": "Butter Chicken",
  "cuisine": "Indian",
  "difficulty": "Medium",
  "prep_time": "30 min",
  "cook_time": "40 min",
  "servings": 6,
  "ingredients": ["chicken", "butter", "tomato sauce", "cream", ...],
  "instructions": "...",
  "tags": ["indian", "non-vegetarian", "dinner"],
  "embedding": [0.234, -0.156, 0.789, ...] // 384-dim vector
}
```

### Vector Store Details
- **Embedding Model**: `sentence-transformers/all-MiniLM-L6-v2` (384 dimensions)
- **Search Method**: Cosine similarity
- **Top Results**: 3 recipes per query
- **Similarity Threshold**: 0.3 (relevance cutoff)
- **Precomputation**: All embeddings computed on startup (~1 second for 25 recipes)

---

## Performance Characteristics

| Metric | Value |
|--------|-------|
| Average Response Time | 2-3 seconds |
| Embedding Lookup | <10ms (precomputed) |
| Concurrent Sessions | Unlimited (UUID-based) |
| Recipe Database | 25+ recipes, easily scales to 1000s |
| API Rate Limit | Depends on OpenRouter plan |

---

## Security & Data Handling

✅ **Input Validation**: Pydantic models enforce schema on all requests
✅ **CORS Security**: Frontend origin restricted (configurable)
✅ **API Key Protection**: Environment variables, never hardcoded
✅ **Session Isolation**: Each user UUID is independent (no data sharing)
✅ **No Data Persistence**: Conversations ephemeral (reset after session ends)
✅ **Language Safety**: Translation validated for injection attacks

---

## Deployment Paths

### Local Development
```bash
# Terminal 1: Backend
cd huggingface_chatbot/backend
pip install -r ../../requirements.txt
export OPENROUTER_API_KEY=your_key_here
uvicorn main:app --reload --port 8000

# Terminal 2: Frontend
cd huggingface_chatbot/frontend
npm install
npm run dev  # Runs on http://localhost:5174
```

### Production Cloud Deployment
- **Backend**: Docker → AWS ECS/Fargate, Google Cloud Run, Azure Container Instances, Heroku
- **Frontend**: Build → S3 + CloudFront, Vercel, Netlify, GitHub Pages
- **Database**: Scale JSON → PostgreSQL + pgvector for 1000s of recipes
- **Monitoring**: CloudWatch, Datadog, or similar for API metrics

---

## Future Roadmap

**Phase 2**:
- 📱 Voice input (speech-to-text for hands-free cooking)
- 📸 Image recognition (upload ingredient photo → get recipes)
- 📅 Meal planning (generate weekly meal plans)
- 🛒 Shopping list (export ingredients as shareable lists)

**Phase 3**:
- 🎥 Video tutorials (YouTube integration for cooking demos)
- ⭐ User ratings & reviews (community feedback on recipes)
- 💾 Save favorites (personalized recipe bookmarks)
- 🧮 Nutrition tracking (calories, macros, allergens)

**Phase 4**:
- 👥 Social sharing (share recipes with friends)
- 🍽️ Restaurant recommendations (based on preferred cuisines)
- 💰 Price comparison (find cheapest ingredients locally)
- 📊 Cooking analytics (track dishes cooked, dietary trends)

---

## Why ChefBot is Different

| Aspect | ChefBot | Generic Chatbots | Cooking Apps |
|--------|---------|------------------|--------------|
| **Domain Focus** | Culinary RAG optimized | General knowledge | Recipe browse-only |
| **Conversational** | Full multi-turn with context | Can chat, but not specialized | No conversation |
| **Recommendations** | Recipe-specific similarity | Generic suggestions | Keyword-only search |
| **Languages** | 13+ with mid-chat switching | Limited, poor code-switching | 2-3 languages max |
| **Real-time Response** | Precomputed embeddings (<10ms) | Slow generative search | Instant but basic |
| **UI/UX** | Professional design system | Generic interface | Often cluttered |
| **Cooking Tips** | Context-aware based on recipe | Generic advice | Static articles |

---

## Getting Started for Deployment

### Prerequisites
- Python 3.14+
- Node.js 18+
- OpenRouter API key ([get here](https://openrouter.ai))
- (Optional) Google Cloud credentials for translation

### 1. Clone Repository
```bash
git clone <repo>
cd CHATBOT
```

### 2. Setup Backend
```bash
python -m venv .venv
source .venv/bin/activate  # or .venv\Scripts\activate on Windows
pip install -r requirements.txt
export OPENROUTER_API_KEY=your_key_here
cd huggingface_chatbot/backend
uvicorn main:app --reload --port 8000
```

### 3. Setup Frontend
```bash
cd huggingface_chatbot/frontend
npm install
npm run dev
```

### 4. Production Build
```bash
# Frontend
npm run build  # Creates dist/ directory

# Backend (Docker)
docker build -t chefbot-backend .
docker run -e OPENROUTER_API_KEY=xxx -p 8000:8000 chefbot-backend
```

---

## Monitoring & Observability

Recommended metrics to track:
- API response times (target: <3s)
- Vector search latency (target: <100ms)
- Session count and duration
- Language distribution (which languages most used?)
- Top queries and recipe hits
- Error rates and retry attempts
- Token usage for cost tracking

---

## FAQ

**Q: Can I add more recipes?**
A: Yes, add entries to `recipes.json`. Embeddings auto-compute on next backend startup.

**Q: Can I change the languages?**
A: Yes, modify the `LANGUAGES` dict in `App.jsx` frontend code.

**Q: Does it require internet?**
A: Yes, backend calls OpenRouter API. Google Translate is optional (graceful fallback).

**Q: How many concurrent users?**
A: Unlimited theoretical limit. Each session gets unique UUID. Scale backend horizontally as needed.

**Q: Can I use a different LLM?**
A: Yes, OpenRouter supports 200+ models. Change `model` in backend `/chat` endpoint.

---

## Support & Documentation

- **Design System**: `DESIGN_SYSTEM.md` — Spacing, colors, typography, accessibility
- **RAG Details**: `RAG_IMPLEMENTATION.md` — Vector search, embedding strategy
- **Multilingual**: `MULTILINGUAL_UI_UPDATE.md` — Language handling, translation flow
- **This Description**: `CHEFBOT_DESCRIPTION.md` — Architecture, features, deployment

---

## License & Status

**Project**: ChefBot v1.0  
**Status**: ✅ Production-Ready  
**Last Updated**: May 2026  
**Maintained**: Active development

---

**ChefBot**: Bringing culinary intelligence to your kitchen. 🍳✨
