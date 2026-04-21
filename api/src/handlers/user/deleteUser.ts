import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { HTTPException } from 'hono/http-exception'
import { User } from '../../entities/User';

/**
 * Supprimer un utilisateur
 * Route: DELETE /users/:id
 * Description: Supprime définitivement un utilisateur via son ID
 */
export const deleteUser = async (c: Context) => {
  try {
    // 1. Récupération de l'ID depuis l'URL
    const id = Number(c.req.param('id'))

    // 2. Vérification que l'utilisateur supprime son propre compte
    if (c.get("userId") !== id) {
      throw new HTTPException(403, { message: "Forbidden: vous ne pouvez supprimer que votre propre compte" });
    }

    const userRepository = AppDataSource.getRepository(User);

    // 3. Vérification de l'existence
    const exists = await userRepository.findOneBy({ id_user: id })
    if (!exists) throw new HTTPException(404, { message: "Impossible de supprimer : utilisateur introuvable" })

    // 4. Suppression
    await userRepository.delete({ id_user: id })

    // 4. Confirmation
    return c.json({ success: true, message: "Utilisateur supprimé avec succès" })
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la suppression de l'utilisateur" });
  }
}