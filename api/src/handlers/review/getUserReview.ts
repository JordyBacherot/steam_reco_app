import { Context } from 'hono';
import { AppDataSource } from "../../database/data-source";
import { Review } from '../../entities/Review';
import { HTTPException } from 'hono/http-exception';

export const getUserReviews = async (c: Context) => {
  try {
    const userId = Number(c.req.param('id'));
    const reviewRepository = AppDataSource.getRepository(Review);

    const reviews = await reviewRepository.find({
      where: { id_user: userId },
      relations: ['game'],
      order: { id_review: 'DESC' }
    });

    return c.json(reviews);
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la récupération des reviews utilisateur" });
  }
};