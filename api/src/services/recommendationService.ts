import axios from "axios";

const RECO_API_URL = process.env.RECO_API_URL || "http://api_recommendation:8000";
const API_KEY = process.env.API_KEY_RECOMMENDATION;

if (!API_KEY) {
  console.warn("⚠️ API_KEY_RECOMMENDATION is not set! Recommendation calls will fail.");
}

const recoClient = axios.create({
  baseURL: RECO_API_URL,
  headers: {
    "Content-Type": "application/json",
    "X-API-Key": API_KEY,
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

export const recommendationService = {
  async getRecommendationsBySteamId(steamId: string, limit: number = 10) {
    const response = await recoClient.get(`/recommendations/${steamId}`, {
      params: { limit },
    });
    return response.data;
  },

  async getManualRecommendations(data: ManualRecoRequest) {
    const response = await recoClient.post("/recommendations/manual", data);
    return response.data;
  },

  async getNearestGames(query: string, limit: number = 5) {
    const response = await recoClient.get(`/nearest_games/${query}`, {
      params: { limit },
    });
    return response.data;
  },
};
