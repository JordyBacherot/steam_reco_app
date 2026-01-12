import os
import pickle
import numpy as np
import pandas as pd
import implicit
import requests
from scipy.sparse import csr_matrix
from typing import List, Dict, Tuple, Optional

class RecoService:
    def __init__(self):
        # Paths
        base_path = os.path.dirname(os.path.abspath(__file__))
        self.model_path = os.path.join(base_path, "models", "als_model.npz")
        self.mappings_path = os.path.join(base_path, "models", "mappings.pkl") # Mappings seems to be in models based on previous list_dir
        self.games_path = os.path.join(base_path, "data", "games_df.csv")
        
        # Data
        self.model: Optional[implicit.cpu.als.AlternatingLeastSquares] = None
        self.user2idx: Dict = {}
        self.item2idx: Dict = {}
        self.idx2item: Dict = {}
        self.games_df: Optional[pd.DataFrame] = None
        self.steam_api_key = os.getenv("STEAM_API_KEY")

    def load_resources(self):
        """Loads model, mappings and game data."""
        print("Loading resources...")
        
        # Load Model
        # implicit.load uses the path directly
        # Note: implicit might load as a different class depending on version/saving method
        # Using load from implicit.cpu.als or similar if it was saved that way, 
        # but safely we can try to use specific load or generic.
        # Given the file is .npz, it might be saved with model.save()
        self.model = implicit.cpu.als.AlternatingLeastSquares.load(self.model_path)
        
        # Load Mappings
        # Based on notebook: user2idx, item2idx, idx2items
        # Previous list_dir of api/mappings failed, but list_dir api/models showed mappings.pkl? 
        # WAIT: list_dir api/models showed 'als_model.npz' and 'mappings.pkl'. 
        
        with open(self.mappings_path, "rb") as f:
            mappings = pickle.load(f)
            # Assuming mappings is a dict with keys 'user2idx', 'item2idx'
            # Adjust if structure is different. 
            # In notebook: user2idx = {u: i ...}, item2idx = {a: i ...}
            # The saved pickle likely contains this dictionary.
            self.item2idx = mappings["item_map"]
            # We construct reverse mapping if not present
            self.idx2item = {v: k for k, v in self.item2idx.items()}

        # Load Games Data
        # We need appid and name
        self.games_df = pd.read_csv(self.games_path)
        # Ensure name column is consistent
        if "name_x" in self.games_df.columns:
            self.games_df = self.games_df.rename(columns={"name_x": "name"})
        
        print("Resources loaded successfully.")

    def get_steam_library(self, steam_id: str) -> List[Dict]:
        """Fetches user's owned games from Steam API."""
        if not self.steam_api_key:
            raise ValueError("STEAM_API_KEY is not set.")
            
        url = f"https://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key={self.steam_api_key}&steamid={steam_id}&include_appinfo=1&include_played_free_games=1&format=json"
        
        try:
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            if "response" not in data or "games" not in data["response"]:
                return []
                
            return data["response"]["games"]
        except Exception as e:
            print(f"Error fetching Steam data: {e}")
            return []

    def recommend(self, steam_id: str, limit: int = 10) -> List[Dict]:
        """
        Main method to get recommendations.
        1. Fetch Steam library
        2. Construct user vector
        3. Run inference
        4. Format response
        """
        if self.model is None:
            self.load_resources()

        # 1. Fetch Library
        games = self.get_steam_library(steam_id)
        if not games:
            print(f"No games found for steam_id {steam_id}")
            # Fallback or empty return? 
            # If no games, we can't recommend based on behaviour easily without cold start handling.
            # Returning empty list for now.
            return []

        # 2. Construct User Vector
        # Filter games known by the model
        known_games = [g for g in games if g["appid"] in self.item2idx]
        
        # Keep track of ALL owned appids for filtering
        owned_appids = {g["appid"] for g in games}
        
        if not known_games:
            return []

        # Build sparse matrix (1 x n_items)
        user_vector = np.zeros(len(self.item2idx), dtype=np.float32)
        
        for g in known_games:
            appid = g["appid"]
            idx = self.item2idx[appid]
            pt = g["playtime_forever"]
            user_vector[idx] = np.log1p(pt)

        user_vector_csr = csr_matrix(user_vector)

        # 3. Inference
        # Request more than limit to allow manual filtering
        ids, scores = self.model.recommend(
            userid=0, 
            user_items=user_vector_csr,
            N=limit + len(games), # Request extra to ensure we have enough after filtering
            filter_already_liked_items=True,
            recalculate_user=True
        )

        # 4. Format Response
        results = []
        for idx, score in zip(ids, scores):
            if len(results) >= limit:
                break
                
            app_id = self.idx2item.get(idx)
            
            # Explicit filtering: Ensure game is not in owned_appids
            # Cast to int to strictly match owned_appids (which are ints from Steam)
            if app_id and int(app_id) in owned_appids:
                continue
                
            if app_id:
                # Find game metadata
                game_info = self.games_df[self.games_df["appid"] == app_id]
                name = "Unknown"
                if not game_info.empty:
                    name = game_info.iloc[0]["name"]
                
                results.append({
                    "appid": int(app_id),
                    "name": name,
                    "score": float(score)
                })
        
        return results
