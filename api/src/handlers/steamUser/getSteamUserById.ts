import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { HTTPException } from 'hono/http-exception'
import { SteamUser } from '../../entities/SteamUser';

export const getSteamUserById = async (c: Context) => {
  try {
    const id = Number(c.req.param('id'));
    const steamUserRepository = AppDataSource.getRepository(SteamUser)
    const user = await steamUserRepository.findOneBy({ id_user: id });

    if (!user) throw new HTTPException(404, { message: "Utilisateur steam non trouvé" })
    return c.json(user);
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la récupération du Steam User" });
  }
}