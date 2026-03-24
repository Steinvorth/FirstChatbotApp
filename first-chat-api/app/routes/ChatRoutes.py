from dotenv import load_dotenv
import os
import uuid

# ── Load .env FIRST, before any SDK imports ──────────────
# Langfuse and OpenAI both read env vars at import time,
# so the keys must be in os.environ BEFORE we import them.
envPath = os.path.join(os.path.dirname(__file__), "..", "..", "..", ".env")
load_dotenv(os.path.abspath(envPath), override=True)

from fastapi import APIRouter, Response
from pydantic import BaseModel
from typing import Optional
from langfuse.openai import OpenAI
from langfuse import get_client

# JSON file storage
from app.services.ConversationStore import (
    GetMessages,
    SaveConversation,
    DeleteConversation as StoreDeleteConversation,
    ListConversations,
)

openaiClient = OpenAI()
langfuseClient = get_client()


router = APIRouter(
    prefix="/chat",
    tags=["Chat"],
)


# ============================================================
# Request Model
# ============================================================
class SendMessageRequest(BaseModel):
    message: str
    conversation_id: Optional[str] = None


# ============================================================
# System Prompt
# ============================================================
SYSTEM_PROMPT = {
    "role": "system",
    "content": "You are a helpful assistant. Answer concisely and clearly.",
}


# ============================================================
# History Trimming
# ============================================================
def TrimHistory(history: list[dict], maxExchanges: int = 10) -> list[dict]:
    keep = maxExchanges * 2
    return history[-keep:]


# ============================================================
# POST /chat/send
# ============================================================
# Flow:
#   1. Flutter sends {"message": "...", "conversation_id": "..."}
#   2. We load existing history from the JSON file (or start fresh)
#   3. Append user message, call OpenAI, append assistant response
#   4. Save updated history back to the JSON file
#   5. Return response + conversation_id to Flutter
@router.post("/send")
def SendMessage(request: SendMessageRequest):
    # --- Step 1: Resolve conversation ID ---
    convo_id = request.conversation_id or str(uuid.uuid4())

    # --- Step 2: Load existing history from JSON file ---
    messages = GetMessages(convo_id)

    # --- Step 3: Append the user message ---
    messages.append(
        {
            "role": "user",
            "content": request.message,
        }
    )

    # --- Step 4: Build the payload for OpenAI ---
    trimmedHistory = TrimHistory(messages)
    payload = [SYSTEM_PROMPT] + trimmedHistory

    # --- Step 5: Call OpenAI (auto-traced by Langfuse) ---
    response = openaiClient.chat.completions.create(
        model="gpt-4o-mini",
        messages=payload,
    )
    aiMessage = response.choices[0].message.content

    # --- Step 6: Append assistant response ---
    messages.append(
        {
            "role": "assistant",
            "content": aiMessage,
        }
    )

    # --- Step 7: Save to JSON file ---
    # Use the first user message as the conversation title
    title = request.message[:50]
    SaveConversation(convo_id, title, messages)

    # --- Step 8: Flush Langfuse ---
    langfuseClient.flush()

    # --- Step 9: Return to Flutter ---
    return {
        "response": aiMessage,
        "conversation_id": convo_id,
    }


# ============================================================
# GET /chat/history/{conversation_id}
# ============================================================
# Returns the full message history for a conversation.
# Flutter calls this when the user taps a conversation in the sidebar.
@router.get("/history/{conversation_id}")
def GetHistory(conversation_id: str):
    messages = GetMessages(conversation_id)
    return {
        "conversation_id": conversation_id,
        "messages": messages,
    }


# ============================================================
# GET /chat/conversations
# ============================================================
# Returns a list of all conversations with metadata.
# Flutter calls this on startup to populate the sidebar.
@router.get("/conversations")
def GetConversations():
    conversations = ListConversations()
    return {
        "conversations": conversations,
    }


# ============================================================
# DELETE /chat/history/{conversation_id}
# ============================================================
# Deletes a conversation and its history from the JSON file.
@router.delete("/history/{conversation_id}")
def DeleteConversation(conversation_id: str):
    deleted = StoreDeleteConversation(conversation_id)
    if not deleted:
        return {"error": True, "message": "Conversation not found"}
    return Response(status_code=204)
