import { Context } from "hono";
import { recommendationService } from "../../services/recommendationService";

/**
 * Handler pour récupérer des recommandations basées sur un SteamID.
 * 
 * Route: GET /recommendations/steam/:steamId
 * 
 * @param c - Contexte Hono
 * @returns JSON avec les recommandations
 */
export const getRecommendationsBySteamId = async (c: Context) => {
  const steamId = c.req.param("steamId");
  const limit = c.req.query("limit") ? parseInt(c.req.query("limit")!) : 10;

  try {
    // Appel au service qui contacte l'API Python
    const data = await recommendationService.getRecommendationsBySteamId(steamId, limit);
    return c.json(data);
  } catch (error: any) {
    console.error("Error fetching recommendations by SteamID:", error.message);
    // On propage l'erreur/status de l'API Python si possible
    if (error.response) {
       return c.json(error.response.data, error.response.status);
    }
    return c.json({ error: "Failed to fetch recommendations" }, 500);
  }
};
