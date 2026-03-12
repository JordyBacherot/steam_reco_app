import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { Game } from '../../entities/Game'
import { ILike } from 'typeorm';

/**
 * Rechercher des jeux par terme dans le nom
 * Route: GET /games/search?q=<terme>&limit=<nombre>
 * Description: Renvoie la liste des jeux dont le nom contient le terme recherché
 *              Le paramètre limit permet de limiter le nombre de résultats (défaut: 10)
 */
export const searchGames = async (c: Context) => {
  try {
    // Récupération des paramètres de requête
    const searchTerm = c.req.query('q') ?? '';
    const limitParam = c.req.query('limit');
    const limit = limitParam ? Math.max(1, parseInt(limitParam, 10)) : 10;

    // Vérification du terme de recherche
    if (!searchTerm.trim()) {
      return c.json({ message: "Le paramètre de recherche 'q' est requis" }, 400);
    }

    // Initialisation du repository
    const gameRepository = AppDataSource.getRepository(Game);

    // Recherche insensible à la casse avec ILike (PostgreSQL)
    const games = await gameRepository.find({
      where: {
        name: ILike(`%${searchTerm}%`),
      },
      take: limit,
      order: { name: 'ASC' },
    });

    // Retour des données avec métadonnées
    return c.json({
      success: true,
      query: searchTerm,
      limit,
      count: games.length,
      data: games,
    });
  } catch (e) {
    return c.json({ message: "Erreur lors de la recherche" }, 500);
  }
}
