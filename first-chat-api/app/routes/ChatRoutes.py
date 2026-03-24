from dotenv import load_dotenv
import os
import uuid
import json

# ── Load .env FIRST, before any SDK imports ──────────────
envPath = os.path.join(os.path.dirname(__file__), "..", "..", "..", ".env")
load_dotenv(os.path.abspath(envPath), override=True)

from fastapi import APIRouter, Response
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from typing import Optional
from langfuse.openai import OpenAI
from langfuse import get_client

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
# POST /chat/send — Streaming via Server-Sent Events (SSE)
# ============================================================
# The response is streamed as SSE events:
#   1. event: conversation_id  → data: "uuid-123"
#   2. event: token            → data: "Hello"
#   3. event: token            → data: " there"
#   4. event: done             → data: ""
#
# Flutter reads these events in real-time and appends each
# token to the AI bubble as it arrives.
@router.post("/send")
def SendMessage(request: SendMessageRequest):
    convo_id = request.conversation_id or str(uuid.uuid4())

    messages = GetMessages(convo_id)

    messages.append(
        {
            "role": "user",
            "content": request.message,
        }
    )

    payload = [SYSTEM_PROMPT] + messages

    def StreamTokens():
        # --- Send conversation_id first so Flutter can track it ---
        yield f"event: conversation_id\ndata: {convo_id}\n\n"

        # --- Stream from OpenAI with stream=True ---
        stream = openaiClient.chat.completions.create(
            model="gpt-4o-mini",
            messages=payload,
            stream=True,
        )

        fullResponse = ""

        for chunk in stream:
            # Each chunk has choices[0].delta.content
            # delta.content is None for the first/last chunks
            delta = chunk.choices[0].delta
            if delta.content is not None:
                token = delta.content
                fullResponse += token
                # Encode token as JSON string to handle newlines/quotes safely
                yield f"event: token\ndata: {json.dumps(token)}\n\n"

        # --- Done streaming — save to history ---
        messages.append(
            {
                "role": "assistant",
                "content": fullResponse,
            }
        )

        title = request.message[:50]
        SaveConversation(convo_id, title, messages)
        langfuseClient.flush()

        yield f"event: done\ndata: \n\n"

    return StreamingResponse(
        StreamTokens(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


# ============================================================
# GET /chat/history/{conversation_id}
# ============================================================
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
@router.get("/conversations")
def GetConversations():
    conversations = ListConversations()
    return {
        "conversations": conversations,
    }


# ============================================================
# DELETE /chat/history/{conversation_id}
# ============================================================
@router.delete("/history/{conversation_id}")
def DeleteConversation(conversation_id: str):
    deleted = StoreDeleteConversation(conversation_id)
    if not deleted:
        return {"error": True, "message": "Conversation not found"}
    return Response(status_code=204)
