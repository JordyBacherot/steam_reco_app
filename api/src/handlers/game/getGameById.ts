import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { Game } from '../../entities/Game'
import { HTTPException } from 'hono/http-exception'


/**
 * Récupérer un jeu par son ID
 * Route: GET /games/:id
 * Description: Renvoie les détails d'un jeu spécifique
 */
export const getGameById = async (c: Context) => {
  try {
    // 1. Récupération de l'ID depuis les paramètres d'URL
    const id = Number(c.req.param('id'))
    const gameRepository = AppDataSource.getRepository(Game)

    // 2. Recherche du jeu en base de données
    const game = await gameRepository.findOneBy({ id_game: id })

    // 3. Gestion du cas "Non trouvé"
    if (!game) throw new HTTPException(404, { message: "Jeu non trouvé" })

    // 4. Retour du jeu trouvé
    return c.json({ success: true, data: game })
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la récupération du jeu" });
  }
}