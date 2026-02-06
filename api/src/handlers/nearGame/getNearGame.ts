import { Context } from 'hono';
import { AppDataSource } from "../../database/data-source";
import { NearGame } from '../../entities/NearGame';
import { HTTPException } from 'hono/http-exception';

/**
 * Récupérer les jeux similaires
 * Route: GET /near-games/:id
 * Description: Renvoie la liste des jeux recommandés/similaires pour un jeu donné
 */
export async function getNearGame(c: Context) {
    try {
        const gameId = Number(c.req.param('id'));

        if (isNaN(gameId)) {
            return c.json({ success: false, message: "ID du jeu invalide" }, 400);
        }

        const repo = AppDataSource.getRepository(NearGame);

        const results = await repo.find({
            where: { id_game: gameId },
            relations: ['nearGame'] // Pour récupérer les détails du jeu similaire
        });

        return c.json({
            success: true,
            count: results.length,
            data: results
        });
    } catch (error) {
        if (error instanceof HTTPException) throw error;
        console.error(error);
        throw new HTTPException(500, { message: "Erreur lors de la récupération des jeux similaires" });
    }
}