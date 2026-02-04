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

games.get('/', getAllGames)
games.get('/:id', getGameById)

// On applique la validation Zod sur le POST et le PUT
games.post('/', zValidator('json', gameSchema), createGame)
// Pour la modification, on rend les champs optionnels (.partial())
games.put('/:id', zValidator('json', gameSchema.partial()), updateGame)

games.delete('/:id', deleteGame)

export default games