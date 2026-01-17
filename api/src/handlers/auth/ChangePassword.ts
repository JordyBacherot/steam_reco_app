import type { Context } from "hono";
import { HTTPException } from "hono/http-exception";
import { AppDataSource } from "../../database/data-source";
import { User } from "../../entities/User";

/**
 * Handler Change Password
 * Permet à un utilisateur connecté de modifier son mot de passe.
 * 
 * Sécurité :
 * 1. Vérifie l'ancien mot de passe.
 * 2. Invalide le Refresh Token (déconnecte les autres sessions par sécurité).
 */
export default async function ChangePassword(c: Context) {
  try {
    // Récupéré via middleware auth
    const userId = c.get("userId");
    const { oldPassword, newPassword } = await c.req.json();

    if (!oldPassword || !newPassword) {
        throw new HTTPException(400, { message: "Ancien et nouveau mot de passe requis" });
    }

    const userRepository = AppDataSource.getRepository(User);
    
    // On récupère l'utilisateur AVEC son mot de passe actuel (nécessaire pour la vérif) grâce au addSelect
    const user = await userRepository.createQueryBuilder("user")
      .addSelect("user.password")
      .where("user.id_user = :id", { id: userId })
      .getOne();

    if (!user) {
      throw new HTTPException(404, { message: "Utilisateur introuvable" });
    }

    // 1. Vérification de l'ancien mot de passe
    const isMatch = await Bun.password.verify(oldPassword, user.password);
    if (!isMatch) {
        throw new HTTPException(401, { message: "Ancien mot de passe incorrect" });
    }

    // 2. Hachage du nouveau mot de passe
    const hashedNewPassword = await Bun.password.hash(newPassword);
    
    // 3. Application des changements
    user.password = hashedNewPassword;
    
    // SÉCURITÉ : On révoque le Refresh Token. 
    // L'utilisateur devra se reconnecter (ou utiliser le nouveau token s'il vient d'être généré, 
    // mais ici on casse la chaîne pour forcer une "hygiène" de sécurité).
    user.refresh_token = null;
    user.refresh_token_exp = null;

    await userRepository.save(user);

    return c.json({
        success: true,
        message: "Mot de passe modifié avec succès. Veuillez vous reconnecter."
    });

  } catch (error) {
    if (error instanceof HTTPException) {
      throw error;
    }
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors du changement de mot de passe" });
  }
}
