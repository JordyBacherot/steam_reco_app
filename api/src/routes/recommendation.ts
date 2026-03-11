import { Hono } from "hono";
import { getRecommendationsBySteamId } from "../handlers/recommendation/GetBySteamId";
import { getManualRecommendations } from "../handlers/recommendation/GetManual";
import { getNearestGames } from "../handlers/recommendation/GetNearest";
import { streamChatHandler } from "../handlers/recommendation/streamChat";
import { getAIHistory } from "../handlers/recommendation/GetAIHistory";
import { getChatHistory } from "../handlers/recommendation/GetChatHistory";
import { authMiddleware } from "../middlewares/auth";

/**
 * Routeur Hono pour les fonctionnalités de Recommandation.
 * Monté sur /recommendations
 */
const recommendationRoutes = new Hono();

// Routes définies (Historiques priorisés pour éviter les conflits d'URL avec :steamId)
recommendationRoutes.get("/history/ai", authMiddleware, getAIHistory);
recommendationRoutes.get("/history/chat", authMiddleware, getChatHistory);

recommendationRoutes.get("/:steamId", authMiddleware, getRecommendationsBySteamId);
recommendationRoutes.post("/manual", authMiddleware, getManualRecommendations);
recommendationRoutes.post("/chat", authMiddleware, streamChatHandler);
recommendationRoutes.get("/nearest_games/:query", authMiddleware, getNearestGames);

export default recommendationRoutes;
