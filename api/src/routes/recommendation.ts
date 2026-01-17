import { Hono } from "hono";
import { getRecommendationsBySteamId } from "../handlers/recommendation/GetBySteamId";
import { getManualRecommendations } from "../handlers/recommendation/GetManual";
import { getNearestGames } from "../handlers/recommendation/GetNearest";
import { authMiddleware } from "../middlewares/auth";

/**
 * Routeur Hono pour les fonctionnalités de Recommandation.
 * Monté sur /recommendations
 */
const recommendationRoutes = new Hono();

// Routes définies :
recommendationRoutes.get("/:steamId", authMiddleware, getRecommendationsBySteamId);
recommendationRoutes.post("/manual", authMiddleware, getManualRecommendations);
recommendationRoutes.get("/nearest_games/:query", authMiddleware, getNearestGames);

export default recommendationRoutes;
