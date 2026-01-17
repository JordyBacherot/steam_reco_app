import { Context } from "hono";
import { recommendationService } from "../../services/recommendationService";

/**
 * Handler pour trouver les jeux les plus proches (similarité).
 * Route: GET /recommendations/nearest_games/:query
 * 
 * @param c - Contexte Hono
 */
export const getNearestGames = async (c: Context) => {
  const query = c.req.param("query");
  const limit = c.req.query("limit") ? parseInt(c.req.query("limit")!) : 5;

  try {
    const data = await recommendationService.getNearestGames(query, limit);
    return c.json(data);
  } catch (error: any) {
    console.error("Error fetching nearest games:", error.message);
    if (error.response) {
       return c.json(error.response.data, error.response.status);
    }
    return c.json({ error: "Failed to fetch nearest games" }, 500);
  }
};
