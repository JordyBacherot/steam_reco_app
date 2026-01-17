import os
import pickle
import numpy as np
import pandas as pd
import implicit
import requests
from scipy.sparse import csr_matrix
from typing import List, Dict, Tuple, Optional, Union, Union

class RecoService:
    """
    Service de Recommandation.
    Gère le chargement du modèle ALS, des mappings et de la base de données des jeux.
    Effectue l'inférence pour recommander des jeux à partir d'un SteamID.
    """
    def __init__(self):
        # Chemins des fichiers
        base_path = os.path.dirname(os.path.abspath(__file__))
        self.model_path = os.path.join(base_path, "models", "als_model.npz")     # Le modèle entraîné
        self.mappings_path = os.path.join(base_path, "models", "mappings.pkl")   # Les dictionnaires de conversion ID <-> Index
        self.games_path = os.path.join(base_path, "data", "games_df.csv")        # Les métadonnées des jeux (noms, etc.)
        
        # Initialisation des données (chargées plus tard via load_resources)
        self.model: Optional[implicit.cpu.als.AlternatingLeastSquares] = None
        self.user2idx: Dict = {}
        self.item2idx: Dict = {}
        self.idx2item: Dict = {}
        self.games_df: Optional[pd.DataFrame] = None
        self.steam_api_key = os.getenv("STEAM_API_KEY")

    def load_resources(self):
        """
        Charge les ressources nécessaires au fonctionnement du service :
        1. Le modèle ALS pré-entraîné (.npz)
        2. Les mappings ID Steam <-> Index Matrice (.pkl)
        3. Le DataFrame des jeux (.csv) pour récupérer les noms
        """
        print("Chargement des ressources en cours...")
        
        # --- 1. Chargement du Modèle ---
        # On utilise la méthode load d'implicit pour récupérer le modèle sauvegardé
        self.model = implicit.cpu.als.AlternatingLeastSquares.load(self.model_path)
        
        # --- 2. Chargement des Mappings ---
        # Ces mappings sont cruciaux pour faire correspondre les AppIDs de Steam
        # aux indices (lignes/colonnes) de la matrice utilisateur/item du modèle.
        with open(self.mappings_path, "rb") as f:
            mappings = pickle.load(f)
            self.item2idx = mappings["item_map"]
            # Création du mapping inverse (Index -> AppID) pour récupérer les IDs après inférence
            self.idx2item = {v: k for k, v in self.item2idx.items()}

        # --- 3. Chargement des Données de Jeux ---
        # Utilisé pour afficher le nom des jeux recommandés
        self.games_df = pd.read_csv(self.games_path)
        
        # Normalisation du nom de la colonne pour éviter les erreurs
        if "name_x" in self.games_df.columns:
            self.games_df = self.games_df.rename(columns={"name_x": "name"})
        
        print("Ressources chargées avec succès.")

    def get_steam_library(self, steam_id: str) -> List[Dict]:
        """
        Récupère la liste des jeux possédés par un utilisateur via l'API Steam officielle.
        Nécessite une API KEY valide dans les variables d'environnement.
        """
        if not self.steam_api_key:
            raise ValueError("Erreur Configuration: STEAM_API_KEY manquante.")
            
        url = f"https://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key={self.steam_api_key}&steamid={steam_id}&include_appinfo=1&include_played_free_games=1&format=json"
        
        try:
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            # Vérification de la structure de réponse Steam
            if "response" not in data or "games" not in data["response"]:
                return []
                
            return data["response"]["games"]
        except Exception as e:
            print(f"Erreur lors de la requête Steam : {e}")
            return []

    def recommend_from_manual_input(self, games_input: List[Dict], limit: int = 10) -> List[Dict]:
        """
        Génère des recommandations à partir d'une liste manuelle de jeux et d'heures de jeu.
        
        Args:
            games_input: Liste de dicts [{"game_id": 10, "hours": 50.5}, ...]
            limit: Nombre de recommandations
        """
        # Normalisation de l'entrée pour correspondre au format attendu par _compute_recommendations
        # Le modèle a été entraîné sur des minutes (Steam API), donc on convertit les heures en minutes.
        normalized_games = []
        for g in games_input:
            try:
                # Utilisation des clés du modèle Pydantic (game_id, hours)
                # Mais on doit être flexible si c'est un dict brut
                appid = int(g.get("game_id"))
                hours = float(g.get("hours", 0))
                
                # Vérification que le jeu est bien connu (Mappé)
                if appid in self.item2idx:
                    normalized_games.append({
                        "appid": appid,
                        "playtime_forever": hours * 60  # Conversion Heures -> Minutes
                    })
            except (ValueError, TypeError):
                continue # On ignore les entrées mal formées

        return self._compute_recommendations(normalized_games, limit)

    def recommend_from_steamid(self, steam_id: str, limit: int = 10) -> List[Dict]:
        """
        Génère des recommandations à partir d'un SteamID (via API Steam).
        """
        if self.model is None:
            self.load_resources()

        # Étape 1 : Récupération Bibliothèque Steam
        games = self.get_steam_library(steam_id)
        if not games:
            print(f"Aucun jeu trouvé pour le SteamID {steam_id}")
            return []

        # Les données Steam sont déjà en minutes ("playtime_forever") et contiennent "appid"
        return self._compute_recommendations(games, limit)

    def _compute_recommendations(self, games: List[Dict], limit: int) -> List[Dict]:
        """
        Cœur de l'algorithme de recommandation (Agnostique de la source de données).
        Prend en entrée une liste de dicts {"appid": int, "playtime_forever": float (minutes)}.
        """
        if self.model is None:
            self.load_resources()
            
        # --- Filtrage et Préparation ---
        
        # On ne garde que les jeux que notre modèle connaît
        known_games = [g for g in games if g["appid"] in self.item2idx]
        
        # On garde une liste de tous les jeux possédés pour ne pas les recommander
        owned_appids = {g["appid"] for g in games}
        
        if not known_games:
            return []

        # --- Construction du Vecteur Utilisateur ---
        
        # Création d'un vecteur sparse (creux) de dimension (1, n_items)
        user_vector = np.zeros(len(self.item2idx), dtype=np.float32)
        
        for g in known_games:
            appid = g["appid"]
            idx = self.item2idx[appid]
            pt = g["playtime_forever"] # En minutes
            # Transformation Log(1 + playtime)
            user_vector[idx] = np.log1p(pt)

        user_vector_csr = csr_matrix(user_vector)

        # --- Inférence (Calcul des scores) ---
        
        ids, scores = self.model.recommend(
            userid=0, # UserID 0 car on fournit un user_items vector personnalisé
            user_items=user_vector_csr,
            N=limit + len(games), 
            filter_already_liked_items=True,
            recalculate_user=True
        )

        # --- Formatage et Filtrage ---
        
        results = []
        for idx, score in zip(ids, scores):
            if len(results) >= limit:
                break
                
            app_id = self.idx2item.get(idx)
            
            # Filtrage strict : Si l'utilisateur possède déjà ce jeu on ne le recommande pas
            if app_id and int(app_id) in owned_appids:
                continue
                
            if app_id:
                # Récupération des métadonnées (Nom du jeu)
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

    def _get_appid_from_name(self, name_query: str) -> Optional[int]:
        """
        Cherche un AppID à partir d'un nom (recherche insensible à la casse).
        Retourne le premier résultat trouvé contenant la chaîne.
        """
        if self.games_df is None:
            return None
            
        # Recherche insensible à la casse
        # On convertit la colonne name en string pour éviter les erreurs si NaN
        mask = self.games_df["name"].astype(str).str.contains(name_query, case=False, na=False)
        matches = self.games_df[mask]
        
        if not matches.empty:
            # On retourne le premier match
            # Idéalement on pourrait retourner une liste de candidats, mais ici on simplifie
            found_game = matches.iloc[0]
            print(f"Jeu trouvé pour '{name_query}': {found_game['name']} (ID: {found_game['appid']})")
            return int(found_game["appid"])
            
        return None

    def get_nearest_games(self, game_input: Union[int, str], limit: int = 5) -> List[Dict]:
        """
        Récupère les jeux les plus proches (Item-Item) selon le modèle.
        Accepte soit un AppID (int) soit un Nom de jeu (str).
        """
        if self.model is None:
            self.load_resources()

        game_id = None

        # 1. Résolution de l'ID
        if isinstance(game_input, int):
            game_id = game_input
        elif isinstance(game_input, str):
            # Si c'est une string qui contient un nombre, on tente le cast
            if game_input.isdigit():
                 game_id = int(game_input)
            else:
                 # Sinon recherche par nom
                 game_id = self._get_appid_from_name(game_input)
        
        if game_id is None:
            # Pas trouvé le jeu par nom
            print(f"Jeu introuvable pour l'entrée : {game_input}")
            return []

        # 2. Conversion AppID -> Matrix Index
        if game_id not in self.item2idx:
            # Le jeu existe (peut-être) mais n'est pas connu du modèle
            return []
            
        idx = self.item2idx[game_id]
        
        # 3. Inférence (Items Proches)
        # N=limit+1 car le jeu lui-même est souvent retourné en premier (distance 0 ou score max)
        ids, scores = self.model.similar_items(idx, N=limit + 1)
        
        # 4. Formatage
        results = []
        for sim_idx, score in zip(ids, scores):
            if len(results) >= limit:
                break
                
            sim_app_id = self.idx2item.get(sim_idx)
            
            # On ignore le jeu lui-même
            if sim_app_id == game_id:
                continue
                
            if sim_app_id:
                # Métadonnées
                game_info = self.games_df[self.games_df["appid"] == sim_app_id]
                name = "Unknown"
                if not game_info.empty:
                    name = game_info.iloc[0]["name"]
                    
                results.append({
                    "appid": int(sim_app_id),
                    "name": name,
                    "score": float(score)
                })
        
        return results
