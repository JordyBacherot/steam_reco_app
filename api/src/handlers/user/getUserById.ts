import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { HTTPException } from 'hono/http-exception'

import { User } from '../../entities/User';

export const getUserById = async (c: Context) => {
  try {
    const id = Number(c.req.param('id'));
    const user = await AppDataSource.getRepository(User).findOneBy({ id_user: id });

    if (!user) throw new HTTPException(404, { message: "Utilisateur non trouvé" })
    return c.json(user);
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la récupération de l'utilisateur" });
  }
}