import { Context } from "hono";
import { recommendationService } from "../../services/recommendationService";
import { AppDataSource } from "../../database/data-source";
import { NearGame } from "../../entities/NearGame";
import { Game } from "../../entities/Game";

/**
 * Handler pour trouver les jeux les plus proches (similarité).
 * Route: GET /recommendations/nearest_games/:query
 * 
 * @param c - Contexte Hono
 */
export const getNearestGames = async (c: Context) => {
  const query = c.req.param("query"); // Considéré comme l'ID du jeu de base dans notre flux
  const limit = c.req.query("limit") ? parseInt(c.req.query("limit")!) : 5;

  try {
    const gameId = parseInt(query);
    const nearGameRepo = AppDataSource.getRepository(NearGame);
    const gameRepo = AppDataSource.getRepository(Game);

    // --- 1. VÉRIFICATION DU CACHE BDD ---
    if (!isNaN(gameId)) {
      // Chercher si les recos pour ce jeu existent déjà en base
      const cachedRelations = await nearGameRepo.find({
        where: { id_game: gameId },
        relations: ["nearGame"],
        take: limit
      });

      if (cachedRelations.length > 0) {
        console.log(`Returning ${cachedRelations.length} NearestGames for appid ${gameId}`);
        // Reformatter pour coller au format de sortie retourné par Python
        const results = cachedRelations.map(rel => ({
          appid: rel.id_near_game,
          name: rel.nearGame?.name || "Unknown",
          score: rel.score || 0.0  
        }));
        
        return c.json({
          query: query,
          found: true,
          limit: limit,
          nearest_games: results,
          source: "local_cache"
        });
      }
    }

    // --- 2. APPEL À L'API PYTHON FASTAPI ---
    console.log(`[Cache Miss] Fetching NearestGames from Python for query: ${query}`);
    const data = await recommendationService.getNearestGames(query, limit);

    // --- 3. SAUVEGARDE EN BDD SI TROUVÉ ---
    if (data.found && data.nearest_games && Array.isArray(data.nearest_games) && !isNaN(gameId)) {
      try {
        const recommendedGameIds = data.nearest_games.map((r: any) => r.appid);
        
        // Vérifier quels jeux recommandés existent vraiment dans notre BDD
        let existingGames: Game[] = [];
        if (recommendedGameIds.length > 0) {
          existingGames = await gameRepo.createQueryBuilder("game")
            .where("game.id_game IN (:...ids)", { ids: recommendedGameIds })
            .getMany();
        }
        
        const existingGameIds = new Set(existingGames.map(g => g.id_game));
        const newRelations: NearGame[] = [];
        
        for (const reco of data.nearest_games) {
          // On s'assure que le jeu de base (gameId) ET le jeu recommandé (appid) existent
          // Dans l'absolu on devrait aussi vérifier pour id_game, mais on assume qu'il vient de la blibliothèque.
          if (existingGameIds.has(reco.appid)) {
            const rel = new NearGame();
            rel.id_game = gameId;
            rel.id_near_game = reco.appid;
            rel.score = reco.score || 0.0;
            newRelations.push(rel);
          }
        }
        
        if (newRelations.length > 0) {
          await nearGameRepo.save(newRelations);
          console.log(`[DB] Saved ${newRelations.length} NearGames for origin appid ${gameId}`);
        }
      } catch (dbError) {
        console.error("Échec de la sauvegarde des NearestGames en BDD:", dbError);
      }
    }

    return c.json(data);
  } catch (error: any) {
    console.error("Error fetching nearest games:", error.message);
    if (error.response) {
       return c.json(error.response.data, error.response.status);
    }
    return c.json({ error: "Failed to fetch nearest games" }, 500);
  }
};
