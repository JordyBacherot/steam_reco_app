import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { createGame } from '../handlers/game/createGame'
import { updateGame } from '../handlers/game/updateGame'
import { getAllGames } from '../handlers/game/getAllGame'
import { getGameById } from '../handlers/game/getGameById'
import { deleteGame } from '../handlers/game/deleteGame'
import { searchGames } from '../handlers/game/searchGames'
import { z } from 'zod'
import { authMiddleware } from '../middlewares/auth'

export const gameSchema = z.object({
  name: z.string().min(1, "Le nom est requis"),
  description: z.string().min(10, "La description est trop courte"),
  image_url: z.string().url("L'URL de l'image est invalide"),
  studio: z.string().min(1),
  // mean_review est souvent géré par le système, pas par l'utilisateur
})

const games = new Hono()

// 1. Définition des routes pour la ressource "Game"
games.get('/', getAllGames)           // Accès public : Liste des jeux
games.get('/search', searchGames)     // Accès public : Recherche de jeux par nom (?q=terme&limit=10)
games.get('/:id', getGameById)        // Accès public : Détail d'un jeu

// 2. Routes protégées (nécessitent authentification + validation des données)
games.post('/', authMiddleware, zValidator('json', gameSchema), createGame)
games.put('/:id', authMiddleware, zValidator('json', gameSchema.partial()), updateGame)
games.delete('/:id', authMiddleware, deleteGame)

export default games