import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { Game } from '../../entities/Game'
import { HTTPException } from 'hono/http-exception'

export const updateGame = async (c: Context) => {
  try {
    const id = Number(c.req.param('id'))
    const data = await c.req.json()

    if (isNaN(id)) return c.json({ message: "ID invalide" }, 400);

    const gameRepository = AppDataSource.getRepository(Game)
    // On vérifie d'abord s'il existe
    const exists = await gameRepository.findOneBy({ id_game: id })
    if (!exists) throw new HTTPException(404, { message: "Impossible de modifier : jeu introuvable" })

    await gameRepository.update(
      { id_game: id },
      data)

    const updatedGame = await gameRepository.findOneBy({ id_game: id });
    return c.json({ success: true, data: updatedGame })
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la modification du jeu" });
  }
}