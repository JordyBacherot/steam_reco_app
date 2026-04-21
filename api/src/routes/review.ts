import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { getGameReviews } from '../handlers/review/getGameReview';
import { deleteReview } from '../handlers/review/deleteReview';
import { updateReview } from '../handlers/review/updateReview';
import { createReview } from '../handlers/review/createReview';
import { getUserReviews } from '../handlers/review/getUserReview';
import { getReviewById } from '../handlers/review/getReviewById';
import { authMiddleware } from '../middlewares/auth';


export const createReviewSchema = z.object({
  id_game: z.number().int({ message: "ID Game invalide" }),
  text: z.string().min(2, { message: "Le message doit faire au moins 2 caractères" }),
});

export type CreateReviewInput = z.infer<typeof createReviewSchema>;

const reviewRoutes = new Hono();

// 1. Récupération des avis (Lecture - public)
reviewRoutes.get('/game/:id', getGameReviews);
reviewRoutes.get('/user/:id', getUserReviews);
reviewRoutes.get('/:id', getReviewById);

// 2. Création et Modification (Ecriture - protégé)
reviewRoutes.post('/', authMiddleware, zValidator('json', createReviewSchema), createReview);
reviewRoutes.put('/:id', authMiddleware, zValidator('json', createReviewSchema.pick({ text: true })), updateReview);

// 3. Suppression (protégé)
reviewRoutes.delete('/:id', authMiddleware, deleteReview);

export default reviewRoutes;