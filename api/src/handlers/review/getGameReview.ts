import { Context } from 'hono';
import { AppDataSource } from "../../database/data-source";
import { Review } from '../../entities/Review';
import { HTTPException } from 'hono/http-exception';

/**
 * Récupérer les avis d'un jeu
 * Route: GET /reviews/game/:id
 * Description: Renvoie la liste des avis liés à un jeu spécifique
 */
export const getGameReviews = async (c: Context) => {
  try {
    // 1. Récupération de l'ID du jeu
    const gameId = Number(c.req.param('id'));
    const reviewRepository = AppDataSource.getRepository(Review);

    // 2. Recherche des avis avec jointure (relation 'user')
    const reviews = await reviewRepository.find({
      where: { id_game: gameId },
      relations: ['user'], // Pour afficher le pseudo de l'auteur
      order: { id_review: 'DESC' }
    });

    // 3. Retour des résultats
    return c.json(reviews);
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la récupération des reviews du jeu" });
  }
};