import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { HTTPException } from 'hono/http-exception'
import { User } from '../../entities/User';

export const updateUser = async (c: Context) => {
  try {
    const id = Number(c.req.param('id'))
    const data = await c.req.json()

    const userRepository = AppDataSource.getRepository(User);

    // On vérifie d'abord s'il existe
    const exists = await userRepository.findOneBy({ id_user: id })
    if (!exists) throw new HTTPException(404, { message: "Impossible de modifier : utilisateur introuvable" })

    await userRepository.update(
      { id_user: id },
      data
    )

    // On recharge l'utilisateur mis à jour
    const updatedUser = await userRepository.findOneBy({ id_user: id });
    return c.json({ success: true, data: updatedUser })
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la mise à jour de l'utilisateur" });
  }
}