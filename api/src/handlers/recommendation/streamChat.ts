import { Context } from "hono";
import { ChatGroq } from "@langchain/groq";
import { HumanMessage, SystemMessage, AIMessage, BaseMessage } from "@langchain/core/messages";
import { streamText } from 'hono/streaming';

/**
 * Interface pour le corps de la requête Chat
 */
interface ChatRequestBody {
  message?: string; // Message optionnel si on veut juste envoyer des jeux sans message
  history: Array<{ role: 'user' | 'assistant'; content: string }>;
  gamesList: Array<{ name: string; hours: number }>; // Liste des jeux joués
  temperature?: number;
}

/**
 * Handler pour le Streaming Chat avec LangChain & Groq
 * Route: POST /chat/stream
 */
export const streamChatHandler = async (c: Context) => {
  try {
    const body = await c.req.json<ChatRequestBody>();
    const { message, history, gamesList, temperature = 0.2 } = body;

    const apiKey = process.env.GROQ_API_KEY;
    if (!apiKey) {
      return c.json({ error: "GROQ_API_KEY is missing" }, 500);
    }

    // 1. Initialisation du modèle Groq
    const model = new ChatGroq({
      apiKey: apiKey,
      model: "openai/gpt-oss-120b", // Modèle courant (remplace llama3-70b-8192 déprécié)
      temperature: temperature,
    });

    // 2. Construction du Prompt Système
    // On met en forme la liste des jeux pour que le LLM puisse l'analyser
    const gamesContext = gamesList
      .map(g => `- ${g.name} (${g.hours} heures)`)
      .join("\n");

    const systemPromptContent = 
      `Tu es un expert passionné en jeux vidéo, spécialisé dans la recommandation personnalisée.
      
      Ton objectif est de conseiller de nouveaux jeux à l'utilisateur en analysant sa bibliothèque actuelle et ses temps de jeu.
      Essaie de comprendre ses goûts implicites (RPG, FPS, stratégie, jeux narratifs, difficulté, rythme...) à travers les jeux qu'il a poncés.
      
      Voici la liste des jeux auxquels l'utilisateur a joué (Jeu : Heures jouées) :
      ${gamesContext}
      
      Si l'utilisateur pose une question, réponds-y en tenant compte de ce profil.
      Si l'utilisateur ne dit rien de précis, propose une analyse de ses goûts et 2-3 recommandations pertinentes.
      Sois convivial, précis et pertinent.
      
      RÈGLE DE FORMATAGE TRÈS IMPORTANTE : 
      Utilise UNIQUEMENT du Markdown standard pour la mise en forme (**, *, -, etc.).
      N'utilise JAMAIS de balises HTML (comme <br>, <b>, <i>). Fais de vrais retours à la ligne au lieu de <br>.`;

    const systemMessage = new SystemMessage(systemPromptContent);

    // 3. Conversion de l'historique (format JSON -> format LangChain)
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
    c.header('Content-Type', 'text/plain; charset=utf-8');

    return streamText(c, async (stream) => {
      try {
        const chatStream = await model.stream(messages);

        for await (const chunk of chatStream) {
          if (chunk.content) {
            await stream.write(chunk.content as string);
          }
        }
      } catch (err) {
        console.error("Chat Stream Error:", err);
        await stream.write("\n[ERROR: Stream failed]");
      }
    });

  } catch (error) {
    console.error("Handler Error:", error);
    return c.json({ error: "Internal Server Error" }, 500);
  }
};
