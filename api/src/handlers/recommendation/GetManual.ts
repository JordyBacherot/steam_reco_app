import { Context } from "hono";
import { recommendationService, ManualRecoRequest } from "../../services/recommendationService";

/**
 * Handler pour les recommandations manuelles (liste de jeux json).
 * Route: POST /recommendations/manual
 * 
 * @param c - Contexte Hono
 *
 */
export const getManualRecommendations = async (c: Context) => {
  try {
    const body = await c.req.json<ManualRecoRequest>();
    
    // Validation basique (pourrait être améliorée avec Zod)
    if (!body.games || !Array.isArray(body.games)) {
        return c.json({ error: "Invalid body: 'games' array is required" }, 400);
    }

    // Appel au service
    const data = await recommendationService.getManualRecommendations(body);
    return c.json(data);
  } catch (error: any) {
    console.error("Error fetching manual recommendations:", error.message);
    if (error.response) {
       return c.json(error.response.data, error.response.status);
    }
    return c.json({ error: "Failed to fetch manual recommendations" }, 500);
  }
};
