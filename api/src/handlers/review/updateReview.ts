import { Context } from 'hono';
import { AppDataSource } from "../../database/data-source";
import { Review } from '../../entities/Review';
import { HTTPException } from 'hono/http-exception';

export const updateReview = async (c: Context) => {
  try {
    const reviewRepository = AppDataSource.getRepository(Review);

    // 1. Récupérer l'ID de la review depuis l'URL
    const reviewId = Number(c.req.param('id'));

    // 2. Récupérer les données du body
    const data = await c.req.json();

    // 4. Exécuter la mise à jour
    const result = await reviewRepository.update(
      { id_review: reviewId },  // Critères : ID de la review uniquement
      { text: data.text }       // Données à modifier
    );

    if (result.affected === 0) {
      return c.json({ success: false, message: "Review non trouvée ou non autorisée" }, 404);
    }

    return c.json({ success: true, message: "Review mise à jour" });
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la mise à jour de la review" });
  }
};