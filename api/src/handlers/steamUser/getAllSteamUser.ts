import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { SteamUser } from '../../entities/SteamUser';
import { HTTPException } from 'hono/http-exception';

/**
 * Récupérer tous les comptes Steam
 * Route: GET /steam-users
 * Description: Renvoie la liste complète des comptes Steam enregistrés
 */
export const getAllSteamUser = async (c: Context) => {
  try {
    // 1. Initialisation repo
    const steamUserRepository = AppDataSource.getRepository(SteamUser)

    // 2. Récupération liste complète
    const users = await steamUserRepository.find();

    // 3. Retour
    return c.json(users);
  } catch (e) {
    console.error(e);
    throw new HTTPException(500, { message: "Erreur lors de la récupération des Steam Users" });
  }
}