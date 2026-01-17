from typing import Union, List
from pydantic import BaseModel, Field

from fastapi import FastAPI, HTTPException, Query, Body
from contextlib import asynccontextmanager
from dotenv import load_dotenv

from reco_service import RecoService

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

# @asynccontextmanager permet garder les ressources chargées en mémoire
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

@app.get("/recommendations/{steam_id}")
def get_recommendations_from_steamid(steam_id: str, limit: int = Query(10, ge=1, le=50)):
    """
     **1. Recommandation via SteamID**
    
    Récupère la bibliothèque Steam publique de l'utilisateur et génère des recommandations.
    """
    try:
        recommendations = reco_service.recommend_from_steamid(steam_id, limit=limit)
        return {"steam_id": steam_id, "limit": limit, "source": "steam_api", "recommendations": recommendations}
    except Exception as e:
        return {"error": str(e)}

@app.post("/recommendations/manual")
def get_recommendations_from_manual_input(request: ManualRecoRequest):
    """
    **2. Recommandation Manuelle (JSON)**
    
    Permet de fournir directement une liste de jeux et d'heures de jeu pour 
    obtenir des recommandations sans passer par l'API Steam (ex: utilisateurs sans compte Steam public).
    
    **Format attendu:**
    ```json
    {
      "games": [
        { "game_id": 10, "hours": 100.5 },
        { "game_id": 730, "hours": 10 }
      ],
      "limit": 5
    }
    ```
    Seuls les jeux connus du modèle ("mappés") seront utilisés pour l'inférence.
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
def get_nearest_games(query: str, limit: int = Query(5, ge=1, le=20)):
    """
    **3. Jeux proches (Item-to-Item)**
    
    Récupère les jeux proches sémantiquement.
    
    **Entrée flexible (`query`) :**
    *   **ID Steam** : `72850` (Recherche exacte)
    *   **Nom** : `Skyrim` (Recherche textuelle *contient*, insensible à la casse)
    
    Si une chaîne est fournie, l'API cherchera d'abord si c'est un ID valide, sinon elle cherchera le nom du jeu dans la base.
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
