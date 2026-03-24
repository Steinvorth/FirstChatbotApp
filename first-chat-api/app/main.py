"""
first-chat-api — Main Application Entry Point

Run with: uv run uvicorn app.main:app --reload
"""

import os
from dotenv import load_dotenv

# ── Load .env BEFORE anything else ───────────────────────
# This is the entry point uvicorn calls. We load env vars here
# so they're available when ChatRoutes.py imports OpenAI/Langfuse.
envPath = os.path.join(os.path.dirname(__file__), "..", "..", ".env")
load_dotenv(os.path.abspath(envPath), override=True)

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes.ChatRoutes import router as chat_router
from app.routes.HealthRoutes import router as health_router

app = FastAPI(
    title="First Chat API",
    description="Learning FastAPI by building a chatbot backend",
    version="0.1.0",
)

# --- CORS Middleware ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Register route groups ---
app.include_router(health_router)
app.include_router(chat_router)
