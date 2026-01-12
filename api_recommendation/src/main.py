from typing import Union, List

from fastapi import FastAPI, HTTPException, Query
from contextlib import asynccontextmanager
from dotenv import load_dotenv

from reco_service import RecoService

# Load environment variables
load_dotenv()

# Global service instance
reco_service = RecoService()

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Load resources on startup
    reco_service.load_resources()
    yield
    # Clean up if needed

app = FastAPI(lifespan=lifespan)


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    return {"item_id": item_id, "q": q}

@app.get("/inference/{steam_id}")
def get_recommendations(steam_id: str, limit: int = Query(10, ge=1, le=50)):
    """
    Get recommendations.
    limit: Number of recommendations to return (1-50, default 10).
    """
    try:
        recommendations = reco_service.recommend(steam_id, limit=limit)
        return {"steam_id": steam_id, "limit": limit, "recommendations": recommendations}
    except Exception as e:
        return {"error": str(e)}
