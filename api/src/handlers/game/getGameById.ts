import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { Game } from '../../entities/Game'
import { HTTPException } from 'hono/http-exception'


export const getGameById = async (c: Context) => {
  try {
    const id = Number(c.req.param('id'))
    const gameRepository = AppDataSource.getRepository(Game)

    const game = await gameRepository.find({ where: { id_game: id } })

    if (!game) throw new HTTPException(404, { message: "Jeu non trouvé" })

    return c.json({ success: true, data: game })
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la récupération du jeu" });
  }
}