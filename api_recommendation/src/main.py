from typing import Union, List, Optional
import os
from pydantic import BaseModel, Field

from fastapi import FastAPI, HTTPException, Query, Body, Security, Depends
from fastapi.security.api_key import APIKeyHeader
from contextlib import asynccontextmanager
from dotenv import load_dotenv

from reco_service import RecoService

@app.get("/health")
def health_check():
    """Route de santé utilisée par Docker pour vérifier que l'API est en vie."""
    return {"status": "ok"}

# --- Modèles Pydantic pour l'API ---

class GameItem(BaseModel):
    game_id: int = Field(..., description="ID Steam du jeu (AppID)", example=10)
    hours: float = Field(..., description="Nombre d'heures jouées", example=50.5)

class ManualRecoRequest(BaseModel):
    games: List[GameItem] = Field(..., description="Liste des jeux possédés")
    limit: int = Field(10, ge=1, le=50, description="Nombre de recommandations souhaitées")

# Load environment variables (Charge les variables d'environnement depuis le .env)
load_dotenv()

# Instance globale du service 
reco_service = RecoService()

# --- Sécurité API Key ---
API_KEY_NAME = "X-API-Key"
api_key_header = APIKeyHeader(name=API_KEY_NAME, auto_error=False)

async def get_api_key(api_key_header: str = Security(api_key_header)):
    """
    Vérifie la présence et la validité de la clé d'API dans le header X-API-Key.
    """
    expected_api_key = os.getenv("API_KEY")
    if not expected_api_key:
        # Si aucune clé n'est configurée côté serveur, on bloque
        return None 
        
    if api_key_header == expected_api_key:
        return api_key_header
    
    raise HTTPException(
        status_code=403,
        detail="Could not validate credentials (invalid or missing API Key)"
    )

@asynccontextmanager
async def lifespan(app: FastAPI):
    # --- Démarrage ---
    # Chargement unique des ressources (Modèle, CSV...) au lancement de l'API
    # Cela évite de recharger le modèle à chaque requête (gain de perf énorme).
    reco_service.load_resources()
    yield
    # --- Arrêt ---
    # Nettoyage si nécessaire (fermeture de connexions DB etc.)
    pass

app = FastAPI(lifespan=lifespan, title="Steam Recommendation API")


@app.get("/")
def read_root():
    """Route de santé simple."""
    return {"Hello": "World", "Status": "Ready"}


# --- Routes Sécurisées ---
# On applique la dépendance de sécurité sur toutes ces routes de recommandation

@app.get("/recommendations/{steam_id}")
def get_recommendations_from_steamid(
    steam_id: str, 
    limit: int = Query(10, ge=1, le=50),
    api_key: str = Security(get_api_key) # Protection active
):
    """
     **1. Recommandation via SteamID** (Sécurisé)
    
    Récupère la bibliothèque Steam publique de l'utilisateur et génère des recommandations.
    Nécessite le header `X-API-Key`.
    """
    try:
        recommendations = reco_service.recommend_from_steamid(steam_id, limit=limit)
        return {"steam_id": steam_id, "limit": limit, "source": "steam_api", "recommendations": recommendations}
    except Exception as e:
        return {"error": str(e)}

@app.post("/recommendations/manual")
def get_recommendations_from_manual_input(
    request: ManualRecoRequest,
    api_key: str = Security(get_api_key) # Protection active
):
    """
    **2. Recommandation Manuelle (JSON)** (Sécurisé 🔒)
    
    Permet de fournir directement une liste de jeux et d'heures de jeu.
    Nécessite le header `X-API-Key`.
    """
    try:
        # Conversion du modèle Pydantic en liste de dicts (compatible avec le service)
        games_input = [g.dict() for g in request.games]
        
        recommendations = reco_service.recommend_from_manual_input(games_input, limit=request.limit)
        
        return {
            "source": "manual_input", 
            "input_count": len(request.games), 
            "limit": request.limit, 
            "recommendations": recommendations
        }
    except Exception as e:
        return {"error": str(e)}

@app.get("/nearest_games/{query}")
def get_nearest_games(
    query: str, 
    limit: int = Query(5, ge=1, le=20),
    api_key: str = Security(get_api_key) # Protection active
):
    """
    **3. Jeux proches (Item-to-Item)** (Sécurisé 🔒)
    
    Récupère les jeux proches sémantiquement.
    Nécessite le header `X-API-Key`.
    """
    try:
        # Recherche des jeux les plus proches via le service
        nearest_games = reco_service.get_nearest_games(query, limit=limit)
        
        if not nearest_games:
             return {"query": query, "found": False, "nearest_games": []}
             
        return {
            "query": query, 
            "found": True, 
            "limit": limit, 
            "nearest_games": nearest_games
        }
    except Exception as e:
        return {"error": str(e)}
