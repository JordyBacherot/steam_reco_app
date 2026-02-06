import { AppDataSource } from "../../database/data-source";
import { GameUser } from '../../entities/GameUser';
import { Context } from 'hono';
import { HTTPException } from 'hono/http-exception';


/**
 * Récupérer la bibliothèque de jeux d'un utilisateur
 * Route: GET /users/:userId/games
 * Description: Renvoie la liste des jeux possédés par l'utilisateur
 */
export async function getGameByUser(c: Context) {
    try {
        const gamesUsersRepository = AppDataSource.getRepository(GameUser);

        // 1. Extraction du paramètre 'userId' depuis l'URL
        const userId = Number(c.req.param('userId'));

        // 2. Vérification si l'ID est bien un nombre
        if (isNaN(userId)) {
            return c.json({
                success: false,
                message: "L'identifiant utilisateur est invalide."
            }, 400);
        }

        // 3. Récupération des données avec la relation 'game'
        const games = await gamesUsersRepository.find({
            where: { id_user: userId },
            relations: ['game']
        });

        // 4. Retour de la réponse JSON
        return c.json({
            success: true,
            data: games
        });
    } catch (error) {
        if (error instanceof HTTPException) throw error;
        console.error(error);
        throw new HTTPException(500, { message: "Erreur lors de la récupération des jeux" });
    }
}