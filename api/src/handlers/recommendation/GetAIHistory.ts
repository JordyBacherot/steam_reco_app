import { Context } from "hono";
import { AppDataSource } from "../../database/data-source";
import { AIRecommendation } from "../../entities/AIRecommendation";

/**
 * Handler pour récupérer l'historique des recommandations IA de l'utilisateur.
 * Route: GET /recommendations/history/ai
 * 
 * @param c - Contexte Hono
 * @returns JSON avec la liste des recommandations et des détails du jeu
 */
export const getAIHistory = async (c: Context) => {
  try {
    const userId = c.get("userId");
    
    // Si l'utilisateur n'est pas authentifié via le middleware, renvoyer une erreur 401
    // (Normalement géré par authMiddleware, mais c'est une sécurité supplémentaire)
    if (!userId) {
      return c.json({ error: "Unauthorized" }, 401);
    }

    // Récupérer la limite demandée, par défaut 10
    const limitParam = c.req.query("limit");
    const limit = limitParam ? parseInt(limitParam) : 10;

    const recoRepo = AppDataSource.getRepository(AIRecommendation);

    // Requête TypeORM pour récupérer l'historique de CES utilisateurs spécifiques
    // Triés par date de création descendante (du plus récent au plus ancien)
    const history = await recoRepo.find({
      where: { id_user: userId },
      relations: ["game"], // Permet de récupérer game.name, game.image_url, etc.
      order: {
        created_at: "DESC"
      },
      take: limit
    });

    return c.json({
      history_ai: history,
      count: history.length,
      limit: limit
    });

  } catch (error: any) {
    console.error("Error fetching AI recommendation history:", error.message);
    return c.json({ error: "Failed to fetch AI history" }, 500);
  }
};
