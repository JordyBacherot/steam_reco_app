import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { Game } from '../../entities/Game'

// Lire tous les jeux
/**
 * Récupérer tous les jeux
 * Route: GET /games
 * Description: Renvoie la liste complète des jeux disponibles
 */
export const getAllGames = async (c: Context) => {
  try {
    // 1. Initialisation du repository
    const gameRepository = AppDataSource.getRepository(Game)

    // 2. Récupération de tous les enregistrements
    const games = await gameRepository.find()

    // 3. Retour des données
    return c.json({ success: true, data: games })
  } catch (e) {
    return c.json({ message: "Erreur lors de la récupération" }, 500);
  }
}