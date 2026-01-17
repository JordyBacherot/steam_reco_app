import type { Context, Next } from "hono";
import { HTTPException } from "hono/http-exception";
import { verify } from "hono/jwt";

/**
 * Interface du Payload JWT
 * Définit la structure des données contenues dans le token une fois décrypté.
 */
interface JWTPayload {
  id_user: number;
  email: string;
}

/**
 * Middleware d'Authentification Custom
 * Ce middleware intercepte chaque requête pour les routes protégées.
 * 
 * Étapes :
 * 1. Vérification de la présence du header "Authorization".
 * 2. Extraction du token (suppression du préfixe "Bearer ").
 * 3. Validation de la signature cryptographique via le Secret.
 * 4. Injection des infos utilisateur dans le contexte (c.set) pour les handlers suivants.
 */
export async function authMiddleware(c: Context, next: Next) {
  try {
    // 1. Récupération du header Authorization
    const authHeader = c.req.header("Authorization");

    // Vérifie que le header existe et commence bien par "Bearer "
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      throw new HTTPException(401, { message: "Unauthorized: Missing or invalid token" });
    }

    // 2. Extraction du token pur (on enlève "Bearer " qui fait 7 caractères)
    const token = authHeader.substring(7);
    const secret = process.env.JWT_SECRET;
    
    // Sécurité : Si le secret n'est pas configuré sur le serveur, on bloque tout
    if (!secret) {
        throw new HTTPException(500, { message: "Internal Server Error: JWT Secret not configured" });
    }

    try {
        // 3. Décodage et vérification de la signature
        // verify() lance une erreur si le token est expiré, modifié ou invalide
        // 'as unknown as JWTPayload' force le typage pour dire "je sais que c'est mon interface"
        const decoded = await verify(token, secret) as unknown as JWTPayload;
        
        // 4. Injection des données dans le contexte de la requête
        // Cela rend 'userId' et 'userEmail' accessibles dans les routeurs (ex: GetMe)
        c.set("userId", decoded.id_user);
        c.set("userEmail", decoded.email);

        // Si tout est bon, on passe la main à la fonction suivante (le handler ou middleware suivant)
        await next();
    } catch (err) {
        // Erreur spécifique si le token est invalide (signature morte) ou expiré
        throw new HTTPException(401, { message: "Unauthorized: Invalid or expired token" });
    }

  } catch (error) {
    // Si c'est déjà une HTTPException (lancée par nous), on la laisse remonter
    if (error instanceof HTTPException) {
        throw error;
    }
    // Sinon, c'est une erreur imprévue (bug), on log et on renvoie une 500
    console.error(error);
    throw new HTTPException(500, { message: "Internal Server Error" });
  }
}
