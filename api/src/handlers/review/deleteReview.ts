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

    // 2. Tentative de suppression
    const result = await reviewRepository.delete({
      id_review: reviewId
    });

    // 3. Vérifier si quelque chose a été supprimé
    if (result.affected === 0) {
      return c.json({
        success: false,
        message: "Review non trouvée ou vous n'avez pas l'autorisation de la supprimer"
      }, 404);
    }

    // 4. Confirmation
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