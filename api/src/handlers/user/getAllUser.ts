import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { User } from '../../entities/User';
import { HTTPException } from 'hono/http-exception';

export const getAllUser = async (c: Context) => {
  try {
    const users = await AppDataSource.getRepository(User).find();
    return c.json(users);
  } catch (e) {
    console.error(e);
    throw new HTTPException(500, { message: "Erreur lors de la récupération des utilisateurs" });
  }
}