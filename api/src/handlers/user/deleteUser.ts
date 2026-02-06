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
    const userRepository = AppDataSource.getRepository(User);

    // 2. Vérification de l'existence
    const exists = await userRepository.findOneBy({ id_user: id })
    if (!exists) throw new HTTPException(404, { message: "Impossible de supprimer : utilisateur introuvable" })

    // 3. Suppression
    await userRepository.delete({ id_user: id })

    // 4. Confirmation
    return c.json({ success: true, message: "Utilisateur supprimé avec succès" })
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la suppression de l'utilisateur" });
  }
}