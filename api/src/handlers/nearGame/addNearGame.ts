import { Context } from 'hono';
import { AppDataSource } from "../../database/data-source";
import { NearGame } from '../../entities/NearGame';
import { Game } from '../../entities/Game';
import { HTTPException } from 'hono/http-exception';

/**
 * Ajouter une liaison de proximité (NearGame)
 * Route: POST /near-games
 * Description: Crée une relation de similarité entre deux jeux
 */
export async function addNearGame(c: Context) {
    try {
        const repo = AppDataSource.getRepository(NearGame);
        const gameRepo = AppDataSource.getRepository(Game);

        // 1. Récupération des données du corps de la requête
        const body = await c.req.json();
        const { id_game, id_near_game } = body;

        // 2. Validation basique
        if (!id_game || !id_near_game) {
            return c.json({ success: false, message: "Les IDs id_game et id_near_game sont requis." }, 400);
        }

        if (id_game === id_near_game) {
            return c.json({ success: false, message: "Un jeu ne peut pas être similaire à lui-même." }, 400);
        }

        // 3. Vérification de l'existence des jeux
        const gameExists = await gameRepo.findOneBy({ id_game });
        const nearGameExists = await gameRepo.findOneBy({ id_game: id_near_game });

        if (!gameExists || !nearGameExists) {
            return c.json({ success: false, message: "Un ou plusieurs jeux n'existent pas." }, 404);
        }

        // 4. Vérification si la liaison existe déjà
        const existingLink = await repo.findOneBy({ id_game, id_near_game });
        if (existingLink) {
            return c.json({ success: false, message: "Cette liaison existe déjà." }, 409);
        }

        // 5. Création de la liaison
        const newLink = repo.create({
            id_game,
            id_near_game
        });

        await repo.save(newLink);

        // 6. Retour succès
        return c.json({
            success: true,
            message: "Liaison de proximité ajoutée avec succès",
            data: newLink
        }, 201);

    } catch (error) {
        if (error instanceof HTTPException) throw error;
        console.error(error);
        throw new HTTPException(500, { message: "Erreur lors de l'ajout du lien de proximité" });
    }
}
