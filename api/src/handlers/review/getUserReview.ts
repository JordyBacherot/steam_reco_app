import { Context } from 'hono';
import { AppDataSource } from "../../database/data-source";
import { Review } from '../../entities/Review';
import { HTTPException } from 'hono/http-exception';

/**
 * Récupérer les avis d'un utilisateur
 * Route: GET /reviews/user/:id
 * Description: Renvoie tous les avis postés par un utilisateur spécifique
 */
export const getUserReviews = async (c: Context) => {
  try {
    // 1. Récupération de l'ID utilisateur
    const userId = Number(c.req.param('id'));
    const reviewRepository = AppDataSource.getRepository(Review);

    // 2. Recherche avec jointure (relation 'game')
    const reviews = await reviewRepository.find({
      where: { id_user: userId },
      relations: ['game'],
      order: { id_review: 'DESC' }
    });

    // 3. Retour des données
    return c.json(reviews);
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la récupération des reviews utilisateur" });
  }
};