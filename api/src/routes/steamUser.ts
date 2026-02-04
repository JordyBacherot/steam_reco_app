import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { getAllSteamUser } from '../handlers/steamUser/getAllSteamUser';
import { getSteamUserById } from '../handlers/steamUser/getSteamUserById';
import { createSteamUser } from '../handlers/steamUser/createSteamUser';
import { deleteSteamUser } from '../handlers/steamUser/deleteSteamUser';
import { updateSteamUser } from '../handlers/steamUser/updateSteamUser';

export const createSteamUserSchema = z.object({
  id_steam: z.string().min(1, { message: "Steam ID est requis" }),
  id_user: z.number().int({ message: "ID User invalide" }),
  username: z.string().min(3, { message: "Le pseudo doit faire au moins 3 caractères" }),
  level: z.number().optional(),
  profile_img: z.string().url().optional(),
});

const steamUserRoutes = new Hono();

steamUserRoutes.get('/', getAllSteamUser);
steamUserRoutes.get('/:id', getSteamUserById);
steamUserRoutes.post('/', zValidator('json', createSteamUserSchema), createSteamUser);
steamUserRoutes.put('/:id', zValidator('json', createSteamUserSchema.partial()), updateSteamUser);
steamUserRoutes.delete('/:id', deleteSteamUser);

export default steamUserRoutes;
