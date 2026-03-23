"""
Health Routes — Simple check to verify the API is running.

C# equivalent: a minimal "GET /health" endpoint that returns 200 OK.
"""

from fastapi import APIRouter

router = APIRouter(
    prefix="/health",
    tags=["Health"],
)


@router.get("/")
def GetHealth():
    """
    GET /health
    Returns a simple status check. Use this to verify your API is running.

    TODO (your task):
    - This one is done for you as a reference. Study how it works.
    - Notice: the decorator (@router.get) defines the HTTP method + path.
    - The function return value gets auto-serialized to JSON (like returning Ok() in C#).
    """
    return {"status": "ok"}
