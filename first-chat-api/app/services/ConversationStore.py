"""
ConversationStore — JSON file-based conversation storage.

Stores all conversations in a single JSON file at `data/conversations.json`.
The file structure is:
{
    "conversation_id_1": {
        "title": "First message preview...",
        "messages": [
            {"role": "user", "content": "Hello"},
            {"role": "assistant", "content": "Hi there!"}
        ]
    },
    "conversation_id_2": { ... }
}

This replaces the in-memory dict so history survives server restarts.
"""

import json
import os

# ─── File path ─────────────────────────────────────────
# Stored in first-chat-api/data/conversations.json
# os.path.dirname(__file__) = app/services/
# Walk up to first-chat-api/, then into data/
DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "data")
FILE_PATH = os.path.join(DATA_DIR, "conversations.json")


def _EnsureFile():
    """Creates the data directory and file if they don't exist."""
    os.makedirs(DATA_DIR, exist_ok=True)
    if not os.path.exists(FILE_PATH):
        with open(FILE_PATH, "w") as f:
            json.dump({}, f)


def LoadAll() -> dict:
    """Reads the entire conversations file and returns it as a dict."""
    _EnsureFile()
    with open(FILE_PATH, "r") as f:
        return json.load(f)


def SaveAll(data: dict):
    """Writes the entire conversations dict back to the file."""
    _EnsureFile()
    with open(FILE_PATH, "w") as f:
        json.dump(data, f, indent=2)


def GetConversation(conversationId: str) -> dict | None:
    """Returns a single conversation by ID, or None if not found."""
    data = LoadAll()
    return data.get(conversationId)


def GetMessages(conversationId: str) -> list[dict]:
    """Returns the messages list for a conversation, or empty list."""
    convo = GetConversation(conversationId)
    if convo is None:
        return []
    return convo.get("messages", [])


def SaveConversation(conversationId: str, title: str, messages: list[dict]):
    """Creates or updates a single conversation in the file."""
    data = LoadAll()
    data[conversationId] = {
        "title": title,
        "messages": messages,
    }
    SaveAll(data)


def DeleteConversation(conversationId: str) -> bool:
    """Removes a conversation from the file. Returns True if it existed."""
    data = LoadAll()
    if conversationId in data:
        del data[conversationId]
        SaveAll(data)
        return True
    return False


def ListConversations() -> list[dict]:
    """Returns a summary list of all conversations (id, title, message count)."""
    data = LoadAll()
    result = []
    for convoId, convo in data.items():
        messages = convo.get("messages", [])
        # Get last message preview
        lastMessage = None
        if messages:
            lastMessage = messages[-1].get("content", "")[:80]
        result.append(
            {
                "id": convoId,
                "title": convo.get("title", "Untitled"),
                "message_count": len(messages),
                "last_message": lastMessage,
            }
        )
    return result
