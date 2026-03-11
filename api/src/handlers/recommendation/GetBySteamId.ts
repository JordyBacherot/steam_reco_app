import { Context } from "hono";
import { recommendationService } from "../../services/recommendationService";
import { AppDataSource } from "../../database/data-source";
import { Game } from "../../entities/Game";
import { AIRecommendation } from "../../entities/AIRecommendation";

/**
 * Handler pour récupérer des recommandations basées sur un SteamID.
 * Route: GET /recommendations/:steamId
 * 
 * @param c - Contexte Hono
 * @returns JSON avec les recommandations
 */
export const getRecommendationsBySteamId = async (c: Context) => {
  const steamId = c.req.param("steamId");
  const limit = c.req.query("limit") ? parseInt(c.req.query("limit")!) : 10;

  try {
    // Appel au service qui contacte l'API Python
    const data = await recommendationService.getRecommendationsBySteamId(steamId, limit);
    
    // --- LOGIQUE DE SAUVEGARDE EN BASE DE DONNÉES ---
    // Extraction de l'ID utilisateur depuis le contexte d'authentification
    const userId = c.get("userId");
    
    // Si l'utilisateur est authentifié et que nous avons reçu des recommandations de Python
    if (userId && data.recommendations && Array.isArray(data.recommendations)) {
      try {
        const recoRepo = AppDataSource.getRepository(AIRecommendation);
        const gameRepo = AppDataSource.getRepository(Game);
        
        // 1. Extraction de tous les identifiants de jeux suggérés
        const recommendedGameIds = data.recommendations.map((r: any) => r.appid);
        
        // 2. Requête en base de données locale pour trouver les jeux qui existent réellement
        let existingGames: Game[] = [];
        if (recommendedGameIds.length > 0) {
           existingGames = await gameRepo.createQueryBuilder("game")
             .where("game.id_game IN (:...ids)", { ids: recommendedGameIds })
             .getMany();
        }
        
        // Création d'un ensemble de recherche rapide (Set) pour les IDs de jeux existants
        const existingGameIds = new Set(existingGames.map(g => g.id_game));
        
        // 3. Préparation des nouvelles entités AIRecommendation (Historique Cumulatif)
        const newRecommendations: AIRecommendation[] = [];
        
        for (const reco of data.recommendations) {
          // Si le jeu existe dans notre base de données locale
          if (existingGameIds.has(reco.appid)) {
            const aiReco = new AIRecommendation();
            aiReco.id_user = userId;
            aiReco.id_game = reco.appid;
            aiReco.score = reco.score || 0;
            // created_at est géré automatiquement
            newRecommendations.push(aiReco);
          }
        }
        
        // 4. Sauvegarde par lots des recommandations 
        if (newRecommendations.length > 0) {
          await recoRepo.save(newRecommendations);
          console.log(`[DB] Enregistrement de ${newRecommendations.length} recommandations IA pour l'utilisateur ${userId} (SteamID: ${steamId})`);
        }
      } catch (dbError) {
        // Nous journalisons l'erreur SQL mais NOUS NE FAISONS PAS PLANTER la requête
        console.error("Échec de la sauvegarde des recommandations SteamID en BDD:", dbError);
      }
    }

    return c.json(data);
  } catch (error: any) {
    console.error("Error fetching recommendations by SteamID:", error.message);
    // On propage l'erreur/status de l'API Python si possible
    if (error.response) {
       return c.json(error.response.data, error.response.status);
    }
    return c.json({ error: "Failed to fetch recommendations" }, 500);
  }
};
