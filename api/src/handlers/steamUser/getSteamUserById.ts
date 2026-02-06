import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { HTTPException } from 'hono/http-exception'
import { SteamUser } from '../../entities/SteamUser';

/**
 * Récupérer un compte Steam par ID Utilisateur
 * Route: GET /steam-users/:id
 * Description: Renvoie les détails du compte Steam lié à un utilisateur
 */
export const getSteamUserById = async (c: Context) => {
  try {
    // 1. Récupération de l'ID utilisateur
    const id = Number(c.req.param('id'));
    const steamUserRepository = AppDataSource.getRepository(SteamUser)

    // 2. Recherche
    const user = await steamUserRepository.findOneBy({ id_user: id });

    // 3. Vérification
    if (!user) throw new HTTPException(404, { message: "Utilisateur steam non trouvé" })

    // 4. Retour
    return c.json(user);
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la récupération du Steam User" });
  }
}