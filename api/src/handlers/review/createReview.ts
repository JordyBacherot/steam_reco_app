import { Context } from 'hono';
import { AppDataSource } from "../../database/data-source";
import { Review } from '../../entities/Review';
import { HTTPException } from 'hono/http-exception';

/**
 * Créer un avis (Review)
 * Route: POST /reviews
 * Description: Ajoute un avis utilisateur sur un jeu
 */
export const createReview = async (c: Context<any>) => {
  try {
    const reviewRepository = AppDataSource.getRepository(Review);

    // 1. Validation automatique via Zod
    const data = await c.req.json();

    // 2. Création de l'entité (id_user forcé depuis le JWT, pas du body)
    const newReview = reviewRepository.create({
      text: data.text,
      id_user: c.get("userId"),
      id_game: data.id_game
    });

    // 3. Sauvegarde
    const result = await reviewRepository.save(newReview);

    // 4. Retour succès (201 Created)
    return c.json(result, 201);
  } catch (error) {
    if (error instanceof HTTPException) throw error;
    console.error(error);
    throw new HTTPException(500, { message: "Erreur lors de la création de la review" });
  }
};