import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { getGameReviews } from '../handlers/review/getGameReview';
import { deleteReview } from '../handlers/review/deleteReview';
import { updateReview } from '../handlers/review/updateReview';
import { createReview } from '../handlers/review/createReview';
import { getUserReviews } from '../handlers/review/getUserReview';
import { getReviewById } from '../handlers/review/getReviewById';

export const createReviewSchema = z.object({
  id_game: z.number().int({ message: "ID Game invalide" }),
  id_user: z.number().int({ message: "ID User invalide" }),
  text: z.string().min(10, { message: "Le message doit faire au moins 10 caractères" }),
});

const reviewRoutes = new Hono();

reviewRoutes.get('/game/:id', getGameReviews);
reviewRoutes.get('/user/:id', getUserReviews);
reviewRoutes.get('/:id', getReviewById);
reviewRoutes.post('/', zValidator('json', createReviewSchema), createReview);
reviewRoutes.put('/:id', zValidator('json', createReviewSchema), updateReview);
reviewRoutes.delete('/:id', deleteReview);

export default reviewRoutes;