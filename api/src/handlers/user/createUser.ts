import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { User } from '../../entities/User';
import { HTTPException } from 'hono/http-exception';

export const createUser = async (c: Context) => {
  try {
    const body = await c.req.json();
    // Note: Dans un vrai projet, hash le mot de passe ici (ex: bcrypt)
    const userRepository = AppDataSource.getRepository(User);
    const newUser = userRepository.create(body);
    const result = await userRepository.save(newUser);
    return c.json(result, 201);
  } catch (e) {
    if (e instanceof HTTPException) throw e;
    console.error(e);
    throw new HTTPException(500, { message: "Erreur lors de la création de l'utilisateur" });
  }
}