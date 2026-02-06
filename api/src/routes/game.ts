import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { createGame } from '../handlers/game/createGame'
import { updateGame } from '../handlers/game/updateGame'
import { getAllGames } from '../handlers/game/getAllGame'
import { getGameById } from '../handlers/game/getGameById'
import { deleteGame } from '../handlers/game/deleteGame'
import { z } from 'zod'

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
games.get('/:id', getGameById)        // Accès public : Détail d'un jeu

// 2. Routes protégées ( nécessitent validation des données )
// Création d'un jeu avec validation complète du schéma
games.post('/', zValidator('json', gameSchema), createGame)

// Modification partielle d'un jeu (tous les champs sont optionnels via .partial())
games.put('/:id', zValidator('json', gameSchema.partial()), updateGame)

// Suppression d'un jeu
games.delete('/:id', deleteGame)

export default games