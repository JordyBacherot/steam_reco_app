import type { Context } from "hono";
import { HTTPException } from "hono/http-exception";
import { sign } from "hono/jwt"; 
import { AppDataSource } from "../../database/data-source";
import { User } from "../../entities/User";

/**
 * Handler de Connexion (Sign In)
 * Vérifie les identifiants et retourne un token JWT.
 */
export default async function SignIn(c: Context) {
  try {
    const { email, password } = await c.req.json();

    const userRepository = AppDataSource.getRepository(User);
    
    // Recherche de l'utilisateur par email avec son mot de passe (car select: false)
    const user = await userRepository.createQueryBuilder("user")
      .addSelect("user.password")
      .where("user.email = :email", { email })
      .getOne();

    // Si pas d'utilisateur -> Erreur 401
    if (!user) {
      throw new HTTPException(401, { message: "Identifiants invalides" });
    }

    // Vérification du mot de passe (comparaison hash)
    const isMatch = await Bun.password.verify(password, user.password);
    if (!isMatch) {
       throw new HTTPException(401, { message: "Identifiants invalides" });
    }

    // Vérification de la clé secrète JWT
    const secret = process.env.JWT_SECRET;
    if (!secret) {
        throw new HTTPException(500, { message: "Configuration serveur erreur (JWT Secret manquant)" });
    }

    // Génération du token JWT
    // Génération du token JWT (Access Token - 45 min)
    // Hono/JWT ne met pas d'expiration par défaut, il faut ajouter le champ 'exp' (Unix Timestamp en secondes)
    const accessTokenExpiresIn = 60 * 45; // 45 minutes
    const token = await sign(
      { 
        id_user: user.id_user, 
        email: user.email,
        exp: Math.floor(Date.now() / 1000) + accessTokenExpiresIn 
      }, 
      secret
    );

    // Génération du Refresh Token (uuid opaque - 2 jours)
    const refreshToken = crypto.randomUUID();
    user.refresh_token = refreshToken;
    // Date d'expiration du Refresh Token (2 jours)
    const refreshExpiresIn = 1000 * 60 * 60 * 24 * 2; // 2 jours en ms
    user.refresh_token_exp = new Date(Date.now() + refreshExpiresIn);
    
    await userRepository.save(user);

    // Réponse formatée
    return c.json({
      data: {
        success: true,
        token,
        refreshToken,
        user_id: user.id_user,
        user_email: user.email,
        username: user.username
      }
    });

  } catch (error) {
    if (error instanceof HTTPException) {
      throw error;
    }
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la connexion" });
  }
}
