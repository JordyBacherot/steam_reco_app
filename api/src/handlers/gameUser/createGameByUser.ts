import { Context } from 'hono';
import { AppDataSource } from "../../database/data-source";
import { GameUser } from '../../entities/GameUser';
import { Game } from '../../entities/Game';
import { HTTPException } from 'hono/http-exception';

/**
 * Ajouter/Mettre à jour un jeu dans la bibliothèque utilisateur
 * Route: POST /users/:userId/games
 * Description: Ajoute un jeu ou met à jour le temps de jeu si déjà présent
 */
export async function createGameUser(c: Context) {
    const gamesUsersRepository = AppDataSource.getRepository(GameUser);
    const gamesRepository = AppDataSource.getRepository(Game);

    try {
        // 1. Extraction de l'ID depuis l'URL
        const userId = Number(c.req.param('userId'));

        // 2. Extraction des données (inclut maintenant metadata du jeu)
        const { id_game, nb_hours, game_title, game_image_url } = await c.req.json();

        // 3. Validation de sécurité
        if (isNaN(userId) || isNaN(id_game)) {
            return c.json({ success: false, message: "IDs invalides" }, 400);
        }

        // Vérification que l'utilisateur modifie sa propre bibliothèque
        if (c.get("userId") !== userId) {
            throw new HTTPException(403, { message: "Forbidden: vous ne pouvez modifier que votre propre bibliothèque" });
        }

        // 4. Upsert du Jeu (Foreign Key constraint prevention)
        let gameRecord = await gamesRepository.findOneBy({ id_game: id_game });
        if (!gameRecord) {
            gameRecord = gamesRepository.create({
                id_game: id_game,
                name: game_title || "Unknown Game",
                image_url: game_image_url || "https://picsum.photos/id/237/200/300"
            });
            await gamesRepository.save(gameRecord);
        }

        // 5. Logique TypeORM : On cherche si l'entrée utlisateur existe déjà
        let record = await gamesUsersRepository.findOneBy({
            id_user: userId,
            id_game: id_game
        });

        if (record) {
            // Mise à jour si déjà présent
            record.nb_hours = nb_hours;
            await gamesUsersRepository.save(record);
            return c.json({
                success: true,
                message: "Temps de jeu mis à jour",
                data: record
            }, 200);
        }

        // Création si inexistant
        const newRecord = gamesUsersRepository.create({
            id_user: userId,
            id_game: id_game,
            nb_hours: nb_hours
        });

        await gamesUsersRepository.save(newRecord);

        return c.json({
            success: true,
            message: "Jeu ajouté à la bibliothèque",
            data: newRecord
        }, 201);
    } catch (error) {
        if (error instanceof HTTPException) throw error;
        console.error("DEBUG ERROR ADD GAME:", error);
        throw new HTTPException(500, { message: "Erreur lors de l'ajout du jeu à la bibliothèque" });
    }
}