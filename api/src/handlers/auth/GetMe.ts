import type { Context } from "hono";
import { HTTPException } from "hono/http-exception";
import { AppDataSource } from "../../database/data-source";
import { User } from "../../entities/User";

/**
 * Handler GetMe (Profil Utilisateur)
 * Récupère les informations de l'utilisateur courant à partir du token JWT.
 * Cette route est protégée par le middleware `jwt`.
 */
export default async function GetMe(c: Context) {
  try {
    // Récupération de l'ID injecté par le middleware authMiddleware
    const userId = c.get("userId");
    
    if (!userId) {
        throw new HTTPException(401, { message: "Non autorisé" });
    }

    // Récupération de l'utilisateur complet en base
    const userRepository = AppDataSource.getRepository(User);
    const user = await userRepository.findOneBy({ id_user: userId });

    if (!user) {
      throw new HTTPException(404, { message: "Utilisateur introuvable" });
    }

    // On retourne les infos publiques de l'utilisateur (pas le mot de passe !)
    return c.json({
        id_user: user.id_user,
        email: user.email,
        username: user.username,
        profile_img: user.profile_img,
        have_steamid: user.have_steamid
    });
    
  } catch (error) {
    if (error instanceof HTTPException) {
      throw error;
    }
    console.error(error);
    throw new HTTPException(500, {
      message: "Impossible de récupérer les informations utilisateur"
    });
  }
}
