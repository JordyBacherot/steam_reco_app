import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { Game } from '../../entities/Game'
import { HTTPException } from 'hono/http-exception'

/**
 * Supprimer un jeu
 * Route: DELETE /games/:id
 * Description: Supprime définitivement un jeu de la base de données
 */
export const deleteGame = async (c: Context) => {
  try {
    // 1. Récupération de l'ID depuis l'URL
    const id = Number(c.req.param('id'))

    // 2. Initialisation du repository
    const gameRepository = AppDataSource.getRepository(Game)

    // 3. Vérification de l'existence du jeu
    const exists = await gameRepository.findOneBy({ id_game: id })
    if (!exists) throw new HTTPException(404, { message: "Impossible de supprimer : jeu introuvable" })

    // 4. Suppression du jeu
    await gameRepository.delete({ id_game: id })

    // 5. Confirmation de suppression
    return c.json({ success: true, message: "Jeu supprimé avec succès" })
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la suppression du jeu" });
  }
}