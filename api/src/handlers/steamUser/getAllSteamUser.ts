import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { SteamUser } from '../../entities/SteamUser';
import { HTTPException } from 'hono/http-exception';

export const getAllSteamUser = async (c: Context) => {
  try {
    const steamUserRepository = AppDataSource.getRepository(SteamUser)
    const users = await steamUserRepository.find();
    return c.json(users);
  } catch (e) {
    console.error(e);
    throw new HTTPException(500, { message: "Erreur lors de la récupération des Steam Users" });
  }
}