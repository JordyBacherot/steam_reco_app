import axios from "axios";

// Configuration de l'URL et de la Clé API depuis l'environnement
const RECO_API_URL = process.env.API_RECOMMENDATION;
const API_KEY = process.env.API_KEY_RECOMMENDATION;

if (!API_KEY) {
  console.warn("⚠️ API_KEY_RECOMMENDATION is not set! Recommendation calls will fail.");
}

// Client Axios pré-configuré avec le Header d'authentification
const recoClient = axios.create({
  baseURL: RECO_API_URL,
  headers: {
    "Content-Type": "application/json",
    "X-API-Key": API_KEY, // Injection automatique de la clé
  },
});

export interface GameItem {
  game_id: number;
  hours: number;
}

export interface ManualRecoRequest {
  games: GameItem[];
  limit?: number;
}

/**
 * Service gérant la communication avec l'API Python de Recommandation.
 */
export const recommendationService = {
  /**
   * Récupère des recommandations pour un utilisateur Steam via son ID.
   */
  async getRecommendationsBySteamId(steamId: string, limit: number = 10) {
    const response = await recoClient.get(`/recommendations/${steamId}`, {
      params: { limit },
    });
    return response.data;
  },
  
  /**
   * Envoie une liste manuelle de jeux pour obtenir des recommandations.
   */
  async getManualRecommendations(data: ManualRecoRequest) {
    const response = await recoClient.post("/recommendations/manual", data);
    return response.data;
  },

  /**
   * Cherche les jeux joués par les autres joueurs (Nearest Neighbors) à partir d'un nom ou d'un ID.
   */
  async getNearestGames(query: string, limit: number = 5) {
    const response = await recoClient.get(`/nearest_games/${query}`, {
      params: { limit },
    });
    return response.data;
  },
};
