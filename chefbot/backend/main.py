from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
from sentence_transformers import SentenceTransformer
import numpy as np
import requests
import uuid
import os
import json
from dotenv import load_dotenv
from langdetect import detect, LangDetectException
from google.cloud import translate_v2
import logging

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "../../.env"))

API_KEY = os.getenv("openrouter_api_key")
OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"
MODEL = "openai/gpt-3.5-turbo"

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ── Multi-Language Setup ──────────────────────────────────────────────────────

# Language mapping for Google Translate
LANGUAGE_CODES = {
    'hi': 'Hindi',
    'ta': 'Tamil',
    'te': 'Telugu',
    'kn': 'Kannada',
    'ml': 'Malayalam',
    'mr': 'Marathi',
    'gu': 'Gujarati',
    'bn': 'Bengali',
    'pa': 'Punjabi',
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'zh-cn': 'Chinese (Simplified)',
    'ja': 'Japanese',
    'ko': 'Korean',
}

# Use Google Translate API (free tier available)
try:
    translate_client = translate_v2.Client()
    logger.info("✓ Google Translate client initialized")
except Exception as e:
    logger.warning(f"Google Translate not available: {e}. Will use manual translation.")
    translate_client = None

def detect_language(text: str) -> str:
    """Detect the language of input text."""
    try:
        lang = detect(text)
        return lang
    except LangDetectException:
        return 'en'

def translate_text(text: str, source_lang: str, target_lang: str) -> str:
    """Translate text from source to target language."""
    if source_lang == target_lang:
        return text
    
    if not translate_client:
        logger.warning(f"Translation not available: {source_lang} -> {target_lang}")
        return text
    
    try:
        result = translate_client.translate_text(
            text=text,
            source_language_code=source_lang,
            target_language_code=target_lang
        )
        return result['translatedText']
    except Exception as e:
        logger.error(f"Translation error: {e}")
        return text

# ── RAG Setup ─────────────────────────────────────────────────────────────────

print("🔧 Loading sentence transformer model...")
embedder = SentenceTransformer('all-MiniLM-L6-v2')
print("✓ Embedder loaded")

print("📚 Loading recipe database...")
with open(os.path.join(os.path.dirname(__file__), "recipes.json"), "r") as f:
    recipes = json.load(f)
print(f"✓ Loaded {len(recipes)} recipes")

print("🧮 Computing recipe embeddings...")
recipe_texts = []
for r in recipes:
    text = f"{r['name']} {r['cuisine']} {r['difficulty']} "
    text += f"{' '.join(r['ingredients'])} {r['instructions']} "
    text += f"{' '.join(r.get('tags', []))}"
    recipe_texts.append(text)

recipe_embeddings = embedder.encode(recipe_texts, convert_to_numpy=True)
print(f"✓ Embeddings ready: {recipe_embeddings.shape}")

# ── ChefBot System Prompt ─────────────────────────────────────────────────────

SYSTEM_PROMPT = """You are ChefBot 🍳, a friendly and knowledgeable culinary assistant with access to a recipe database.

You help users with:
- Recipe recommendations based on their preferences
- Step-by-step cooking instructions
- Ingredient substitutions and shopping tips
- Cooking techniques and troubleshooting
- Dietary accommodations (vegan, gluten-free, etc.)
- Meal planning and prep advice

When answering:
- If the user asks about a recipe, dish, or ingredient, use the retrieved recipes first
- Use the retrieved recipe data to give accurate, specific answers
- If no relevant recipes are found, use your general culinary knowledge
- Be warm, encouraging, and practical
- Give clear, structured answers
- Stay strictly on food and cooking topics
- If user sends queries in multiple languages, respond in the SAME language they asked in

Retrieved recipes will be provided in your context when relevant."""

# In-memory conversation history per session
session_histories: dict[str, list] = {}

# ── App setup ─────────────────────────────────────────────────────────────────

app = FastAPI(
    title="ChefBot API with RAG + Multi-language",
    description="AI culinary assistant with recipes and multi-language support",
    version="3.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Schemas ───────────────────────────────────────────────────────────────────

class ChatRequest(BaseModel):
    message: str
    session_id: Optional[str] = None
    language: Optional[str] = 'en'  # User's selected language

class ChatResponse(BaseModel):
    response: str
    session_id: str

class ResetRequest(BaseModel):
    session_id: str

# ── RAG Functions ─────────────────────────────────────────────────────────────

def retrieve_recipes(query: str, top_k: int = 3) -> list:
    """Retrieve top-k most relevant recipes using semantic similarity."""
    query_embedding = embedder.encode([query], convert_to_numpy=True)[0]
    similarities = np.dot(recipe_embeddings, query_embedding) / (
        np.linalg.norm(recipe_embeddings, axis=1) * np.linalg.norm(query_embedding)
    )
    top_indices = np.argsort(similarities)[-top_k:][::-1]
    
    results = []
    for idx in top_indices:
        recipe = recipes[idx].copy()
        recipe['similarity_score'] = float(similarities[idx])
        results.append(recipe)
    
    return results

def format_recipes_for_context(retrieved: list) -> str:
    """Format retrieved recipes into a readable context block for GPT."""
    if not retrieved:
        return ""
    
    context = "\n\n=== RETRIEVED RECIPES ===\n"
    for i, r in enumerate(retrieved, 1):
        context += f"\n[Recipe {i}] {r['name']}\n"
        context += f"Cuisine: {r['cuisine']} | Difficulty: {r['difficulty']} | "
        context += f"Prep: {r['prep_time']} | Cook: {r['cook_time']} | Servings: {r['servings']}\n"
        context += f"Ingredients: {', '.join(r['ingredients'])}\n"
        context += f"Instructions: {r['instructions']}\n"
        if r.get('tags'):
            context += f"Tags: {', '.join(r['tags'])}\n"
    
    context += "\n=== END RETRIEVED RECIPES ===\n"
    return context

# ── OpenRouter Call ───────────────────────────────────────────────────────────

def call_openrouter(messages: list) -> str:
    """Send messages to OpenRouter and return the assistant reply."""
    if not API_KEY:
        raise ValueError("openrouter_api_key not found in .env")

    payload = {
        "model": MODEL,
        "messages": messages,
        "temperature": 0.7,
        "max_tokens": 800,
    }

    resp = requests.post(
        OPENROUTER_URL,
        headers={
            "Authorization": f"Bearer {API_KEY}",
            "Content-Type": "application/json",
        },
        json=payload,
        timeout=30,
    )

    if resp.status_code != 200:
        raise ValueError(f"OpenRouter error {resp.status_code}: {resp.text}")

    return resp.json()["choices"][0]["message"]["content"].strip()

# ── Endpoints ─────────────────────────────────────────────────────────────────

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """Send a message to ChefBot with RAG and language support."""
    try:
        session_id = request.session_id or str(uuid.uuid4())
        user_message = request.message
        target_language = request.language or 'en'  # Use selected language

        logger.info(f"User selected language: {target_language}")

        # ── Translate to English for processing (if not already English) ──
        if target_language != 'en':
            english_message = translate_text(user_message, target_language, 'en')
            logger.info(f"Translated to English: {english_message}")
        else:
            english_message = user_message

        # Get or create history
        if session_id not in session_histories:
            session_histories[session_id] = []

        history = session_histories[session_id]

        # ── RAG: Retrieve relevant recipes ──
        retrieved = retrieve_recipes(english_message, top_k=3)
        relevant_recipes = [r for r in retrieved if r['similarity_score'] > 0.3]
        recipe_context = format_recipes_for_context(relevant_recipes)

        # ── Build prompt with RAG context ──
        augmented_message = english_message
        if recipe_context:
            augmented_message = f"{recipe_context}\n\nUser question: {english_message}"

        # Append to history (store in English)
        history.append({"role": "user", "content": augmented_message})

        # Build full message list
        messages = [{"role": "system", "content": SYSTEM_PROMPT}] + history

        # Keep context manageable
        if len(messages) > 21:
            messages = [messages[0]] + messages[-20:]

        # Call GPT (will get response in English)
        reply_english = call_openrouter(messages)

        # ── Translate response back to user's language ──
        if target_language != 'en':
            reply = translate_text(reply_english, 'en', target_language)
            logger.info(f"Translated response to {target_language}")
        else:
            reply = reply_english

        # Save assistant reply (in English for history)
        history.append({"role": "assistant", "content": reply_english})
        session_histories[session_id] = history

        return ChatResponse(
            response=reply,
            session_id=session_id,
        )

    except Exception as e:
        logger.error(f"Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/reset")
async def reset_conversation(request: ResetRequest):
    """Clear conversation history for a session."""
    session_histories[request.session_id] = []
    return {"message": "Conversation reset successfully", "session_id": request.session_id}


@app.get("/health")
async def health_check():
    """Check if the API is running."""
    return {
        "status": "healthy",
        "bot": "ChefBot with RAG + Multi-language",
        "model": MODEL,
        "embedder": "all-MiniLM-L6-v2",
        "recipes_loaded": len(recipes),
        "active_sessions": len(session_histories),
        "languages_supported": list(LANGUAGE_CODES.values()),
    }


@app.get("/recipes")
async def list_recipes():
    """List all available recipes (for debugging)."""
    return {
        "total": len(recipes),
        "recipes": [{"id": r["id"], "name": r["name"], "cuisine": r["cuisine"]} for r in recipes]
    }

@app.get("/languages")
async def supported_languages():
    """List all supported languages."""
    return {
        "supported_languages": LANGUAGE_CODES,
        "total": len(LANGUAGE_CODES)
    }
