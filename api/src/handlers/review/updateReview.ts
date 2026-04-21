import { Context } from 'hono';
import { AppDataSource } from "../../database/data-source";
import { Review } from '../../entities/Review';
import { HTTPException } from 'hono/http-exception';

/**
 * Mettre à jour un avis
 * Route: PUT /reviews/:id
 * Description: Modifie le texte d'un avis existant
 */
export const updateReview = async (c: Context) => {
  try {
    const reviewRepository = AppDataSource.getRepository(Review);

    // 1. Récupérer l'ID de la review depuis l'URL
    const reviewId = Number(c.req.param('id'));

    // 2. Vérifier l'existence et l'ownership
    const review = await reviewRepository.findOneBy({ id_review: reviewId });
    if (!review) {
      throw new HTTPException(404, { message: "Review introuvable" });
    }
    if (review.id_user !== c.get("userId")) {
      throw new HTTPException(403, { message: "Forbidden: vous ne pouvez modifier que vos propres reviews" });
    }

    // 3. Récupérer les données du body
    const data = await c.req.json();

    // 4. Mise à jour
    await reviewRepository.update({ id_review: reviewId }, { text: data.text });

    return c.json({ success: true, message: "Review mise à jour" });
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la mise à jour de la review" });
  }
};