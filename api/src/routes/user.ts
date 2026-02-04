import { Hono } from 'hono';
import { getAllUser } from '../handlers/user/getAllUser';
import { getUserById } from '../handlers/user/getUserById';
import { createUser } from '../handlers/user/createUser';
import { updateUser } from '../handlers/user/updateUser';
import { deleteUser } from '../handlers/user/deleteUser';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';

export const createUserSchema = z.object({
  email: z.string().email({ message: "Email invalide" }),
  username: z.string().min(3, { message: "Le pseudo doit faire au moins 3 caractères" }),
  password: z.string().min(8, { message: "Le mot de passe doit faire au moins 8 caractères" }),
  profile_img: z.string().url().optional(),
  have_steamid: z.boolean().default(false)
});

const userRoutes = new Hono();

userRoutes.get('/', getAllUser);
userRoutes.get('/:id', getUserById);
userRoutes.post('/', zValidator('json', createUserSchema), createUser);
userRoutes.put('/:id', zValidator('json', createUserSchema.partial()), updateUser);
userRoutes.delete('/:id', deleteUser);

export default userRoutes;