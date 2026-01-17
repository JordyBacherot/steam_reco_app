import type { Context } from "hono";
import { HTTPException } from "hono/http-exception";
import { sign } from "hono/jwt";
import { AppDataSource } from "../../database/data-source";
import { User } from "../../entities/User";

/**
 * Handler Refresh Token
 * Permet d'obtenir un nouvel Access Token valide en échange d'un Refresh Token valide.
 * 
 * Sécurité (Rotation) :
 * À chaque utilisation réussie, on génère un NOUVEAU Refresh Token et on invalide l'ancien.
 * Cela empêche qu'un refresh token volé soit utilisé indéfiniment.
 */
export default async function RefreshToken(c: Context) {
  try {
    const { refreshToken } = await c.req.json();

    if (!refreshToken) {
      throw new HTTPException(400, { message: "Refresh Token requis" });
    }

    const userRepository = AppDataSource.getRepository(User);
    
    // On cherche l'utilisateur qui possède ce Refresh Token spécifique
    // Note : On doit ajouter .addSelect pour les champs cachés
    const user = await userRepository.createQueryBuilder("user")
      .addSelect("user.refresh_token")
      .addSelect("user.refresh_token_exp")
      .where("user.refresh_token = :token", { token: refreshToken })
      .getOne();

    // Si aucun utilisateur n'a ce token
    if (!user) {
      throw new HTTPException(401, { message: "Refresh Token invalide" });
    }

    // Vérification de l'expiration du Refresh Token
    if (!user.refresh_token_exp || user.refresh_token_exp < new Date()) {
        throw new HTTPException(401, { message: "Refresh Token expiré" });
    }

    // --- ROTATION DU REFRESH TOKEN ---
    const newRefreshToken = crypto.randomUUID();
    user.refresh_token = newRefreshToken;
    
    // On prolonge la session de 2 jours à partir de maintenant
    const refreshExpiresIn = 1000 * 60 * 60 * 24 * 2;
    user.refresh_token_exp = new Date(Date.now() + refreshExpiresIn);
    
    await userRepository.save(user);

    // Création du nouvel Access Token (45 min)
    const accessTokenExpiresIn = 60 * 45;
    const newAccessToken = await sign(
      { 
        id_user: user.id_user, 
        email: user.email,
        exp: Math.floor(Date.now() / 1000) + accessTokenExpiresIn
      }, 
      process.env.JWT_SECRET!
    );

    return c.json({
      success: true,
      token: newAccessToken,
      refreshToken: newRefreshToken // On renvoie le nouveau joker
    });

  } catch (error) {
    if (error instanceof HTTPException) {
      throw error;
    }
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors du rafraîchissement" });
  }
}
