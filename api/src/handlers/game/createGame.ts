import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { Game } from '../../entities/Game'

// Ajouter un jeu
export const createGame = async (c: Context) => {
    try {
      const data = await c.req.json() 
      const gameRepository = AppDataSource.getRepository(Game)
      const newGame = await gameRepository.create(data);
      const result = await gameRepository.save(newGame);
      return c.json(result, 201);
    }  catch (e) {
      return c.json({ message: "Erreur de création" }, 400);
    }
  }