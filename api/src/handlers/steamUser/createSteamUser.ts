import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { User } from '../../entities/User';
import { SteamUser } from '../../entities/SteamUser';
import { HTTPException } from 'hono/http-exception';

/**
 * Lier un compte Steam
 * Route: POST /steam-users
 * Description: Associe un compte Steam à un utilisateur existant
 */
export const createSteamUser = async (c: Context<any>) => {
  try {
    // 1. Récupération des données validées
    const body = await c.req.json();
    const { id_user, id_steam, username, level, profile_img } = body;

    const steamUserRepository = AppDataSource.getRepository(SteamUser);
    const userRepository = AppDataSource.getRepository(User); // Pour vérifier si le user existe

    // 2. Vérification de l'utilisateur lié
    const user = await userRepository.findOneBy({ id_user });
    if (!user) {
      throw new HTTPException(404, { message: "Utilisateur non trouvé" });
    }

    // 3. Vérification unicité (Optionnel mais recommandé)
    const existingSteamUser = await steamUserRepository.findOneBy({ id_steam });
    if (existingSteamUser) {
      throw new HTTPException(409, { message: "Ce compte Steam est déjà lié" });
    }

    // 4. Création de l'entité avec mapping correct
    // Note: On mappe `username` (input) -> `username_steam` (BDD)
    //       On mappe `profile_img` (input) -> `image_profil` (BDD)
    const newSteamUser = steamUserRepository.create({
      id_steam,
      id_user,
      username_steam: username,
      level: level,
      image_profil: profile_img,
      user: user // Liaison TypeORM
    });

    const result = await steamUserRepository.save(newSteamUser);
    return c.json(result, 201);
  } catch (e) {
    if (e instanceof HTTPException) throw e;
    console.error(e);
    // Gestion des erreurs de contrainte de clé étrangère ou autre erreur SQL
    if ((e as any).code === 'ER_DUP_ENTRY') {
      throw new HTTPException(409, { message: "Conflit : Données déjà existantes" });
    }
    throw new HTTPException(500, { message: "Erreur lors de la création du Steam User" });
  }
}