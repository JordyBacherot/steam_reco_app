import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { Game } from '../../entities/Game'

// Lire tous les jeux
export const getAllGames = async (c: Context) => {
  try {
    const gameRepository = AppDataSource.getRepository(Game)
    const games = await gameRepository.find() // Exemple avec un ORM

    return c.json({ success: true, data: games })
  } catch (e) {
    return c.json({ message: "Erreur lors de la récupération" }, 500);
  }
}