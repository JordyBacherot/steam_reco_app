import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { Game } from '../../entities/Game'
import { HTTPException } from 'hono/http-exception'

/**
 * Mettre à jour un jeu
 * Route: PUT /games/:id
 * Description: Modifie les informations d'un jeu existant
 */
export const updateGame = async (c: Context) => {
  try {
    // 1. Récupération de l'ID et des nouvelles données
    const id = Number(c.req.param('id'))
    const data = await c.req.json()

    // 2. Validation basique de l'ID
    if (isNaN(id)) return c.json({ message: "ID invalide" }, 400);

    const gameRepository = AppDataSource.getRepository(Game)

    // 3. Vérification de l'existence avant modification
    const exists = await gameRepository.findOneBy({ id_game: id })
    if (!exists) throw new HTTPException(404, { message: "Impossible de modifier : jeu introuvable" })

    // 4. Mise à jour des données
    await gameRepository.update(
      { id_game: id },
      data)

    // 5. Récupération de la version mise à jour pour confirmation
    const updatedGame = await gameRepository.findOneBy({ id_game: id });
    return c.json({ success: true, data: updatedGame })
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la modification du jeu" });
  }
}