import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { User } from '../../entities/User';
import { HTTPException } from 'hono/http-exception';

/**
 * Récupérer tous les utilisateurs
 * Route: GET /users
 * Description: Renvoie la liste complète des utilisateurs enregistrés
 */
/**
 * Récupérer tous les utilisateurs
 * Route: GET /users
 * Description: Renvoie la liste complète des utilisateurs enregistrés
 */
export const getAllUser = async (c: Context) => {
  try {
    // 1. Appel direct au repository pour récupérer la liste
    const users = await AppDataSource.getRepository(User).find();

    // 2. Retour des données
    return c.json(users);
  } catch (e) {
    console.error(e);
    throw new HTTPException(500, { message: "Erreur lors de la récupération des utilisateurs" });
  }
}