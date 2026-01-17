import type { Context } from "hono";
import { HTTPException } from "hono/http-exception";
import { AppDataSource } from "../../database/data-source";
import { User } from "../../entities/User";
import { sign } from "hono/jwt";

/**
 * Handler d'Inscription (Sign Up)
 * Crée un nouvel utilisateur en base de données après vérification des doublons.
 */
export default async function SignUp(c: Context) {
  try {
    // Les données sont déjà validées par Zod avant d'arriver ici, mais on les récupère proprement.
    const { email, password, username } = await c.req.json();

    // Double vérification 
    if (!email || !password || !username) {
      throw new HTTPException(400, { message: "Email, mot de passe et nom d'utilisateur requis" });
    }

    const userRepository = AppDataSource.getRepository(User);

    // Vérifie si l'email ou le username existe déjà
    const existingUser = await userRepository.findOne({
        where: [{ email }, { username }]
    });
    
    if (existingUser) {
      throw new HTTPException(409, { message: "Cet email ou nom d'utilisateur est déjà utilisé" });
    }

    // Hachage du mot de passe avec Bun (Argon2 par défaut, très sécurisé)
    const hashedPassword = await Bun.password.hash(password);

    // Création de l'entité User
    const user = userRepository.create({
      email,
      username,
      password: hashedPassword,
      have_steamid: false
    });

    // Sauvegarde en BDD
    await userRepository.save(user);
    
    // Génération immédiate du token JWT (Access Token - 45 min)
    const accessTokenExpiresIn = 60 * 45; // 45 minutes
    const token = await sign({ 
        id_user: user.id_user, 
        email: user.email,
        exp: Math.floor(Date.now() / 1000) + accessTokenExpiresIn
    }, process.env.JWT_SECRET!);

    // Génération du Refresh Token (2 jours)
    const refreshToken = crypto.randomUUID();
    user.refresh_token = refreshToken;
    const refreshExpiresIn = 1000 * 60 * 60 * 24 * 2; // 2 jours
    user.refresh_token_exp = new Date(Date.now() + refreshExpiresIn);
    
    await userRepository.save(user);

    // Réponse succès 201 (Created)
    return c.json({
      success: true,
      message: "Utilisateur créé avec succès",
      user: {
        id_user: user.id_user,
        email: user.email,
        username: user.username
      },
      token: token,
      refreshToken: refreshToken
    }, 201);

  } catch (error) {
    if (error instanceof HTTPException) {
      throw error;
    }
    // Erreur serveur non gérée
    throw new HTTPException(500, { message: "Erreur lors de l'inscription" });
  }
}
