import { Context } from 'hono';
import { AppDataSource } from "../../database/data-source";
import { GameUser } from '../../entities/GameUser';
import { HTTPException } from 'hono/http-exception';

/**
 * Ajouter/Mettre à jour un jeu dans la bibliothèque utilisateur
 * Route: POST /users/:userId/games
 * Description: Ajoute un jeu ou met à jour le temps de jeu si déjà présent
 */
export async function createGameUser(c: Context) {
    const gamesUsersRepository = AppDataSource.getRepository(GameUser);

    try {
        // 1. Extraction de l'ID depuis l'URL (ex: /users/123/games)
        const userId = Number(c.req.param('userId'));

        // 2. Extraction des données depuis le corps de la requête (JSON)
        const { id_game, nb_hours } = await c.req.json();

        // 3. Validation de sécurité
        if (isNaN(userId) || isNaN(id_game)) {
            return c.json({ success: false, message: "IDs invalides" }, 400);
        }

        // 4. Logique TypeORM : On cherche si l'entrée existe déjà
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
        }, 201); // 201 = Created
    } catch (error) {
        if (error instanceof HTTPException) throw error;
        console.error(error);
        throw new HTTPException(500, { message: "Erreur lors de l'ajout du jeu à la bibliothèque" });
    }
}