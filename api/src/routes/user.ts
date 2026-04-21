import { Hono } from 'hono';
import { getAllUser } from '../handlers/user/getAllUser';
import { getUserById } from '../handlers/user/getUserById';
import { updateUser } from '../handlers/user/updateUser';
import { deleteUser } from '../handlers/user/deleteUser';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { authMiddleware } from '../middlewares/auth';

export const createUserSchema = z.object({
  email: z.string().email({ message: "Email invalide" }),
  username: z.string().min(3, { message: "Le pseudo doit faire au moins 3 caractères" }),
  password: z.string().min(8, { message: "Le mot de passe doit faire au moins 8 caractères" }),
  profile_img: z.string().url().optional(),
  have_steamid: z.boolean().default(false)
});

// Schéma de mise à jour : password exclu (changer via POST /auth/password/change)
const updateUserSchema = createUserSchema.omit({ password: true }).partial();

const userRoutes = new Hono();

userRoutes.get('/', authMiddleware, getAllUser);
userRoutes.get('/:id', authMiddleware, getUserById);
userRoutes.put('/:id', authMiddleware, zValidator('json', updateUserSchema), updateUser);
userRoutes.delete('/:id', authMiddleware, deleteUser);

export default userRoutes;