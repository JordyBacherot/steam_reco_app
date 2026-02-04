import { Context } from 'hono';
import { AppDataSource } from "../../database/data-source";
import { NearGame } from '../../entities/NearGame';
import { HTTPException } from 'hono/http-exception';

export async function deleteNearGame(c: Context) {
    try {
        const id_game = Number(c.req.param('id'));
        const id_near_game = Number(c.req.param('nearId'));

        if (isNaN(id_game) || isNaN(id_near_game)) {
            return c.json({ success: false, message: "IDs invalides" }, 400);
        }

        const repo = AppDataSource.getRepository(NearGame);
        const result = await repo.delete({ id_game, id_near_game });

        if (result.affected === 0) {
            return c.json({ success: false, message: "Relation non trouvée" }, 404);
        }

        return c.json({ success: true, message: "Relation supprimée avec succès" });
    } catch (error) {
        if (error instanceof HTTPException) throw error;
        console.error(error);
        throw new HTTPException(500, { message: "Erreur lors de la suppression du lien de proximité" });
    }
}