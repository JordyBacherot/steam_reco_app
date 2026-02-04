import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { Game } from '../../entities/Game'
import { HTTPException } from 'hono/http-exception'

export const deleteGame = async (c: Context) => {
  try {
    const id = Number(c.req.param('id'))

    const gameRepository = AppDataSource.getRepository(Game)
    const exists = await gameRepository.findOneBy({ id_game: id })
    if (!exists) throw new HTTPException(404, { message: "Impossible de supprimer : jeu introuvable" })

    await gameRepository.delete({ id_game: id })
    return c.json({ success: true, message: "Jeu supprimé avec succès" })
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la suppression du jeu" });
  }
}