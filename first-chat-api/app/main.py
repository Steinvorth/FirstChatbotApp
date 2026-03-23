"""
first-chat-api — Main Application Entry Point

Run with: uv run uvicorn app.main:app --reload

This is the starting point of your FastAPI application.
FastAPI works similar to ASP.NET Minimal APIs:
- You create an "app" instance (like WebApplication.CreateBuilder in C#)
- You attach route groups to it (like MapGroup / MapGet in C#)
"""

from fastapi import FastAPI
from app.routes.ChatRoutes import router as chat_router
from app.routes.HealthRoutes import router as health_router

app = FastAPI(
    title="First Chat API",
    description="Learning FastAPI by building a chatbot backend",
    version="0.1.0",
)

# --- Register route groups (like app.MapGroup() in ASP.NET) ---
app.include_router(health_router)
app.include_router(chat_router)
