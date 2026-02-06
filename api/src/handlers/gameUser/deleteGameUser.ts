import { Context } from 'hono';
import { AppDataSource } from "../../database/data-source";
import { GameUser } from '../../entities/GameUser';
import { HTTPException } from 'hono/http-exception';

/**
 * Supprimer un jeu de la bibliothèque utilisateur
 * Route: DELETE /users/:userId/games/:gameId
 * Description: Retire l'association entre un utilisateur et un jeu
 */
export async function deleteGameUser(c: Context) {
    const gamesUsersRepository = AppDataSource.getRepository(GameUser);

    try {
        // 1. Extraction des IDs depuis l'URL
        // Note : On utilise les noms définis dans ta route (ex: /:userId/:gameId)
        const userId = Number(c.req.param('userId'));
        const gameId = Number(c.req.param('gameId'));

        // 2. Sécurité : On vérifie que ce sont bien des nombres
        if (isNaN(userId) || isNaN(gameId)) {
            return c.json({
                success: false,
                message: "Identifiants invalides."
            }, 400);
        }

        // 3. Suppression dans la base de données
        const result = await gamesUsersRepository.delete({
            id_user: userId,
            id_game: gameId
        });

        // 4. Gestion de la réponse
        if (result.affected === 0) {
            return c.json({
                success: false,
                message: "Ce jeu n'est pas présent dans la bibliothèque de l'utilisateur."
            }, 404);
        }

        return c.json({
            success: true,
            message: "Le jeu a été retiré de la bibliothèque avec succès."
        });
    } catch (error) {
        if (error instanceof HTTPException) throw error;
        console.error(error);
        throw new HTTPException(500, { message: "Erreur lors de la suppression du jeu de la bibliothèque" });
    }
}