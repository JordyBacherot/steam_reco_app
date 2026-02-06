import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { Game } from '../../entities/Game'

// Ajouter un jeu
/**
 * Créer un nouveau jeu
 * Route: POST /games
 * Description: Ajoute un nouveau jeu dans la base de données après validation
 */
export const createGame = async (c: Context) => {
  try {
    // 1. Récupération des données du corps de la requête (JSON)
    const data = await c.req.json()

    // 2. Initialisation du repository Game
    const gameRepository = AppDataSource.getRepository(Game)

    // 3. Création de l'instance du jeu
    const newGame = await gameRepository.create(data);

    // 4. Sauvegarde en base de données
    const result = await gameRepository.save(newGame);

    // 5. Retour de la réponse réussie (201 Created)
    return c.json(result, 201);
  } catch (e) {
    return c.json({ message: "Erreur de création" }, 400);
  }
}