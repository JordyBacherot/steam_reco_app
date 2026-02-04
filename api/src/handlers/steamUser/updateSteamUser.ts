import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { HTTPException } from 'hono/http-exception'
import { SteamUser } from '../../entities/SteamUser';

export const updateSteamUser = async (c: Context<any>) => {
  try {
    // Standardisation : On utilise l'ID User (numérique) comme pour GET/DELETE
    // Standardisation : On utilise l'ID User (numérique) comme pour GET/DELETE
    const id = Number(c.req.param('id'))
    const body = await c.req.valid('json');

    // Extraction et mapping des champs (ignorer id_steam/id_user s'ils sont envoyés)
    const { username, level, profile_img } = body;

    const steamUserRepository = AppDataSource.getRepository(SteamUser)

    // On vérifie d'abord s'il existe via l'FK id_user
    const exists = await steamUserRepository.findOneBy({ id_user: id })
    if (!exists) throw new HTTPException(404, { message: "Impossible de modifier : utilisateur introuvable" })

    // Construction de l'objet de mise à jour partiel
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