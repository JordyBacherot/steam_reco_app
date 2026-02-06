import { Context } from 'hono'
import { AppDataSource } from "../../database/data-source";
import { HTTPException } from 'hono/http-exception'
import { Review } from '../../entities/Review';

/**
 * Récupérer un avis par son ID
 * Route: GET /reviews/:id
 * Description: Renvoie le détail d'un avis spécifique
 */
export const getReviewById = async (c: Context) => {
  try {
    // 1. Récupération de l'ID par URL
    const id = Number(c.req.param('id'));
    const reviewRepository = AppDataSource.getRepository(Review)

    // 2. Recherche en base
    const review = await reviewRepository.findOneBy({ id_review: id });

    // 3. Gestion d'erreur (404)
    if (!review) throw new HTTPException(404, { message: "Commentaire non trouvé" })

    // 4. Retour de l'avis
    return c.json(review);
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la récupération de la review" });
  }
}