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
    
    // Si l'utilisateur n'est pas authentifié via le middleware, renvoyer une erreur 401
    if (!userId) {
      return c.json({ error: "Unauthorized" }, 401);
    }

    // Récupérer la limite de "conversations" demandée, par défaut 1
    const limitParam = c.req.query("limit");
    const limit = limitParam ? parseInt(limitParam) : 1;

    const chatRepo = AppDataSource.getRepository(ChatbotRecommendation);

    // 1. Trouver les X derniers "session_id" distincts triés par la date la plus récente
    // On utilise le QueryBuilder car TypeORM ne permet pas de faire facilement un GROUP BY avec un ORDER BY MAX() direct avec le formalisme `.find()`
    const recentSessionsQuery = await chatRepo
      .createQueryBuilder("chat")
      .select("chat.session_id", "session_id")
      .addSelect("MAX(chat.created_at)", "max_date")
      .where("chat.id_user = :userId", { userId })
      .andWhere("chat.session_id IS NOT NULL") // S'assurer qu'on ne prend que des conversations avec session
      .groupBy("chat.session_id")
      .orderBy("max_date", "DESC")
      .limit(limit)
      .getRawMany();

    const sessionIds = recentSessionsQuery.map((s) => s.session_id);

    // Si aucune session n'est trouvée pour cet utilisateur, on renvoie un tableau vide
    if (sessionIds.length === 0) {
      return c.json({
        history_chat: [],
        count: 0,
        limit: limit
      });
    }

    // 2. Récupérer TOUS les messages appartenant à ces sessions
    // On les trie par 'created_at' ASC afin de restituer le sens de la discussion
    const messages = await chatRepo
      .createQueryBuilder("chat")
      .leftJoinAndSelect("chat.user", "user") // Si vous avez besoin de peupler la relation
      .where("chat.session_id IN (:...sessionIds)", { sessionIds })
      .orderBy("chat.created_at", "ASC")
      .getMany();

    // 3. Regrouper les messages par session pour faciliter la lecture côté client
    // Résultat : { "session-id-1": [ message1, message2... ], "session-id-2": [ ... ] }
    const groupedBySession: Record<string, ChatbotRecommendation[]> = {};
    for (const msg of messages) {
      if (msg.session_id) {
        if (!groupedBySession[msg.session_id]) {
          groupedBySession[msg.session_id] = [];
        }
        groupedBySession[msg.session_id].push(msg);
      }
    }

    // Transforme l'objet en un tableau de conversations plus facile à itérer
    const conversationsArray = Object.keys(groupedBySession).map(sessionId => ({
      session_id: sessionId,
      messages: groupedBySession[sessionId]
    }));

    // Re-trier le tableau final de conversations de la plus récente à la plus ancienne
    conversationsArray.sort((a, b) => {
      const lastMsgA = a.messages[a.messages.length - 1];
      const lastMsgB = b.messages[b.messages.length - 1];
      return lastMsgB.created_at.getTime() - lastMsgA.created_at.getTime();
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
