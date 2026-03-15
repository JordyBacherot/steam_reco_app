import { Context } from "hono";
import { AppDataSource } from "../../database/data-source";
import { ChatbotRecommendation } from "../../entities/ChatbotRecommendation";

/**
 * Handler pour récupérer l'historique des requêtes Chatbot de l'utilisateur.
 * Retourne les X (limit) dernières conversations entières (regroupées par session_id).
 * Route: GET /recommendations/history/chat
 * 
 * @param c - Contexte Hono
 * @returns JSON avec la liste des conversations complètes (les messages à l'intérieur sont triés du plus ancien au plus récent)
 */
export const getChatHistory = async (c: Context) => {
  try {
    const userId = c.get("userId");
    
    if (!userId) {
      return c.json({ error: "Unauthorized" }, 401);
    }

    const limitParam = c.req.query("limit");
    const limit = limitParam ? parseInt(limitParam) : 1;

    const chatRepo = AppDataSource.getRepository(ChatbotRecommendation);

    // 1. Trouver les X derniers "session_id" distincts
    const recentSessionsQuery = await chatRepo
      .createQueryBuilder("chat")
      .select("chat.session_id", "session_id")
      .addSelect("MAX(chat.created_at)", "max_date")
      .where("chat.id_user = :userId", { userId })
      .andWhere("chat.session_id IS NOT NULL")
      .groupBy("chat.session_id")
      .orderBy("max_date", "DESC")
      .limit(limit)
      .getRawMany();

    const sessionIds = recentSessionsQuery.map((s) => s.session_id);

    if (sessionIds.length === 0) {
      return c.json({
        history_chat: [],
        count: 0,
        limit: limit
      });
    }

    // 2. Récupérer TOUS les messages (User + Assistant) pour ces sessions
    const messages = await chatRepo
      .createQueryBuilder("chat")
      // On s'assure de sélectionner le champ 'role' (automatique avec getMany si défini dans l'entité)
      .where("chat.session_id IN (:...sessionIds)", { sessionIds })
      .orderBy("chat.created_at", "ASC") 
      .getMany();

    // 3. Regrouper par session
    const groupedBySession: Record<string, any[]> = {};
    
    for (const msg of messages) {
      if (msg.session_id) {
        if (!groupedBySession[msg.session_id]) {
          groupedBySession[msg.session_id] = [];
        }
        
        // On construit un objet propre pour le front
        groupedBySession[msg.session_id].push({
          id: msg.id_chatbot_reco,
          role: msg.role, // "user" ou "assistant"
          content: msg.response,
          created_at: msg.created_at
        });
      }
    }

    // Mise en forme finale
    const conversationsArray = Object.keys(groupedBySession).map(sessionId => ({
      session_id: sessionId,
      messages: groupedBySession[sessionId]
    }));

    // Tri final des conversations par date du dernier message
    conversationsArray.sort((a, b) => {
      const lastA = new Date(a.messages[a.messages.length - 1].created_at).getTime();
      const lastB = new Date(b.messages[b.messages.length - 1].created_at).getTime();
      return lastB - lastA;
    });

    return c.json({
      history_chat: conversationsArray,
      count: conversationsArray.length,
      limit: limit
    });

  } catch (error: any) {
    console.error("Error fetching Chatbot history:", error.message);
    return c.json({ error: "Failed to fetch Chatbot history" }, 500);
  }
};