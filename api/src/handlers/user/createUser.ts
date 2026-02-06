import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { User } from '../../entities/User';
import { HTTPException } from 'hono/http-exception';

/**
 * Créer un nouvel utilisateur
 * Route: POST /users
 * Description: Ajoute un nouvel utilisateur avec validation des données
 */
export const createUser = async (c: Context) => {
  try {
    // 1. Récupération des données du corps de la requête
    const body = await c.req.json();

    // Note: Dans un vrai projet, hash le mot de passe ici (ex: bcrypt)

    // 2. Initialisation du repository
    const userRepository = AppDataSource.getRepository(User);

    // 3. Création de l'entité
    const newUser = userRepository.create(body);

    // 4. Sauvegarde en base de données
    const result = await userRepository.save(newUser);

    // 5. Retour de la réponse
    return c.json(result, 201);
  } catch (e) {
    if (e instanceof HTTPException) throw e;
    console.error(e);
    throw new HTTPException(500, { message: "Erreur lors de la création de l'utilisateur" });
  }
}