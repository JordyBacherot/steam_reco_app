import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { HTTPException } from 'hono/http-exception'
import { Review } from '../../entities/Review';

export const getReviewById = async (c: Context) => {
  try {
    const id = Number(c.req.param('id'));
    const reviewRepository = AppDataSource.getRepository(Review)
    const review = await reviewRepository.findOneBy({ id_review: id });

    if (!review) throw new HTTPException(404, { message: "Commentaire non trouvé" })
    return c.json(review);
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la récupération de la review" });
  }
}