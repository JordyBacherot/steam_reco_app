import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { HTTPException } from 'hono/http-exception'
import { SteamUser } from '../../entities/SteamUser';

/**
 * Supprimer un compte Steam lié
 * Route: DELETE /steam-users/:id
 * Description: Supprime le lien Steam d'un utilisateur
 */
export const deleteSteamUser = async (c: Context) => {
  try {
    // 1. Récupération de l'ID utilisateur
    const id = Number(c.req.param('id'))

    const steamUserRepository = AppDataSource.getRepository(SteamUser)

    // 2. Vérification existence
    const exists = await steamUserRepository.findOneBy({ id_user: id })
    if (!exists) throw new HTTPException(404, { message: "Impossible de supprimer : utilisateur introuvable" })

    // 3. Suppression
    await steamUserRepository.delete({ id_user: id })

    // 4. Confirmation
    return c.json({ success: true, message: "Utilisateur supprimé avec succès" })
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error("Error deleting Steam User:", error);
    if ((error as any).code === 'ER_ROW_IS_REFERENCED_2') {
      throw new HTTPException(409, { message: "Impossible de supprimer : cet utilisateur est référencé par d'autres données." });
    }
    throw new HTTPException(500, { message: "Erreur lors de la suppression du Steam User" });
  }
}