import { Context } from "hono";
import { ChatGroq } from "@langchain/groq";
import { HumanMessage, SystemMessage, AIMessage, BaseMessage } from "@langchain/core/messages";
import { streamText } from 'hono/streaming';
import crypto from "crypto";
import { AppDataSource } from "../../database/data-source";
import { ChatbotRecommendation } from "../../entities/ChatbotRecommendation";
import { GameUser } from "../../entities/GameUser";

/**
 * Interface pour le corps de la requête Chat
 */
interface ChatRequestBody {
  message?: string; // Message optionnel si on veut juste envoyer des jeux sans message
  history: Array<{ role: 'user' | 'assistant'; content: string }>;
  temperature?: number;
  session_id?: string; // ID de la session de chat
}

/**
 * Handler pour le Streaming Chat avec LangChain & Groq
 * Route: POST /chat/stream
 */
export const streamChatHandler = async (c: Context) => {
  try {
    const body = await c.req.json<ChatRequestBody>();
    const { message, history, temperature = 0.2, session_id } = body;

    const apiKey = process.env.GROQ_API_KEY;
    if (!apiKey) {
      return c.json({ error: "GROQ_API_KEY is missing" }, 500);
    }
    
    // Check user authentication
    const userId = c.get("userId");
    if (!userId) {
      return c.json({ error: "Unauthorized" }, 401);
    }
    
    // Resolve or generate Session ID
    const sessionId = session_id || crypto.randomUUID();

    // 1. Initialisation du modèle Groq
    const model = new ChatGroq({
      apiKey: apiKey,
      model: "openai/gpt-oss-120b", // Modèle courant (remplace llama3-70b-8192 déprécié)
      temperature: temperature,
    });

    // 2. Recherche des jeux possédés par l'utilisateur en BDD
    const gamesRepo = AppDataSource.getRepository(GameUser);
    const userGamesInfos = await gamesRepo.find({
      where: { id_user: userId },
      relations: ['game']
    });

    // 3. Construction dynamique du Prompt Système
    let systemPromptContent = 
      `Tu es un expert passionné en jeux vidéo, spécialisé dans la recommandation personnalisée.
      
Ton objectif est de conseiller de nouveaux jeux à l'utilisateur en analysant sa bibliothèque actuelle et ses temps de jeu.
Essaie de comprendre ses goûts implicites (RPG, FPS, stratégie, jeux narratifs, difficulté, rythme...) à travers les jeux qu'il a poncés.\n\n`;

    if (userGamesInfos.length > 0) {
      const gamesContext = userGamesInfos
        .filter(gu => gu.game) // Sécurité si une relation est vide
        .map(gu => `- ${gu.game.name} (${gu.nb_hours} heures)`)
        .join("\n");
        
      systemPromptContent += `Voici la liste des jeux auxquels l'utilisateur a joué (Jeu : Heures jouées) :
${gamesContext}

Si l'utilisateur pose une question, réponds-y en tenant compte de ce profil. Précise-lui bien que ta recommandation est faite à partir des jeux qu'il a indiqués dans son profil.
Si l'utilisateur ne dit rien de précis, propose une analyse de ses goûts et 2-3 recommandations pertinentes.`;

    } else {
      systemPromptContent += `Cependant, je vois que l'utilisateur n'a pas encore ajouté de jeux dans sa bibliothèque.
Demande-lui simplement de te donner 2 ou 3 exemples de jeux ou de genres qu'il apprécie dans la discussion, ou invite-le à remplir son profil.
Garde un ton léger, ne lui demande pas une liste complète. Tu peux lui demander ses gouts aussi, fais lui des premières recommandations de jeux, puis pour les affiner tu peux lui demander des détails. `;
    }

    // Directives globales
    systemPromptContent += `\n\nSois convivial, précis et pertinent.

RÈGLE DE FORMATAGE TRÈS IMPORTANTE : 
Utilise UNIQUEMENT du Markdown standard pour la mise en forme (**, *, -, etc.).
N'utilise JAMAIS de balises HTML (comme <br>, <b>, <i>). Fais de vrais retours à la ligne au lieu de <br>.`;

    const systemMessage = new SystemMessage(systemPromptContent);

    // 4. Conversion de l'historique (format JSON -> format LangChain)
    const langchainHistory: BaseMessage[] = history.map((msg) => {
      if (msg.role === 'user') return new HumanMessage(msg.content);
      return new AIMessage(msg.content);
    });

    // 4. Ajout du message actuel (s'il existe)
    if (message) {
      langchainHistory.push(new HumanMessage(message));
    }

    // 5. Préparation des messages à envoyer
    const messages = [systemMessage, ...langchainHistory];

    // 6. Streaming via Hono (Texte brut)
    // On force les headers pour éviter le buffering Nginx/Navigateur
    c.header('X-Accel-Buffering', 'no'); 
    c.header('Cache-Control', 'no-cache');
    c.header('Connection', 'keep-alive');
    c.header('Content-Type', 'application/x-ndjson; charset=utf-8');

    return streamText(c, async (stream) => {
      let fullResponse = "";
      try {
        const chatStream = await model.stream(messages);

        for await (const chunk of chatStream) {
          if (chunk.content) {
            fullResponse += chunk.content;
            
            // On envoie un dictionnaire JSON à chaque morceau (NDJSON)
            const payload = JSON.stringify({
              session_id: sessionId,
              message: chunk.content
            });
            await stream.write(payload + "\n");
          }
        }
      } catch (err) {
        console.error("Chat Stream Error:", err);
        await stream.write("\n[ERROR: Stream failed]");
      } finally {
        // Sauvegarde de l'historique une fois le stream terminé
        if (userId && fullResponse.trim().length > 0) {
          try {
            const chatRepo = AppDataSource.getRepository(ChatbotRecommendation);

            // 1. Sauvegarde du message de l'utilisateur (si présent)
            if (message && message.trim().length > 0) {
              const userEntry = new ChatbotRecommendation();
              userEntry.id_user = userId;
              userEntry.session_id = sessionId;
              userEntry.response = message;
              userEntry.role = "user"; // On précise le rôle
              await chatRepo.save(userEntry);
            }

            // 2. Sauvegarde de la réponse de l'assistant
            const aiEntry = new ChatbotRecommendation();
            aiEntry.id_user = userId;
            aiEntry.session_id = sessionId;
            aiEntry.response = fullResponse;
            aiEntry.role = "assistant"; // On précise le rôle
            await chatRepo.save(aiEntry);

            console.log(`[DB] Saved User prompt and AI Response for session ${sessionId}`);
          } catch (dbError) {
            console.error("Failed to save Chatbot history:", dbError);
          }

        }
      }
    });

  } catch (error) {
    console.error("Handler Error:", error);
    return c.json({ error: "Internal Server Error" }, 500);
  }
};
