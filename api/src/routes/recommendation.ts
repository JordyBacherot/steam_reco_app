import { Hono } from "hono";
import { getRecommendationsBySteamId } from "../handlers/recommendation/GetBySteamId";
import { getManualRecommendations } from "../handlers/recommendation/GetManual";
import { getNearestGames } from "../handlers/recommendation/GetNearest";

/**
 * Routeur Hono pour les fonctionnalités de Recommandation.
 * Monté sur /recommendations (ou /api/reco selon app.ts)
 */
const recommendationRoutes = new Hono();

// Routes définies :
recommendationRoutes.get("/steam/:steamId", getRecommendationsBySteamId);
recommendationRoutes.post("/manual", getManualRecommendations);
recommendationRoutes.get("/nearest_games/:query", getNearestGames);

export default recommendationRoutes;
