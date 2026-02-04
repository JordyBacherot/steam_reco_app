import { Context } from 'hono';
import { AppDataSource } from "../../database/data-source";
import { Review } from '../../entities/Review';
import { HTTPException } from 'hono/http-exception';

export const getGameReviews = async (c: Context) => {
  try {
    const gameId = Number(c.req.param('id'));
    const reviewRepository = AppDataSource.getRepository(Review);

    const reviews = await reviewRepository.find({
      where: { id_game: gameId },
      relations: ['user'], // Pour afficher le pseudo de l'auteur
      order: { id_review: 'DESC' }
    });

    return c.json(reviews);
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la récupération des reviews du jeu" });
  }
};