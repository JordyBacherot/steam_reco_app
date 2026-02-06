import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { HTTPException } from 'hono/http-exception'
import { User } from '../../entities/User';

/**
 * Mettre à jour un utilisateur
 * Route: PUT /users/:id
 * Description: Modifie les informations d'un utilisateur existant
 */
export const updateUser = async (c: Context) => {
  try {
    // 1. Récupération ID et données
    const id = Number(c.req.param('id'))
    const data = await c.req.json()

    const userRepository = AppDataSource.getRepository(User);

    // 2. Vérification de l'existence
    const exists = await userRepository.findOneBy({ id_user: id })
    if (!exists) throw new HTTPException(404, { message: "Impossible de modifier : utilisateur introuvable" })

    // 3. Mise à jour des informations
    await userRepository.update(
      { id_user: id },
      data
    )

    // 4. Récupération de la version mise à jour pour le retour
    const updatedUser = await userRepository.findOneBy({ id_user: id });
    return c.json({ success: true, data: updatedUser })
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la mise à jour de l'utilisateur" });
  }
}