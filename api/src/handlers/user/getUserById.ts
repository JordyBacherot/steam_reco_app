import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { HTTPException } from 'hono/http-exception'

import { User } from '../../entities/User';

/**
 * Récupérer un utilisateur par son ID
 * Route: GET /users/:id
 * Description: Renvoie les détails d'un utilisateur spécifique
 */
/**
 * Récupérer un utilisateur par son ID
 * Route: GET /users/:id
 * Description: Renvoie les détails d'un utilisateur spécifique
 */
export const getUserById = async (c: Context) => {
  try {
    // 1. Récupération de l'ID depuis les paramètres
    const id = Number(c.req.param('id'));

    // 2. Recherche en base
    const user = await AppDataSource.getRepository(User).findOneBy({ id_user: id });

    // 3. Gestion d'erreur si non trouvé
    if (!user) throw new HTTPException(404, { message: "Utilisateur non trouvé" })

    // 4. Retour des données
    return c.json(user);
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la récupération de l'utilisateur" });
  }
}