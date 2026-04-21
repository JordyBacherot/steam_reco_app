import { Context } from 'hono';
import { AppDataSource } from "../../database/data-source";
import { Review } from '../../entities/Review';
import { HTTPException } from 'hono/http-exception';

/**
 * Supprimer un avis
 * Route: DELETE /reviews/:id
 * Description: Supprime un avis existant par son ID
 */
export const deleteReview = async (c: Context) => {
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
      throw new HTTPException(403, { message: "Forbidden: vous ne pouvez supprimer que vos propres reviews" });
    }

    // 3. Suppression
    await reviewRepository.delete({ id_review: reviewId });

    return c.json({
      success: true,
      message: "La review a été supprimée avec succès"
    });
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la suppression de la review" });
  }
};