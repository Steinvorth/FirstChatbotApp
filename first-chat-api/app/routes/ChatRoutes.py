"""
Chat Routes — The core of your chatbot API.

These are the endpoints your Flutter app will call.
Think of this file like a C# Controller — it defines the HTTP contract,
but the actual logic (calling OpenAI, managing history) will live elsewhere.

C# parallel:
    [ApiController]
    [Route("chat")]
    public class ChatController : ControllerBase { ... }
"""

from fastapi import APIRouter

router = APIRouter(
    prefix="/chat",
    tags=["Chat"],
)


# ============================================================
# POST /chat/send
# ============================================================
# This is your main endpoint. The Flutter app sends a user message,
# and this endpoint should return the AI's response.
#
# What you'll need to implement:
#   1. Accept a request body with the user's message (and maybe a conversation_id)
#   2. Build the messages payload (system prompt + history + new message)
#   3. Call OpenAI's chat completion API
#   4. Store the exchange in your conversation history
#   5. Return the AI's response
#
# Hints:
#   - Use a Pydantic model for the request body (like a C# record/DTO)
#   - Example: class SendMessageRequest(BaseModel): message: str
#   - FastAPI auto-validates and auto-documents it (just like ASP.NET model binding)
#
# TODO: Implement this endpoint
@router.post("/send")
def SendMessage():
    return {"detail": "Not implemented yet — this is your job!"}


# ============================================================
# GET /chat/history/{conversation_id}
# ============================================================
# Returns the message history for a given conversation.
# Your Flutter app will call this to load previous messages.
#
# What you'll need to implement:
#   1. Accept a conversation_id as a path parameter
#   2. Look up the stored messages for that conversation
#   3. Return them as a list
#
# Hints:
#   - Path params in FastAPI work like [Route("{id}")] in C#
#   - Just add the param to the function signature: def GetHistory(conversation_id: str)
#   - FastAPI picks it up automatically from the URL
#
# TODO: Implement this endpoint
@router.get("/history/{conversation_id}")
def GetHistory(conversation_id: str):
    return {"detail": f"Not implemented yet — load history for {conversation_id}"}


# ============================================================
# GET /chat/conversations
# ============================================================
# Returns a list of all conversations (id + maybe a title/preview).
# Your Flutter app will use this for a conversation list/sidebar.
#
# What you'll need to implement:
#   1. Return all stored conversations with their IDs and metadata
#
# Hints:
#   - Start simple: just return a list of conversation IDs
#   - Later you can add titles, timestamps, message counts, etc.
#
# TODO: Implement this endpoint
@router.get("/conversations")
def GetConversations():
    return {"detail": "Not implemented yet — list all conversations"}


# ============================================================
# DELETE /chat/history/{conversation_id}
# ============================================================
# Deletes a conversation and its history.
#
# What you'll need to implement:
#   1. Accept a conversation_id
#   2. Remove that conversation from storage
#   3. Return a confirmation
#
# Hints:
#   - Same path param pattern as GetHistory
#   - Return a 204 No Content on success (from fastapi import Response, then Response(status_code=204))
#
# TODO: Implement this endpoint
@router.delete("/history/{conversation_id}")
def DeleteConversation(conversation_id: str):
    return {"detail": f"Not implemented yet — delete {conversation_id}"}
