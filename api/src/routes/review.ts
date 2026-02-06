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

export type CreateReviewInput = z.infer<typeof createReviewSchema>;

const reviewRoutes = new Hono();

// 1. Récupération des avis (Lecture)
reviewRoutes.get('/game/:id', getGameReviews);  // Par Jeu
reviewRoutes.get('/user/:id', getUserReviews);  // Par Utilisateur
reviewRoutes.get('/:id', getReviewById);        // Par ID unique

// 2. Création et Modification (Ecriture)
// Ajout d'un avis avec validation obligatoire
reviewRoutes.post('/', zValidator('json', createReviewSchema), createReview);

// Mise à jour d'un avis existant
reviewRoutes.put('/:id', zValidator('json', createReviewSchema.pick({ text: true })), updateReview);

// 3. Suppression
reviewRoutes.delete('/:id', deleteReview);

export default reviewRoutes;