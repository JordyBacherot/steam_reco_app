import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { HTTPException } from 'hono/http-exception'
import { SteamUser } from '../../entities/SteamUser';

/**
 * Mettre à jour un compte Steam
 * Route: PUT /steam-users/:id
 * Description: Modifie les informations d'un compte Steam (niveau, image, etc.)
 */
/**
 * Mettre à jour un compte Steam
 * Route: PUT /steam-users/:id
 * Description: Modifie les informations d'un compte Steam (niveau, image, etc.)
 */
export const updateSteamUser = async (c: Context<any>) => {
  try {
    // Standardisation : On utilise l'ID User (numérique) comme pour GET/DELETE
    const id = Number(c.req.param('id'))

    // Vérification ownership
    if (c.get("userId") !== id) {
      throw new HTTPException(403, { message: "Forbidden: vous ne pouvez modifier que votre propre compte Steam" });
    }

    const body = await c.req.valid('json');

    const { id_steam, username, level, profile_img } = body;

    const steamUserRepository = AppDataSource.getRepository(SteamUser)

    // On vérifie d'abord s'il existe via l'FK id_user
    const existing = await steamUserRepository.findOneBy({ id_user: id })
    if (!existing) throw new HTTPException(404, { message: "Impossible de modifier : utilisateur introuvable" })

    // Si le id_steam (clé primaire) change, on doit supprimer l'ancien et recréer
    if (id_steam !== undefined && id_steam !== existing.id_steam) {
      await steamUserRepository.remove(existing);

      const newSteamUser = steamUserRepository.create({
        id_steam: id_steam,
        id_user: id,
        username_steam: username ?? existing.username_steam,
        level: level ?? existing.level,
        image_profil: profile_img ?? existing.image_profil,
      });

      const saved = await steamUserRepository.save(newSteamUser);
      return c.json({ success: true, data: saved })
    }

    // Sinon, mise à jour partielle classique (sans toucher à la PK)
    const updateData: any = {};
    if (username !== undefined) updateData.username_steam = username;
    if (level !== undefined) updateData.level = level;
    if (profile_img !== undefined) updateData.image_profil = profile_img;

    if (Object.keys(updateData).length > 0) {
      await steamUserRepository.update(
        { id_user: id },
        updateData
      )
    }

    const updatedUser = await steamUserRepository.findOneBy({ id_user: id });
    return c.json({ success: true, data: updatedUser })
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la mise à jour du Steam User" });
  }
}